
%% main_glm_hrf_mask.m
%
% First-level HRF-cohort odor GLM used to create the individual odor masks
% for subsequent HRF fitting.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
glmDir = fileparts(scriptDir);
fmriAnalysisDir = fileparts(glmDir);

commonFunctions = fullfile(glmDir,'common','functions');
localFunctions = fullfile(scriptDir,'functions');

addpath(commonFunctions);
addpath(genpath(localFunctions));

repoRoot = find_repo_root_analysis(scriptFile);
cfg = glm_hrf_config(repoRoot);

assert(isfile(cfg.fileList), ...
    'HRF file list not found:\n%s',cfg.fileList);

assert(isfolder(cfg.processedProtocolDir), ...
    'Processed HRF protocol directory not found:\n%s', ...
    cfg.processedProtocolDir);

assert(isfile(cfg.explicitMask), ...
    ['HRF explicit mask not found:\n%s\n' ...
     'Place the small DARTEL mask under data/reference/templates/fMRI/hrf/.'], ...
    cfg.explicitMask);

assert(isfile(fullfile(cfg.initialHrfDir,'spm_hrf.m')), ...
    ['Initial 2-s HRF implementation not found:\n%s\n' ...
     'If the exact historical hrf_new folder is available, point ' ...
     'cfg.initialHrfDir to it.'],cfg.initialHrfDir);

for d = {cfg.glmRoot,cfg.firstLevelDir,cfg.regressorDir,cfg.covariateDir}
    if ~isfolder(d{1}); mkdir(d{1}); end
end

F = load(cfg.fileList,'Pfunc','Pfunc_subjName');

assert(numel(F.Pfunc)==cfg.nSessions, ...
    'Expected %d HRF sessions, found %d.',cfg.nSessions,numel(F.Pfunc));

% Temporarily put only the initial custom HRF folder at the front of path.
oldPath = path;
cleanupPath = onCleanup(@() restore_path(oldPath)); %#ok<NASGU>
addpath(cfg.initialHrfDir,'-begin');
clear spm_hrf

activeHrf = which('spm_hrf');
assert(startsWith(activeHrf,cfg.initialHrfDir), ...
    'The intended initial HRF is not first on the MATLAB path.');

for s = 1:cfg.nSessions

    epiFile = F.Pfunc{s};
    subjectName = F.Pfunc_subjName{s};

    [epiDir,epiName,~] = fileparts(epiFile);
    sessionID = epiName(1:min(11,numel(epiName)));

    fprintf('HRF mask GLM: %s (%d/%d)\n',sessionID,s,cfg.nSessions);

    protocolFile = find_hrf_protocol_file( ...
        cfg.processedProtocolDir,subjectName,epiFile);

    P = load(protocolFile,'events');
    assert(isfield(P,'events'),'Processed protocol lacks events: %s',protocolFile);

    regressors = create_regressors_hrf_v1(P.events,cfg.odorDelaySec);

    regFile = fullfile( ...
        cfg.regressorDir, ...
        sprintf('%s_v1.mat',sessionID));

    save(regFile,'regressors');

    nuisanceSource = fullfile(epiDir,'regressors_motcsf_der.txt');

    [R,names] = create_covariates_hrf_v1(nuisanceSource);

    covFile = fullfile( ...
        cfg.covariateDir, ...
        sprintf('%s_v1.mat',sessionID));

    save(covFile,'R','names');

    primaryEpi = fullfile( ...
        epiDir, ...
        [cfg.epiPrefix epiName cfg.epiSuffix '.nii']);

    assert(isfile(primaryEpi),'Primary HRF EPI missing:\n%s',primaryEpi);

    scans = expand_4d_nifti(primaryEpi);

    firstLevelDir = fullfile(cfg.firstLevelDir,sessionID);

    run_firstlevel_hrf_mask_glm( ...
        scans, ...
        regressors, ...
        covFile, ...
        cfg.explicitMask, ...
        cfg, ...
        firstLevelDir ...
    );

    create_individual_odor_mask(firstLevelDir,sessionID,cfg);
end

fprintf('\nHRF odor-mask GLM completed.\n');

function restore_path(oldPath)
path(oldPath);
clear spm_hrf
end
