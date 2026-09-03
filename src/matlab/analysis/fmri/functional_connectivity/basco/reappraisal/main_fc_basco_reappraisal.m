%% main_fc_basco_reappraisal.m
%
% Primary BASCO beta-series functional-connectivity pipeline for the
% conditioning/reappraisal cohort.
%
% Scientific constraints:
%   - BASCO version v11
%   - BASCO trial-wise regressors v19
%   - UNSMOOTHED normalized EPI for FC/graph analyses
%   - 52 bilateral/bi-hemispheric Allen-atlas ROIs
%   - 10 primary Pearson correlation matrices per subject
%
% NBS inference and graph analysis are deliberately separate modules.

clearvars;
close all;
clc;

%% Locate repository

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);                 % .../basco/reappraisal
bascoDir = fileparts(scriptDir);                   % .../basco
commonFunctionsDir = fullfile(bascoDir, 'common', 'functions');
localFunctionsDir = fullfile(scriptDir, 'functions');

assert(isfolder(commonFunctionsDir), ...
    'Common BASCO helper directory not found:\n%s', commonFunctionsDir);

addpath(commonFunctionsDir);
addpath(genpath(localFunctionsDir));

repoRoot = find_repo_root_fc(scriptFile);
cfg = fc_basco_reappraisal_config(repoRoot);

%% Stage selection

runStage.createRegressorsV19 = false;
runStage.buildManifest = false;
runStage.prepareInput = false;
runStage.openBasco = false;          % BASCO toolbox/model-estimation stage
runStage.createBetaSeries = false;
runStage.createCorrelationMatrices = false;
runStage.validateOutputs = false;

%% Required output folders

outputDirs = {
    cfg.manifestDir
    cfg.regressorsDir
    cfg.inputDir
    cfg.toolboxOutputDir
    cfg.betaSeriesDir
    cfg.correlationMatrixDir
    cfg.roiDataDir
};

for i = 1:numel(outputDirs)
    if ~isfolder(outputDirs{i})
        mkdir(outputDirs{i});
    end
end

%% 1. Create the primary BASCO v19 trial-wise regressors

if runStage.createRegressorsV19
    create_regressors_basco_v19_reappraisal(cfg);
end

%% 2. Build portable subject manifest
%
% Replaces the historical filelist_ICON_reappraisal_jr.mat.

if runStage.buildManifest
    manifest = build_fc_subject_manifest_reappraisal(cfg);
else
    manifest = load_existing_manifest(cfg);
end

%% 3. Prepare BASCO input folders

if runStage.prepareInput

    assert_manifest_complete(manifest);

    prepare_basco_input_reappraisal(manifest, cfg);
end

%% 4. Run BASCO
%
% This stage remains interactive until the exact historical
% anadef_reappraisal.m is supplied and its BASCO invocation is verified.

if runStage.openBasco

    setup_basco_dependencies(cfg);

    assert(isfile(cfg.model.anadefFile), ...
        ['Missing BASCO analysis definition:\n%s\n\n' ...
         'Copy the historical anadef_reappraisal.m into model/.'], ...
        cfg.model.anadefFile ...
    );

    metainfoFile = fullfile( ...
        cfg.inputDir, ...
        sprintf('metainfo_%s.mat', cfg.version.basco) ...
    );

    assert(isfile(metainfoFile), ...
        'BASCO metainfo file not found:\n%s', metainfoFile);

    fprintf('\nOpening BASCO with manuscript configuration.\n');
    fprintf('Input root:          %s\n', cfg.inputDir);
    fprintf('Analysis definition: %s\n', cfg.model.anadefFile);
    fprintf('Metainfo:            %s\n', metainfoFile);
    fprintf('Expected output:     %s\n\n', cfg.basco.anaobjFile);

    BASCO;
end

%% 5. Convert BASCO beta images into primary trial beta series

if runStage.createBetaSeries

    setup_spm_and_hrf(cfg);

    assert_manifest_complete(manifest);

    create_betaseries_basco_reappraisal(manifest, cfg);
