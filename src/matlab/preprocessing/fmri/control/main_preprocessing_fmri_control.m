%% main_preprocessing_fmri_control.m
%
% Reappraisal-control fMRI preprocessing master.
%
% This file summarizes the manuscript-facing preprocessing sequence for
% the control fMRI cohort.
%
% Historical cohort name:
%   reappraisal_control_2023
%
% PUBLIC PIPELINE
% ---------------
%
%   1. Bruker/ParaVision conversion and reorientation
%   2. identify task EPI, TurboRARE3D anatomy, and field maps from scan list
%   3. remove first 5 EPI volumes
%   4. AFNI 3dDespike
%   5. field-map preparation / distortion correction
%   6. realignment and unwarping
%   7. slice-time correction
%   8. EPI-to-anatomical coregistration where required
%   9. anatomical brain extraction
%  10. anatomical + functional alignment to template space
%  11. anatomical bias correction and tissue segmentation
%  12. DARTEL study-template creation and normalization
%  13. reslice normalized EPI
%  14. create analysis branches
%  15. mask / intensity-normalize EPI
%  16. wavelet despiking
%
% Raw MRI acquisitions are not distributed publicly.
%
% PROJECT FUNCTIONS
% -----------------
% Control-specific functions can be stored under:
%
%   src/matlab/preprocessing/fmri/control/functions/
%
% The current repository already stores the shared fMRI preprocessing
% functions under:
%
%   src/matlab/preprocessing/fmri/reappraisal/functions/
%
% Both locations are added below.
%
% TOOLBOXES
% ---------
% Repository-local toolboxes are stored under:
%
%   src/matlab/preprocessing/toolboxes/
%
% Only preprocessing-relevant toolboxes are added globally here.
% SPM12 and AFNI are external dependencies.

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

% repo/src/matlab/preprocessing/fmri/
fmriPreprocessingDir = fileparts(scriptDir);

% repo/src/matlab/preprocessing/
preprocessingRoot = fileparts(fmriPreprocessingDir);

helpersDir = fullfile( ...
    preprocessingRoot, ...
    'helpers' ...
);

controlFunctionsDir = fullfile( ...
    scriptDir, ...
    'functions' ...
);

sharedFmriFunctionsDir = fullfile( ...
    fmriPreprocessingDir, ...
    'reappraisal', ...
    'functions' ...
);

toolboxesDir = fullfile( ...
    preprocessingRoot, ...
    'toolboxes' ...
);

%% Add repository helpers

if ~isfolder(helpersDir)
    error('Preprocessing helper directory not found:\n%s', helpersDir);
end

addpath(helpersDir);

repoRoot = find_repo_root(scriptFile);

%% Add project-specific fMRI preprocessing functions

if isfolder(sharedFmriFunctionsDir)
    addpath(genpath(sharedFmriFunctionsDir));
else
    warning('Shared fMRI function directory not found:\n%s', ...
        sharedFmriFunctionsDir);
end

if isfolder(controlFunctionsDir)
    addpath(genpath(controlFunctionsDir));
end

%% Add only preprocessing-relevant repository-local toolboxes

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

% Deliberately NOT added globally:
%
%   2019_03_03_BCT
%   BASCO
%   NBS1.2
%
% These are analysis- or figure-specific dependencies.

cfg = fmri_control_config(repoRoot);

%% Check non-public raw MRI path

if isempty(cfg.rawMriRoot) || ~isfolder(cfg.rawMriRoot)
    fprintf([ ...
        '\nRaw control MRI root is not configured.\n' ...
        'Set environment variable:\n' ...
        '  NOSEMAZE_CONTROL_FMRI_RAW_ROOT\n\n' ...
        'This is expected for a public GitHub clone because the original ' ...
        'MRI acquisitions are not distributed.\n\n' ...
    ]);
end

%% Create repository working directories

requiredDirs = {
    cfg.workRoot
    cfg.convertedDir
    cfg.fileListDir
    cfg.dartelDir
    cfg.motionDir
    cfg.processedRoot
};

for dirIndex = 1:numel(requiredDirs)
    if ~isfolder(requiredDirs{dirIndex})
        mkdir(requiredDirs{dirIndex});
    end
end

%% Scan-list status
%
% Historical scan types used by the control workflow:
%
%   EPI task:
%       EPI_FID_1.1_22Slc
%
%   anatomy:
%       TurboRARE3D
%
%   field maps:
%       Fieldmap_1
%       Fieldmap_2
%
% The historical script generated machine-specific Pfunc/P3d/Pdmap file
% lists from this scan list. The public version should regenerate those
% paths after conversion rather than commit the old absolute-path MAT file.

