%% main_glm_reappraisal.m
%
% Primary voxelwise GLM pipeline for the reappraisal/conditioning cohort.
%
% Confirmed primary settings:
%   regressor model = v22
%   smoothing       = 0.6 mm (s6)
%   nuisance model  = v1 (14 nuisance covariates)
%
% The s4 / 0.4-mm branch is a robustness analysis and is not run here.

clearvars;
close all;
clc;

%% Locate analysis folders

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);        % .../glm/reappraisal
glmRoot = fileparts(scriptDir);           % .../glm

commonFunctionsDir = fullfile(glmRoot, 'common', 'functions');
localFunctionsDir = fullfile(scriptDir, 'functions');

if ~isfolder(commonFunctionsDir)
    error('Common GLM functions folder not found:\n%s', commonFunctionsDir);
end

addpath(genpath(commonFunctionsDir));
addpath(genpath(localFunctionsDir));

repoRoot = find_repo_root_analysis(scriptFile);
cfg = glm_reappraisal_config(repoRoot);

%% External dependency: SPM12

if isempty(which('spm'))
    error('SPM12 was not found on the MATLAB path.');
end

%% Required functions

requiredFunctions = {
    'create_regressors_reappraisal_v22'
    'create_covariates_reappraisal'
    'run_firstlevel_reappraisal'
    'do_firstlevel_jr'
    'do_secondlevel_jr'
};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)), requiredFunctions) ...
);

if ~isempty(missingFunctions)
    fprintf('Missing GLM functions:\n');
    fprintf('  %s.m\n', missingFunctions{:});
    error('GLM function set is incomplete.');
end

%% Output directories

requiredDirs = {
    cfg.regressorsDir
    cfg.covariatesDir
    cfg.resultsDir
    cfg.firstLevelDir
    cfg.secondLevelDir
};

for dirIndex = 1:numel(requiredDirs)
    if ~isfolder(requiredDirs{dirIndex})
        mkdir(requiredDirs{dirIndex});
    end
end

%% Stage selection
%
% The primary v22 regressor definition is now fully specified.

runStage.createRegressors = false;
runStage.createCovariates = false;
runStage.firstLevel = false;
runStage.secondLevel = false;

%% 1. Create primary v22 task regressors

if runStage.createRegressors
    create_regressors_reappraisal_v22(cfg);
end

%% 2. Create 14 nuisance covariates

if runStage.createCovariates
    create_covariates_reappraisal(cfg);
end

%% 3. First-level GLM

if runStage.firstLevel
    run_firstlevel_reappraisal(cfg);
end

%% 4. General one-sample second-level models

if runStage.secondLevel

    contrastInfoFile = fullfile( ...
        cfg.firstLevelDir, ...
        'contrast_info.mat' ...
    );

    if ~isfile(contrastInfoFile)
        error('contrast_info.mat not found:\n%s', contrastInfoFile);
    end

    loaded = load(contrastInfoFile, 'contrast_info');

    do_secondlevel_jr( ...
        cfg.secondLevelDir, ...
        loaded.contrast_info, ...
        cfg.firstLevelDir, ...
        cfg.explicitMask ...
    );
end

fprintf('\nPrimary reappraisal GLM pipeline finished.\n');