end

%% 6. Create the 10 primary 52 × 52 Pearson FC matrices

if runStage.createCorrelationMatrices

    setup_spm_only(cfg);

    assert_manifest_complete(manifest);

    create_correlation_matrices_basco_reappraisal(manifest, cfg);
end

%% 7. Validate primary FC products

if runStage.validateOutputs

    assert_manifest_complete(manifest);

    validate_primary_fc_outputs(manifest, cfg);
end

fprintf('\nReappraisal BASCO FC pipeline finished.\n');


%% Local functions

function manifest = load_existing_manifest(cfg)

if isfile(cfg.subjectManifestMat)

    loaded = load(cfg.subjectManifestMat, 'manifest');

    assert(isfield(loaded, 'manifest'), ...
        'Variable "manifest" missing in:\n%s', cfg.subjectManifestMat);

    manifest = loaded.manifest;

elseif isfile(cfg.subjectManifestCsv)

    manifest = readtable( ...
        cfg.subjectManifestCsv, ...
        'TextType', ...
        'string' ...
    );

else

    manifest = table();

    fprintf([ ...
        '\nNo FC subject manifest exists yet.\n' ...
        'Set runStage.buildManifest = true first.\n\n' ...
    ]);
end

end


function assert_manifest_complete(manifest)

assert(~isempty(manifest) && height(manifest) > 0, ...
    'FC subject manifest has not been created.');

requiredFlags = {
    'Has_EPI'
    'Has_Protocol'
    'Has_Nuisance'
    'Has_v19_Regressors'
};

assert(all(ismember(requiredFlags, manifest.Properties.VariableNames)), ...
    'FC manifest is missing completeness flags.');

complete = ...
    manifest.Has_EPI & ...
    manifest.Has_Protocol & ...
    manifest.Has_Nuisance & ...
    manifest.Has_v19_Regressors;

if any(~complete)

    disp(manifest(~complete, { ...
        'Subject_ID', ...
        'Has_EPI', ...
        'Has_Protocol', ...
        'Has_Nuisance', ...
        'Has_v19_Regressors' ...
    }));

    error('FC subject manifest is incomplete.');
end

end


function setup_basco_dependencies(cfg)

setup_spm_and_hrf(cfg);

assert(isfolder(cfg.toolboxes.basco), ...
    'Repository-local BASCO toolbox not found:\n%s', cfg.toolboxes.basco);

addpath(genpath(cfg.toolboxes.basco));

marsbarDir = cfg.toolboxes.marsbar;

if isempty(marsbarDir)
    candidate = fullfile(cfg.toolboxes.basco, 'marsbar');

    if isfolder(candidate)
        marsbarDir = candidate;
    end
end

if ~isempty(marsbarDir) && isfolder(marsbarDir)
    addpath(genpath(marsbarDir));
else
    warning([ ...
        'MarsBaR was not resolved. If BASCO requires a separate MarsBaR ' ...
        'installation, set environment variable MARSBAR_DIR.' ...
    ]);
end

assert(exist('BASCO', 'file') == 2, ...
    'BASCO entry point was not found after adding the BASCO toolbox.');

end


function setup_spm_and_hrf(cfg)

setup_spm_only(cfg);

assert(isfolder(cfg.hrf.dir), ...
    'Mouse HRF directory not found:\n%s', cfg.hrf.dir);

% Add only the selected mouse HRF directory, not every HRF implementation.
addpath(genpath(cfg.hrf.dir));

end


function setup_spm_only(cfg)

if isempty(which('spm'))

    if ~isempty(cfg.toolboxes.spm12) && isfolder(cfg.toolboxes.spm12)
        addpath(cfg.toolboxes.spm12);
    end
end

assert(~isempty(which('spm')), ...
    ['Official SPM12 was not found. Add it to the MATLAB path or set ' ...
     'SPM12_DIR.']);

spm('defaults', 'fmri');

end
