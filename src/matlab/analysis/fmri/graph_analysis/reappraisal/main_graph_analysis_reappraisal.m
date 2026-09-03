%% main_graph_analysis_reappraisal.m
%
% Primary graph-theoretical analysis for the reappraisal cohort.
%
% Input: BASCO v11 subject-level 52 x 52 correlation matrices.
%
% Historical primary settings:
%   - merged left/right atlas (52 nodes)
%   - diagonal removed
%   - positive correlations only
%   - density thresholds 0.10:0.01:0.50
%   - normalization method 'max'
%   - manuscript metrics only: SWP, delta_C, delta_L, local strength, local clustering
%   - AUC over all 41 thresholds

clearvars;
close all;
clc;

%% Locate repository

scriptFile = mfilename('fullpath');
if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);
graphRoot = fileparts(scriptDir);

commonFunctionsDir = fullfile(graphRoot,'common','functions');
localFunctionsDir = fullfile(scriptDir,'functions');

addpath(commonFunctionsDir);
addpath(genpath(localFunctionsDir));

repoRoot = find_repo_root_graph(scriptFile);
cfg = graph_reappraisal_config(repoRoot);

%% Dependencies

if isfolder(cfg.bctDir)
    addpath(genpath(cfg.bctDir));
else
    error('Brain Connectivity Toolbox not found:\n%s',cfg.bctDir);
end

missingProjectFunctions = cfg.requiredProjectFunctions( ...
    cellfun(@(name) isempty(which(name)),cfg.requiredProjectFunctions));

if ~isempty(missingProjectFunctions)
    error(['Required historical graph functions are missing:\n%s\n\n' ...
        'Place them under:\n%s'], ...
        strjoin(missingProjectFunctions,newline),commonFunctionsDir);
end

%% Output folders

outputDirs = {
    cfg.preparedCormatDir
    cfg.gstrucDir
    cfg.aucDir
    cfg.manifestDir
};

for i=1:numel(outputDirs)
    if ~isfolder(outputDirs{i})
        mkdir(outputDirs{i});
    end
end

%% Stage selection

runStage.preparePositiveNetworks = false;
runStage.computeThresholdMetrics = false;
runStage.computeAUC = false;

%% Analyze explicit matrix names, not dir() row numbers

manifestRows = cell(numel(cfg.matrixSuffixes),7);

for matrixIndex=1:numel(cfg.matrixSuffixes)

    suffix = cfg.matrixSuffixes{matrixIndex};

    fprintf('\nGraph analysis: %s\n',suffix);

    cormatFile = resolve_graph_cormat_file(cfg,suffix);
    data = load_and_validate_cormat_set(cormatFile,cfg);

    preparedFile = fullfile(cfg.preparedCormatDir, ...
        sprintf('cormat_%s_%s_p.mat',cfg.cormatVersion,suffix));

    gstrucFile = fullfile(cfg.gstrucDir, ...
        sprintf('gstruc_%s_p.mat',suffix));

    aucFile = fullfile(cfg.aucDir, ...
        sprintf('auc_struc_%s_45to50_p.mat',suffix));

    if runStage.preparePositiveNetworks
        prepared = prepare_positive_cormats_reappraisal(data,cfg,suffix);
    elseif isfile(preparedFile)
        L = load(preparedFile,'cormat','subjectIDs','names');
        prepared = struct();
        prepared.cormat = L.cormat;
        prepared.subjectIDs = data.subjectIDs;
        prepared.names = data.names;
        if isfield(L,'subjectIDs'); prepared.subjectIDs = L.subjectIDs; end
        if isfield(L,'names'); prepared.names = L.names; end
        prepared.outputFile = preparedFile;
    else
        prepared = struct();
    end

    if runStage.computeThresholdMetrics
        assert(~isempty(fieldnames(prepared)), ...
            'Run preparePositiveNetworks first for %s.',suffix);

        gstrucFile = run_graph_threshold_analysis_reappraisal( ...
            prepared,cfg,suffix);
    end

    if runStage.computeAUC
        assert(isfile(gstrucFile), ...
            'Run computeThresholdMetrics first for %s.',suffix);

        aucFile = compute_graph_auc_reappraisal( ...
            gstrucFile,cfg,suffix);
    end

    manifestRows(matrixIndex,:) = {
        suffix
        cormatFile
        preparedFile
        gstrucFile
        aucFile
        numel(data.cormat)
        cfg.expectedROIcount
    };
end

write_graph_analysis_manifest(manifestRows,cfg);

fprintf('\nReappraisal graph-analysis pipeline finished.\n');
