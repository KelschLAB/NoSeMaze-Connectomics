%% main_preprocessing_nosemaze_tubetest.m
%
% NoSeMaze tube-test preprocessing:
%
% 1. combined CSV -> daily LOG files
% 2. LOG files -> competition extraction + QC plots + daily Data.mat
% 3. manual event curation
% 4. curated daily Data.mat -> full_hierarchy_jr.mat
%
% Hierarchy calculation runs afterwards from ../hierarchy/.
%
% Raw data are not distributed publicly.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
preprocessingRoot = fileparts(fileparts(scriptDir));

addpath(scriptDir);
addpath(fullfile(scriptDir,'functions'));
addpath(fullfile(preprocessingRoot,'helpers'));

repoRoot = find_repo_root(scriptFile);
groups = nosemaze_tubetest_config(repoRoot);

%% Select stages

% First pass:
runStage.convertCsvToLog = true;
runStage.findAndPlotEvents = true;
runStage.combineCuratedData = false;

% Second pass after manual curation:
% runStage.convertCsvToLog = false;
% runStage.findAndPlotEvents = false;
% runStage.combineCuratedData = true;

overwriteExisting = false;
validateAgainstExisting = true;

%% Process both NoSeMaze cohorts

for groupIndex = 1:numel(groups)

    cfg = groups(groupIndex);

    fprintf('\n============================================================\n');
    fprintf('%s\n',cfg.name);
    fprintf('============================================================\n');

    if ~isfolder(cfg.logDir); mkdir(cfg.logDir); end
    if ~isfolder(cfg.eventPlotDir); mkdir(cfg.eventPlotDir); end
    if ~isfolder(cfg.processedDir); mkdir(cfg.processedDir); end

    %% 1. Combined CSV -> daily LOG files

    if runStage.convertCsvToLog
        fprintf('\n[1] CSV -> daily LOG files\n');
        convert_csv_to_LOG(cfg.rawCsvPath,cfg.logDir,overwriteExisting);
    end

    %% 2. Extract competitions and generate QC plots

    if runStage.findAndPlotEvents
        fprintf('\n[2] Extract and plot daily tube competitions\n');
        find_and_plot_tube_events(cfg.logDir,cfg.eventPlotDir,overwriteExisting);
    end

    %% 3. MANUAL CURATION
    %
    % Inspect:
    %   data/interim/NoSeMaze/<group>/tube/LOG-files/plots/LOG_*/
    %
    % Then place optional files directly under the plots folder:
    %   include_events.mat   variable include
    %   exclude_events.mat   variable exclude
    %   invert_events.mat    variable invert

    %% 4. Combine curated days

    if runStage.combineCuratedData

        fprintf('\n[4] Combine manually curated daily data\n');

        switch cfg.name
            case 'NoSeMaze_1'
                full_hierarchy = combine_curated_data_NoSeMaze_1(cfg.eventPlotDir);
            case 'NoSeMaze_2'
                full_hierarchy = combine_curated_data_NoSeMaze_2(cfg.eventPlotDir);
            otherwise
                error('Unknown cohort: %s',cfg.name);
        end

        outputExists = isfile(cfg.fullHierarchyFile);

        if outputExists && validateAgainstExisting
            validate_full_hierarchy(full_hierarchy,cfg.fullHierarchyFile);
        end

        if outputExists && ~overwriteExisting
            fprintf(['Existing final file retained:\n%s\n' ...
                'Set overwriteExisting=true to replace it.\n'],cfg.fullHierarchyFile);
        else
            save(cfg.fullHierarchyFile,'full_hierarchy','-v7.3');
            fprintf('Saved final hierarchy:\n%s\n',cfg.fullHierarchyFile);
        end
    end
end

fprintf('\nTube-test preprocessing completed.\n');