if isfile(cfg.scanList)

    fprintf('Control scan list found:\n%s\n', cfg.scanList);

else

    warning([ ...
        'Control scan list is not yet available at the expected location:\n%s\n' ...
        'Copy ScanList_reappraisal_control_2023.csv there before rebuilding ' ...
        'the control file manifest.' ...
    ], cfg.scanList);
end

%% Stage selection
%
% The public master documents the ordered workflow and performs path/dependency
% checks. Raw-data stage wrappers remain disabled until validated against the
% private acquisition environment.

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
%
% Functions below are directly called in the historical control master.
% Several are shared with the reappraisal pipeline.

% These are the project helpers packaged in the current public source tree.
% Two exact historical-only calls (wwf_reform_bruker3 and
% intensity_normalization_by100) are documented separately in
% DEPENDENCIES.md and are not treated as missing core dependencies because
% this cleaned master does not execute raw-to-processed stages.

requiredCoreFunctions = {
    'wwf_del_vol'
    'fieldmap_fill_dilate_jr'
    'wwf_fix_fm_offset'
    'wwf_appl_fieldmap_reappraisal_control_2023_jr'
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
    'WaveletDespike'
};

missingCoreFunctions = requiredCoreFunctions( ...
    cellfun(@(x) isempty(which(x)), requiredCoreFunctions) ...
);

if ~isempty(missingCoreFunctions)

    fprintf('Missing control preprocessing functions/dependencies:\n');
    fprintf('  %s\n', missingCoreFunctions{:});

    fprintf([ ...
        '\nExpected project functions are under either:\n%s\n%s\n' ...
        'Repository-local preprocessing toolboxes are under:\n%s\n\n' ...
    ], ...
        controlFunctionsDir, ...
        sharedFmriFunctionsDir, ...
        toolboxesDir ...
    );

else

    fprintf('All packaged MATLAB control preprocessing helpers were found.\n');
end

%% External dependency checks

if isempty(which('spm'))
    error([ ...
        'SPM12 was not found on the MATLAB path. ' ...
        'Install SPM12 separately and add it before running preprocessing.' ...
    ]);
else
    fprintf('SPM12 found: %s\n', which('spm'));
end

[afniStatus, ~] = system('3dDespike -help > /dev/null 2>&1');

if ispc
    [afniStatus, ~] = system('3dDespike -help > NUL 2>&1');
end

if afniStatus ~= 0
    warning('AFNI 3dDespike was not found on the system PATH.');
end

%% Important control-specific historical notes
%
% 1. Functional-to-anatomical coregistration
%    The historical control script states that this step was generally
%    omitted and used only for one animal (ZI_M230906D). Do not convert
%    that historical exception into a blanket cohort-wide coregistration
%    without checking the final data.
%
% 2. Field-map loops
%    Several historical blocks were restricted manually to ix = 1:3.
%    The cleaned pipeline should determine valid subjects from the control
%    scan list / file manifest rather than retaining that hard-coded index.
%
% 3. Scrubbing / DVARS / CSF-regression sections
%    These were historical QC/alternative processing branches and are not
%    included in the compact core pipeline above
%    unless confirmed as inputs to the final manuscript products.
%
% 4. Wavelet masking
%    The historical script referenced a polished DARTEL mask from the main
%    reappraisal preprocessing. This cross-cohort reference should be
%    confirmed before the cleaned executable stage is frozen.
%
% 5. Historical-only helper calls
%    The historical workflow also called wwf_reform_bruker3.m and
%    intensity_normalization_by100.m. These exact files are not packaged as
%    canonical public helpers. They remain provenance items only; do not
%    substitute similarly named functions without validating equivalence.

%% Guard against accidental execution of unfinished stage wrappers

if any(structfun(@(x) logical(x), runStage))
    error([ ...
        'One or more control preprocessing stages were enabled, but the ' ...
        'cleaned stage-execution blocks have not yet been migrated and ' ...
        'validated. Keep the switches false for documentation/provenance ' ...
        'or complete the stage migration first.' ...
    ]);
end

fprintf('\nControl fMRI preprocessing structure initialized.\n');
fprintf('Repository root: %s\n', repoRoot);
fprintf('Shared fMRI functions: %s\n', sharedFmriFunctionsDir);
fprintf('Control-specific functions: %s\n', controlFunctionsDir);
fprintf('Preprocessing toolboxes: %s\n', toolboxesDir);
fprintf('Configuration: %s\n', ...
    fullfile(scriptDir, 'fmri_control_config.m'));
