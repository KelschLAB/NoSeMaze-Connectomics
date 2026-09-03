%% main_secondlevel_social_hierarchy_reappraisal.m
%
% Second-level voxelwise regressions relating task BOLD contrasts to
% prescan NoSeMaze social-hierarchy measures.
%
% Reduced covariate set:
%   1. SocialRank
%   2. DavidScore
%   3. FractionActiveChases
%   4. FractionBeingChased
%
% Graph-derived covariates are handled separately by:
%   main_secondlevel_graph_covariates_reappraisal.m

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
glmRoot = fileparts(scriptDir);

addpath(genpath(fullfile(glmRoot, 'common', 'functions')));
addpath(genpath(fullfile(scriptDir, 'functions')));

repoRoot = find_repo_root_analysis(scriptFile);

cfg = glm_reappraisal_config(repoRoot);

if isempty(which('spm'))
    error('SPM12 is not available on the MATLAB path.');
end

if isempty(which('do_secondlevel_GLM_to_NoSeMaze_jr'))
    error([ ...
        'Missing do_secondlevel_GLM_to_NoSeMaze_jr.m. ' ...
        'Copy this helper into the GLM functions folder.' ...
    ]);
end

if ~isfile(cfg.explicitMask)
    error('Explicit analysis mask not found:\n%s', cfg.explicitMask);
end

contrastInfoFile = fullfile( ...
    cfg.firstLevelDir, ...
    'contrast_info.mat' ...
);

if ~isfile(contrastInfoFile)
    error('contrast_info.mat not found:\n%s', contrastInfoFile);
end

loadedContrast = load( ...
    contrastInfoFile, ...
    'contrast_info' ...
);

contrast_info = loadedContrast.contrast_info;

%% Build / save reduced social-hierarchy table

socialTable = build_social_hierarchy_covariates(cfg);

%% Select covariates to run

covariatesToRun = {
    'SocialRank'
    'DavidScore'
    'FractionActiveChases'
    'FractionBeingChased'
};

%% Run one second-level regression per explanatory variable

for covIndex = 1:numel(covariatesToRun)

    variableName = covariatesToRun{covIndex};

    if ~ismember(variableName, socialTable.Properties.VariableNames)
        error('Covariate "%s" not found in social table.', variableName);
    end

    values = socialTable.(variableName);

    if any(~isfinite(values))
        error( ...
            'Covariate "%s" contains non-finite values.', ...
            variableName ...
        );
    end

    ExplVar = struct();

    ExplVar.name = variableName;
    ExplVar.values = values(:);
    ExplVar.ID = cellstr(string(socialTable.RFID));
    ExplVar.AnimalNumb = socialTable.AnimalNumber(:);

    [sortedValues, sortedIndex] = sort( ...
        ExplVar.values, ...
        'descend' ...
    );

    ExplVar.DS_sorted = sortedValues;
    ExplVar.DS_sortedIndex = sortedIndex;

    outputDir = fullfile( ...
        cfg.socialHierarchyDir, ...
        variableName ...
    );

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    do_secondlevel_GLM_to_NoSeMaze_jr( ...
        outputDir, ...
        contrast_info, ...
        cfg.firstLevelDir, ...
        cfg.explicitMask, ...
        ExplVar ...
    );
end

fprintf('\nSocial-hierarchy second-level GLMs completed.\n');
