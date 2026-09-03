
%% main_residual_glm_hrf.m
%
% Nuisance-only residual GLM for HRF estimation.
%
% Uses the primary HRF-cohort EPI and the same v1 14-column nuisance model.
% No task regressors are entered. Residuals are written explicitly and
% concatenated into a 4-D NIfTI for ROI extraction.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
fmriAnalysisDir = fileparts(scriptDir);

addpath(genpath(fullfile(scriptDir,'functions')));
addpath(fullfile(fmriAnalysisDir,'glm','common','functions'));

repoRoot = find_repo_root_analysis(scriptFile);
cfg = hrf_estimation_config(repoRoot);

assert(isfile(cfg.fileList),'HRF file list missing:\n%s',cfg.fileList);
assert(isfile(cfg.explicitMask),'HRF explicit mask missing:\n%s',cfg.explicitMask);

F = load(cfg.fileList,'Pfunc');

assert(numel(F.Pfunc)==cfg.nSessions, ...
    'Expected %d HRF sessions.',cfg.nSessions);

if ~isfolder(cfg.residualFirstLevelDir)
    mkdir(cfg.residualFirstLevelDir);
end

for s = 1:cfg.nSessions

    epiFile = F.Pfunc{s};
    [epiDir,epiName,~] = fileparts(epiFile);
    sessionID = epiName(1:min(11,numel(epiName)));

    primaryEpi = fullfile( ...
        epiDir, ...
        [cfg.primaryEpiPrefix epiName cfg.primaryEpiSuffix '.nii']);

    assert(isfile(primaryEpi),'Primary HRF EPI missing:\n%s',primaryEpi);

    covFile = fullfile(cfg.covariateDir,[sessionID '_v1.mat']);
    assert(isfile(covFile), ...
        ['HRF v1 covariate file not found:\n%s\n' ...
         'Run main_glm_hrf_mask.m first.'],covFile);

    scans = expand_4d_nifti(primaryEpi);

    sessionDir = fullfile(cfg.residualFirstLevelDir,sessionID);

    run_residual_glm_hrf( ...
        scans,covFile,cfg.explicitMask,cfg,sessionDir);

    merge_residuals_hrf(sessionDir,false);
end

fprintf('\nHRF residual GLMs and 4-D residual files completed.\n');
