%% main_glm_control.m
% Primary control-cohort voxelwise GLM.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
controlDir = fileparts(scriptFile);
glmRoot = fileparts(controlDir);
commonFunctions = fullfile(glmRoot,'common','functions');
localFunctions = fullfile(controlDir,'functions');

addpath(commonFunctions);
addpath(localFunctions);

repoRoot = find_repo_root_analysis(scriptFile);
cfg = glm_control_config(repoRoot);

spm12Dir = getenv('SPM12_DIR');
if isempty(spm12Dir) || ~isfolder(spm12Dir)
    error('Set SPM12_DIR to the official SPM12 installation.');
end
addpath(spm12Dir);

hrfDir = fullfile(repoRoot,'src','matlab','preprocessing','toolboxes', ...
    'spm12_animal','longTC','hrf_withoutOnset_from2sHRF-GLM');
if isfolder(hrfDir); addpath(hrfDir); end

runStage.createRegressors = false;
runStage.buildEpiManifest = false;
runStage.createCovariates = false;
runStage.firstLevel = false;
runStage.secondLevel = false;

if runStage.createRegressors
    create_regressors_control_v22(cfg);
end

epiManifestFile = fullfile(cfg.resultsDir,'control_epi_manifest.mat');

if runStage.buildEpiManifest
    if ~isfolder(cfg.resultsDir); mkdir(cfg.resultsDir); end
    epiManifest = build_control_epi_manifest(cfg);
    save(epiManifestFile,'epiManifest');
else
    if isfile(epiManifestFile)
        load(epiManifestFile,'epiManifest');
    else
        epiManifest = build_control_epi_manifest(cfg);
    end
end

if runStage.createCovariates
    create_covariates_control_v1(cfg,epiManifest);
end

if runStage.firstLevel
    run_firstlevel_control(cfg,epiManifest);
end

if runStage.secondLevel
    firstlevelDir = fullfile(cfg.resultsDir,'firstlevel');
    contrastInfoFile = fullfile(cfg.resultsDir,'contrast_info.mat');
    load(contrastInfoFile,'contrast_info');

    outputDirSecond = fullfile(cfg.resultsDir,'secondlevel');
    do_secondlevel_jr( ...
        outputDirSecond, contrast_info, firstlevelDir, cfg.explicitMask);
end
