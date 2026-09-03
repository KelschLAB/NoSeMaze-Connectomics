
%% main_extract_hrf_timecourses.m
%
% Extract session-specific residual BOLD time courses from the individual
% odor masks used for HRF fitting.

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
F = load(cfg.fileList,'Pfunc');

if ~isfolder(cfg.timecourseDir)
    mkdir(cfg.timecourseDir);
end

for s = 1:numel(F.Pfunc)

    [~,epiName,~] = fileparts(F.Pfunc{s});
    sessionID = epiName(1:min(11,numel(epiName)));

    maskFile = fullfile( ...
        cfg.maskFirstLevelDir, ...
        sessionID, ...
        sprintf('%s_odormask_%s.nii',sessionID,cfg.maskLabel));

    residualFile = fullfile( ...
        cfg.residualFirstLevelDir, ...
        sessionID, ...
        sprintf('4D_residuals_%s.nii',sessionID));

    assert(isfile(maskFile),'Individual HRF odor mask missing:\n%s',maskFile);
    assert(isfile(residualFile),'4-D HRF residual file missing:\n%s',residualFile);

    sessionOut = fullfile(cfg.timecourseDir,sessionID);
    if ~isfolder(sessionOut); mkdir(sessionOut); end

    outputFile = fullfile( ...
        sessionOut, ...
        sprintf('%s_odormask_%s_roidata.mat',sessionID,cfg.maskLabel));

    extract_roi_timecourse(maskFile,residualFile,outputFile);
end

fprintf('\nHRF residual time-course extraction completed.\n');
