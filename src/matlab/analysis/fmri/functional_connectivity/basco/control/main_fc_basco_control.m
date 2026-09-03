%% main_fc_basco_control.m
% Control-cohort BASCO v6 functional-connectivity pipeline.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
controlDir = fileparts(scriptFile);
bascoRoot = fileparts(controlDir);

addpath(fullfile(bascoRoot,'common','functions'));
addpath(fullfile(controlDir,'functions'));
addpath(fullfile(controlDir,'model'));

% Shared exact merged-ROI helper lives in the reappraisal functions folder.
addpath(fullfile(bascoRoot,'reappraisal','functions'));

repoRoot = find_repo_root_fc(scriptFile);
cfg = fc_basco_control_config(repoRoot);

runStage.createRegressorsV16 = false;
runStage.buildManifest = false;
runStage.prepareInput = false;
runStage.openBasco = false;
runStage.createBetaSeries = false;
runStage.createCorrelationMatrices = false;

if runStage.createRegressorsV16
    create_regressors_basco_v16_control(cfg);
end

if runStage.buildManifest
    manifest = build_fc_subject_manifest_control(cfg);
else
    if isfile(cfg.subjectManifestMat)
        load(cfg.subjectManifestMat,'manifest');
    else
        manifest = build_fc_subject_manifest_control(cfg);
    end
end

if runStage.prepareInput
    prepare_basco_input_control(manifest,cfg);
end

if runStage.openBasco
    if isfolder(cfg.toolboxes.basco)
        addpath(genpath(cfg.toolboxes.basco));
    end
    BASCO
end

if runStage.createBetaSeries
    create_betaseries_basco_control(manifest,cfg);
end

if runStage.createCorrelationMatrices
    create_correlation_matrices_basco_control(manifest,cfg);
end
