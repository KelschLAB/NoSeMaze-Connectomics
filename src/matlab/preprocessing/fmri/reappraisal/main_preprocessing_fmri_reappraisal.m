%% main_preprocessing_fmri_reappraisal.m
%
% Reappraisal-cohort fMRI preprocessing master.
%
% This file defines the public ordered preprocessing workflow reconstructed
% from the historically executed processing sequence.
%
% The final manuscript pipeline is:
%
%   1. Bruker/ParaVision conversion, x10 SPM scaling, reorientation
%   2. remove first 5 EPI volumes
%   3. AFNI 3dDespike
%   4. field-map preparation and distortion correction
%   5. SPM realignment/unwarping
%   6. slice-time correction
%   7. EPI-to-anatomical coregistration
%   8. anatomical brain extraction
%   9. anatomical + functional alignment to Paxinos-space template
%  10. anatomical bias correction and tissue segmentation
%  11. DARTEL study-template creation and normalization
%  12. produce three task-EPI branches:
%        a) unsmoothed normalized EPI for FC/graph analyses
%        b) 0.6 mm FWHM for primary voxelwise BOLD analyses
%        c) 0.4 mm FWHM robustness branch
%  13. masking / intensity normalization
%  14. wavelet despiking
%
% Raw MRI acquisitions are deliberately external/non-public.
%
% DEPENDENCIES
% ------------
% Project-specific preprocessing functions are stored under:
%
%   src/matlab/preprocessing/fmri/reappraisal/functions/
%
% Repository-local preprocessing toolboxes are stored under:
%
%   src/matlab/preprocessing/toolboxes/
%
% Only preprocessing-relevant toolboxes are added here. Analysis toolboxes
% such as BCT, BASCO, and NBS are deliberately NOT added globally by this
% master.
%
% SPM12 and AFNI are external dependencies and must be installed separately.

clearvars;
close all;
clc;

%% Locate repository and configure MATLAB paths

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error([ ...
        'MATLAB could not determine the script location. ' ...
        'Run the complete saved script rather than selected lines.' ...
    ]);
end

scriptDir = fileparts(scriptFile);

% Expected:
% repo/src/matlab/preprocessing/fmri/reappraisal/
fmriPreprocessingDir = fileparts(scriptDir);

% Expected:
% repo/src/matlab/preprocessing/
preprocessingRoot = fileparts(fmriPreprocessingDir);

helpersDir = fullfile( ...
    preprocessingRoot, ...
    'helpers' ...
);

functionsDir = fullfile( ...
    scriptDir, ...
    'functions' ...
);

toolboxesDir = fullfile( ...
    preprocessingRoot, ...
    'toolboxes' ...
);

%% Add repository helper functions

if ~isfolder(helpersDir)
    error('Preprocessing helper directory not found:\n%s', helpersDir);
end

addpath(helpersDir);

repoRoot = find_repo_root(scriptFile);

%% Add project-specific reappraisal preprocessing functions

if ~isfolder(functionsDir)
    error('Reappraisal preprocessing function directory not found:\n%s', ...
        functionsDir);
end

addpath(genpath(functionsDir));

%% Add only preprocessing-relevant repository-local toolboxes
%
% Do NOT use addpath(genpath(toolboxesDir)) here. The toolbox directory also
% contains analysis packages such as BCT, BASCO, NBS, and a separate HRF
% implementation. Adding all of them globally can introduce function-name
% collisions and makes preprocessing dependent on unrelated analyses.

spm12AnimalDir = fullfile( ...
    toolboxesDir, ...
    'spm12_animal' ...
);

waveletDespikingDir = fullfile( ...
    toolboxesDir, ...
    'wavelet_despiking' ...
);

if isfolder(spm12AnimalDir)
    addpath(genpath(spm12AnimalDir));
else
    warning('Repository-local spm12_animal toolbox not found:\n%s', ...
        spm12AnimalDir);
end

if isfolder(waveletDespikingDir)
    addpath(genpath(waveletDespikingDir));
else
    warning('Repository-local wavelet_despiking toolbox not found:\n%s', ...
        waveletDespikingDir);
end

% The following repository-local toolboxes are intentionally NOT added by
% the preprocessing master:
%
%   2019_03_03_BCT
%   BASCO
%   NBS1.2
%
% They are analysis- or figure-specific dependencies and should be added
% only by scripts that actually require them.

cfg = fmri_reappraisal_config(repoRoot);

if isempty(cfg.rawMriRoot) || ~isfolder(cfg.rawMriRoot)
    fprintf([ ...
        '\nRaw MRI root is not configured.\n' ...
        'Set environment variable:\n' ...
        '  NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT\n\n' ...
        'This is expected for a public GitHub clone because the original ' ...
        'MRI acquisitions are not distributed.\n\n' ...
    ]);
end

if ~isfolder(cfg.workRoot); mkdir(cfg.workRoot); end
if ~isfolder(cfg.fileListDir); mkdir(cfg.fileListDir); end
if ~isfolder(cfg.processedRoot); mkdir(cfg.processedRoot); end


%% Validate acquisition scan list and build core manifest
%
% This step is fully reproducible without access to the original MRI data.

scanInfo = validate_scanlist_reappraisal(cfg.scanList);

manifest = build_reappraisal_scan_manifest( ...
    cfg.scanList, ...
    cfg.fileListDir ...
);

fprintf( ...
    '\nCore acquisition manifest contains %d subjects.\n', ...
    height(manifest) ...
);

%% Stage selection
%
% The repository paths and dependencies are configured above. These stage
% switches remain false by default so that users can inspect/configure the
% workflow before running preprocessing on the non-public raw MRI data.

runStage.convertAndBuildFileList = false;
runStage.removeDummies = false;
runStage.afniDespike = false;
runStage.fieldmapAndUnwarp = false;
runStage.sliceTimeCorrection = false;
runStage.coregistration = false;
runStage.brainExtraction = false;
runStage.templateAlignment = false;
runStage.biasAndSegmentation = false;
runStage.dartel = false;
runStage.prepareAnalysisBranches = false;
runStage.waveletDespike = false;

%% Dependency check

requiredCoreFunctions = {
    'do_pvconv_jr'
    'wwf_del_vol'
    'wwf_FieldMap_rat_jr'
    'fieldmap_fill_dilate_jr'
    'do_unwarp_jr'
    'do_slice_time_reappraisal_jr'
    'do_coreg_func23d_lw'
    'ms_do_brainExtraction'
    'do_shift_auto_brain_TwoPfunc_jr'
    'do_coreg_all2temp_2func_jr'
    'wwf_do_bias_jr'
    'jr_do_segmentation'
    'jr_do_DARTEL_inital_import'
    'jr_do_DARTEL_create_templates'
    'spm_dartel_norm_fun_mice_jr'
    'do_reslice'
    'do_smooth_lw'
    'intensity_normalization'
    'WaveletDespike'
};

missingCoreFunctions = requiredCoreFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredCoreFunctions) ...
);

if ~isempty(missingCoreFunctions)
    fprintf('Missing preprocessing functions/dependencies:\n');
    fprintf('  %s\n', missingCoreFunctions{:});
    fprintf([ ...
        '\nExpected project functions are under:\n%s\n' ...
        'Repository-local preprocessing toolboxes are under:\n%s\n\n' ...
    ], functionsDir, toolboxesDir);
else
    fprintf('All listed MATLAB preprocessing functions were found.\n');
end

%% External dependency check

if isempty(which('spm'))
    error([ ...
        'SPM12 was not found on the MATLAB path. ' ...
        'Install SPM12 separately and add it before running fMRI preprocessing.' ...
    ]);
else
    fprintf('SPM12 found: %s\n', which('spm'));
end

[afniStatus,~] = system('3dDespike -help > /dev/null 2>&1');
if ispc
    [afniStatus,~] = system('3dDespike -help > NUL 2>&1');
end

if afniStatus ~= 0
    warning('AFNI 3dDespike was not found on the system PATH.');
end

%% Guard against accidental execution of unfinished stage wrappers
%
% The dependency/path setup above is operational. The individual cleaned
% stage-execution blocks still need to be migrated from the historical
% master before these switches should be enabled.

if any(structfun(@(x) logical(x), runStage))
    error([ ...
        'One or more preprocessing stages were enabled, but the cleaned ' ...
        'stage-execution blocks have not yet been migrated into this public ' ...
        'master. Keep the switches false for documentation/provenance, or ' ...
        'complete the stage migration before execution.' ...
    ]);
end

fprintf('\nReappraisal fMRI preprocessing structure initialized.\n');
fprintf('Repository root: %s\n', repoRoot);
fprintf('Project functions: %s\n', functionsDir);
fprintf('Preprocessing toolboxes: %s\n', toolboxesDir);
fprintf('Configuration: %s\n', ...
    fullfile(scriptDir, 'fmri_reappraisal_config.m'));
