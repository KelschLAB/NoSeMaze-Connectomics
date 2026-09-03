% figure_S6_global_metrics_thresholds.m
% Jonathan Reinwald
%
% Repository-adapted threshold-robustness analysis for Supplementary
% Figure S6.
%
% Figure S6A: Delta L (g_delta_L)
% Figure S6B: Delta C (g_delta_C)
% Figure S6C: Small-world propensity (g_swp)
%
% For each metric, three plots are generated across network sparsities
% 10-50% in 1% steps:
%
%   left:
%       conditioning PRE / TEST + control PRE / TEST
%       inference shown only for conditioning PRE vs TEST
%
%   middle:
%       TEST-PRE change in conditioning and control cohorts
%       inference: conditioning change vs control change
%
%   right:
%       Pearson correlation between conditioning TEST-PRE change
%       and social rank
%
% Statistical tests:
%   - conditioning PRE vs TEST:
%         permutation_test_paired(..., 10000, 'mean')
%         (replaces historical threshold-wise permutest)
%   - conditioning vs control TEST-PRE:
%         permutation_test_unpaired(..., 10000, 'mean')
%         (replaces historical threshold-wise permutationTest)
%   - rank association:
%         Pearson correlation, as in the historical script
%
% Threshold-wise p-values are shown without additional correction,
% reproducing the logic of the historical Figure S6 analysis.
%
% Significance display reproduces the original stacked-marker convention:
%   # p < .10, * p < .05, ** p < .01, *** p < .001,
% with the stars for ** and *** drawn on separate vertical rows.
%
% Expected repository structure:
%
% NoSeMaze-Connectomics/
% ├── figures/supplement/Figure_S6/
% │   └── figure_S6_global_metrics_thresholds.m
% │
% ├── data/processed/fMRI/Figure_4/
% │   ├── conditioning/
% │   │   ├── gstruc_TPnoPuff11to40_p.mat
% │   │   └── gstruc_TPnoPuff81to120_p.mat
% │   └── control/
% │       ├── gstruc_TPnoPuff11to40_p.mat
% │       └── gstruc_TPnoPuff81to120_p.mat
% │
% ├── data/processed/NoSeMaze/
% │   ├── 01_General_Overview.xlsx
% │   ├── AnimalNumb_to_ID.mat
% │   └── tubetest/
% │       ├── NoSeMaze_1/
% │       │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │       │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │       └── NoSeMaze_2/
% │           └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │
% ├── src/matlab/
% │   ├── shadedErrorBar.m
% │   ├── permutation_test_paired.m
% │   ├── permutation_test_unpaired.m
% │   └── docDataSrc.m                    (optional)
% │
% └── results/supplement/Figure_S6/
%     ├── Figure_S6A/
%     ├── Figure_S6B/
%     └── Figure_S6C/
%
% -------------------------------------------------------------------------

clear;
close all;
clc;

%% Locate repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error([ ...
        'MATLAB could not determine the script location. ' ...
        'Run the complete saved script rather than selected lines.' ...
    ]);
end

scriptDir = fileparts(scriptFile);

% repo/figures/supplement/Figure_S6/figure_S6_global_metrics_thresholds.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative directories

srcDir = fullfile(repoRoot, 'src', 'matlab');

graphBaseDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'Figure_4' ...
);

taskDir = fullfile(graphBaseDir, 'conditioning');
controlDir = fullfile(graphBaseDir, 'control');

noSeMazeDir = fullfile( ...
    repoRoot, 'data', 'processed', 'NoSeMaze' ...
);

overviewFile = fullfile( ...
    noSeMazeDir, '01_General_Overview.xlsx' ...
);

animalMapFile = fullfile( ...
    noSeMazeDir, 'AnimalNumb_to_ID.mat' ...
);

am1EarlyFile = fullfile( ...
    noSeMazeDir, 'tubetest', 'NoSeMaze_1', ...
    'DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

am1LateFile = fullfile( ...
    noSeMazeDir, 'tubetest', 'NoSeMaze_1', ...
    'DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

am2File = fullfile( ...
    noSeMazeDir, 'tubetest', 'NoSeMaze_2', ...
    'DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

resultsBaseDir = fullfile( ...
    repoRoot, 'results', 'supplement', 'Figure_S6' ...
);

%% Add helpers

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {
    'shadedErrorBar'
    'permutation_test_paired'
    'permutation_test_unpaired'
};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)), requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error([ ...
        'Required MATLAB helper functions not found:\n%s\n\n' ...
        'Place them somewhere under src/matlab/.' ...
    ], strjoin(missingFunctions, newline));
end

if isempty(ver('stats'))
    error('Statistics and Machine Learning Toolbox is required for corr.');
end

%% Analysis settings

preName = 'TPnoPuff11to40';
testName = 'TPnoPuff81to120';

thresholdPercent = (10:50)';
numberOfThresholds = numel(thresholdPercent);

numberOfPermutations = 10000;
permutationSeed = 1234;

%% Input graph files

taskPreFile = fullfile(taskDir, sprintf('gstruc_%s_p.mat', preName));
taskTestFile = fullfile(taskDir, sprintf('gstruc_%s_p.mat', testName));
controlPreFile = fullfile(controlDir, sprintf('gstruc_%s_p.mat', preName));
controlTestFile = fullfile(controlDir, sprintf('gstruc_%s_p.mat', testName));

requiredFiles = {
    taskPreFile
    taskTestFile
    controlPreFile
    controlTestFile
    overviewFile
    animalMapFile
    am1EarlyFile
    am1LateFile
    am2File
};

missingFiles = requiredFiles(~cellfun(@isfile, requiredFiles));

if ~isempty(missingFiles)
    error('Required input files are missing:\n\n%s', strjoin(missingFiles, newline));
end

%% Load graph structures

taskPreLoaded = load(taskPreFile, 'gstruc');
taskTestLoaded = load(taskTestFile, 'gstruc');
controlPreLoaded = load(controlPreFile, 'gstruc');
controlTestLoaded = load(controlTestFile, 'gstruc');

loadedGraphData = {
    taskPreLoaded
    taskTestLoaded
    controlPreLoaded
    controlTestLoaded
};

loadedGraphFiles = {
    taskPreFile
    taskTestFile
    controlPreFile
    controlTestFile
};

for fileIndex = 1:numel(loadedGraphData)
    if ~isfield(loadedGraphData{fileIndex}, 'gstruc')
        error('Variable "gstruc" missing from:\n%s', loadedGraphFiles{fileIndex});
    end
end

gTaskPre = taskPreLoaded.gstruc;
gTaskTest = taskTestLoaded.gstruc;
gControlPre = controlPreLoaded.gstruc;
gControlTest = controlTestLoaded.gstruc;

%% Select historical plotted threshold range
%
% The original script used only gstruc rows 1:41 and displayed these as
% sparsity thresholds 10-50%. The underlying gstruc files can contain
% additional thresholds (e.g. 61 rows, corresponding to 10-70%).
%
% Therefore, retain only the first 41 rows for Figure S6.

thresholdRowIndices = 1:numberOfThresholds;

graphStructures = {
    gTaskPre
    gTaskTest
    gControlPre
    gControlTest
};

graphStructureNames = {
    'conditioning PRE'
    'conditioning TEST'
    'control PRE'
    'control TEST'
};

for structureIndex = 1:numel(graphStructures)

    numberOfAvailableThresholds = size(graphStructures{structureIndex}, 1);

    if numberOfAvailableThresholds < numberOfThresholds
        error( ...
            ['%s contains only %d threshold rows, but Figure S6 ' ...
             'requires at least %d rows (10-50%%).'], ...
            graphStructureNames{structureIndex}, ...
            numberOfAvailableThresholds, ...
            numberOfThresholds ...
        );
    end
end

gTaskPre = gTaskPre(thresholdRowIndices, :);
gTaskTest = gTaskTest(thresholdRowIndices, :);
gControlPre = gControlPre(thresholdRowIndices, :);
gControlTest = gControlTest(thresholdRowIndices, :);

%% Build social-rank vector in MRI animal order

socialRank = loadSocialRankVector( ...
    overviewFile, ...
    animalMapFile, ...
    am1EarlyFile, ...
    am1LateFile, ...
    am2File ...
);

nTask = size(gTaskPre, 2);
nControl = size(gControlPre, 2);

if numel(socialRank) ~= nTask
    error( ...
        'Social-rank vector has %d animals, graph data contain %d.', ...
        numel(socialRank), nTask ...
    );
end

%% Define Figure S6 panels

metricInfo = struct([]);

metricInfo(1).panel = 'Figure_S6A';
metricInfo(1).shortName = 'deltaL';
metricInfo(1).displayName = '\DeltaL';
metricInfo(1).fieldName = 'g_delta_L';

metricInfo(2).panel = 'Figure_S6B';
metricInfo(2).shortName = 'deltaC';
metricInfo(2).displayName = '\DeltaC';
metricInfo(2).fieldName = 'g_delta_C';

metricInfo(3).panel = 'Figure_S6C';
metricInfo(3).shortName = 'SWP';
metricInfo(3).displayName = 'SWP';
metricInfo(3).fieldName = 'g_swp';

%% Process panels

allResults = struct([]);

for metricIndex = 1:numel(metricInfo)

    panelName = metricInfo(metricIndex).panel;
    shortName = metricInfo(metricIndex).shortName;
    displayName = metricInfo(metricIndex).displayName;
    fieldName = metricInfo(metricIndex).fieldName;

    taskPre = extractMetricMatrix(gTaskPre, fieldName);
    taskTest = extractMetricMatrix(gTaskTest, fieldName);
    controlPre = extractMetricMatrix(gControlPre, fieldName);
    controlTest = extractMetricMatrix(gControlTest, fieldName);

    taskDelta = taskTest - taskPre;
    controlDelta = controlTest - controlPre;

    pConditioning = nan(numberOfThresholds, 1);
    pDeltaBetweenCohorts = nan(numberOfThresholds, 1);
    rhoRank = nan(numberOfThresholds, 1);
    pRank = nan(numberOfThresholds, 1);

    for thresholdIndex = 1:numberOfThresholds

        rng(permutationSeed + thresholdIndex - 1, 'twister');

        [~, ~, pConditioning(thresholdIndex)] = ...
            permutation_test_paired( ...
                taskTest(thresholdIndex, :)', ...
                taskPre(thresholdIndex, :)', ...
                numberOfPermutations, ...
                'mean' ...
            );

        rng(permutationSeed + 1000 + thresholdIndex - 1, 'twister');

        [~, ~, pDeltaBetweenCohorts(thresholdIndex)] = ...
            permutation_test_unpaired( ...
                taskDelta(thresholdIndex, :)', ...
                controlDelta(thresholdIndex, :)', ...
                numberOfPermutations, ...
                'mean' ...
            );

        [rhoRank(thresholdIndex), pRank(thresholdIndex)] = corr( ...
            taskDelta(thresholdIndex, :)', ...
            socialRank, ...
            'Type', 'Pearson', ...
            'Rows', 'complete' ...
        );
    end

    outputDir = fullfile(resultsBaseDir, panelName);

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    fig = figure( ...
        'Name', sprintf('%s: %s', panelName, shortName), ...
        'Visible', 'on', ...
        'Color', 'white', ...
        'Position', [100, 100, 1350, 430] ...
    );

    axesHandles = gobjects(1, 3);

    %% Left: PRE/TEST trajectories

    axesHandles(1) = subplot(1, 3, 1);
    hold(axesHandles(1), 'on');

    hControlTest = shadedErrorBar( ...
        thresholdPercent, ...
        mean(controlTest, 2, 'omitnan'), ...
        semAcrossSubjects(controlTest) ...
    );

    hControlPre = shadedErrorBar( ...
        thresholdPercent, ...
        mean(controlPre, 2, 'omitnan'), ...
        semAcrossSubjects(controlPre) ...
    );

    hTaskTest = shadedErrorBar( ...
        thresholdPercent, ...
        mean(taskTest, 2, 'omitnan'), ...
        semAcrossSubjects(taskTest) ...
    );

    hTaskPre = shadedErrorBar( ...
        thresholdPercent, ...
        mean(taskPre, 2, 'omitnan'), ...
        semAcrossSubjects(taskPre) ...
    );

    formatShadedLine(hControlTest, [0 160/255 227/255] .* 0.5, '--');
    formatShadedLine(hControlPre, [204/255 51/255 204/255] .* 0.5, '--');
    formatShadedLine(hTaskTest, [0 160/255 227/255], '-');
    formatShadedLine(hTaskPre, [204/255 51/255 204/255], '-');

    formatThresholdAxis(axesHandles(1));
    axesHandles(1).YLabel.String = 'A.U.';
    axesHandles(1).YLim = [0 1];

    title(axesHandles(1), 'PRE / TEST', 'Interpreter', 'none');

    markThresholdSignificance( ...
        axesHandles(1), thresholdPercent, pConditioning ...
    );

    legend( ...
        axesHandles(1), ...
        [ ...
            hControlTest.mainLine, ...
            hControlPre.mainLine, ...
            hTaskTest.mainLine, ...
            hTaskPre.mainLine ...
        ], ...
        { ...
            'control: test', ...
            'control: pre', ...
            'conditioning: test', ...
            'conditioning: pre' ...
        }, ...
        'Location', 'north', ...
        'Box', 'off' ...
    );

    %% Middle: TEST-PRE conditioning vs control

    axesHandles(2) = subplot(1, 3, 2);
    hold(axesHandles(2), 'on');

    hControlDelta = shadedErrorBar( ...
        thresholdPercent, ...
        mean(controlDelta, 2, 'omitnan'), ...
        semAcrossSubjects(controlDelta) ...
    );

    hTaskDelta = shadedErrorBar( ...
        thresholdPercent, ...
        mean(taskDelta, 2, 'omitnan'), ...
        semAcrossSubjects(taskDelta) ...
    );

    formatShadedLine(hControlDelta, [75/255 75/255 75/255], '-');
    formatShadedLine(hTaskDelta, [0 128/255 128/255], '-');

    formatThresholdAxis(axesHandles(2));
    axesHandles(2).YLabel.String = 'TEST - PRE [A.U.]';

    title(axesHandles(2), 'TEST - PRE', 'Interpreter', 'none');

    markThresholdSignificance( ...
        axesHandles(2), thresholdPercent, pDeltaBetweenCohorts ...
    );

    legend( ...
        axesHandles(2), ...
        [hControlDelta.mainLine, hTaskDelta.mainLine], ...
        {'control', 'conditioning'}, ...
        'Location', 'north', ...
        'Box', 'off' ...
    );

    %% Right: correlation with social rank

    axesHandles(3) = subplot(1, 3, 3);

    plot( ...
        axesHandles(3), ...
        thresholdPercent, ...
        rhoRank, ...
        'LineWidth', 2 ...
    );

    formatThresholdAxis(axesHandles(3));
    axesHandles(3).YLim = [-0.7 0.7];
    axesHandles(3).YLabel.String = 'Pearson''s r';

    title( ...
        axesHandles(3), ...
        'conditioning change vs rank', ...
        'Interpreter', ...
        'none' ...
    );

    markThresholdSignificance( ...
        axesHandles(3), thresholdPercent, pRank ...
    );

    sgtitle( ...
        sprintf('%s | %s | %s', ...
            panelName, displayName, fieldName), ...
        'Interpreter', 'none' ...
    );

    %% Save source data

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_conditioning_PRE.csv', ...
                panelName, shortName)), ...
        thresholdPercent, taskPre ...
    );

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_conditioning_TEST.csv', ...
                panelName, shortName)), ...
        thresholdPercent, taskTest ...
    );

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_control_PRE.csv', ...
                panelName, shortName)), ...
        thresholdPercent, controlPre ...
    );

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_control_TEST.csv', ...
                panelName, shortName)), ...
        thresholdPercent, controlTest ...
    );

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_conditioning_DELTA.csv', ...
                panelName, shortName)), ...
        thresholdPercent, taskDelta ...
    );

    writeThresholdMatrix( ...
        fullfile(outputDir, ...
            sprintf('SourceData_%s_%s_control_DELTA.csv', ...
                panelName, shortName)), ...
        thresholdPercent, controlDelta ...
    );

    %% Save statistics

    statisticsTable = table( ...
        thresholdPercent, ...
        pConditioning, ...
        pDeltaBetweenCohorts, ...
        rhoRank, ...
        pRank, ...
        'VariableNames', { ...
            'SparsityPercent'
            'PermutationP_Conditioning_PRE_vs_TEST'
            'PermutationP_Delta_Conditioning_vs_Control'
            'PearsonR_DeltaConditioning_vs_Rank'
            'PearsonP_DeltaConditioning_vs_Rank'
        } ...
    );

    writetable( ...
        statisticsTable, ...
        fullfile(outputDir, ...
            sprintf('Statistics_%s_%s_thresholds.csv', ...
                panelName, shortName)) ...
    );

    %% Save metadata

    metadata = table( ...
        string(panelName), ...
        string(shortName), ...
        string(fieldName), ...
        min(thresholdPercent), ...
        max(thresholdPercent), ...
        string(sprintf('%d:%d', thresholdRowIndices(1), thresholdRowIndices(end))), ...
        numberOfPermutations, ...
        permutationSeed, ...
        nTask, ...
        nControl, ...
        string(taskPreFile), ...
        string(taskTestFile), ...
        string(controlPreFile), ...
        string(controlTestFile), ...
        string(overviewFile), ...
        string(animalMapFile), ...
        'VariableNames', { ...
            'Panel'
            'Metric'
            'GraphField'
            'MinSparsityPercent'
            'MaxSparsityPercent'
            'SelectedGstrucRows'
            'NumberOfPermutations'
            'PermutationSeedBase'
            'N_Conditioning'
            'N_Control'
            'Conditioning_PRE_File'
            'Conditioning_TEST_File'
            'Control_PRE_File'
            'Control_TEST_File'
            'GeneralOverview_File'
            'AnimalMap_File'
        } ...
    );

    writetable( ...
        metadata, ...
        fullfile(outputDir, ...
            sprintf('AnalysisMetadata_%s_%s.csv', ...
                panelName, shortName)) ...
    );

    %% Save complete results

    currentResult = struct();

    currentResult.panel = panelName;
    currentResult.metric = shortName;
    currentResult.fieldName = fieldName;
    currentResult.thresholdPercent = thresholdPercent;

    currentResult.taskPre = taskPre;
    currentResult.taskTest = taskTest;
    currentResult.controlPre = controlPre;
    currentResult.controlTest = controlTest;
    currentResult.taskDelta = taskDelta;
    currentResult.controlDelta = controlDelta;

    currentResult.socialRank = socialRank;

    currentResult.pConditioning = pConditioning;
    currentResult.pDeltaBetweenCohorts = pDeltaBetweenCohorts;
    currentResult.rhoRank = rhoRank;
    currentResult.pRank = pRank;

    currentResult.numberOfPermutations = numberOfPermutations;
    currentResult.permutationSeed = permutationSeed;

    save( ...
        fullfile(outputDir, ...
            sprintf('Results_%s_%s.mat', ...
                panelName, shortName)), ...
        'currentResult' ...
    );

    %% Optional source-script documentation

    if ~isempty(which('docDataSrc'))
        try
            docDataSrc(fig, outputDir, scriptFile, true);
        catch documentationError
            warning('docDataSrc failed: %s', documentationError.message);
        end
    end

    %% Export

    exportgraphics( ...
        fig, ...
        fullfile(outputDir, ...
            sprintf('%s_%s_thresholds.pdf', ...
                panelName, shortName)), ...
        'ContentType', 'vector', ...
        'BackgroundColor', 'white' ...
    );

    exportgraphics( ...
        fig, ...
        fullfile(outputDir, ...
            sprintf('%s_%s_thresholds.png', ...
                panelName, shortName)), ...
        'Resolution', 300, ...
        'BackgroundColor', 'white' ...
    );

    savefig( ...
        fig, ...
        fullfile(outputDir, ...
            sprintf('%s_%s_thresholds.fig', ...
                panelName, shortName)) ...
    );

    allResults(metricIndex).panel = panelName;
    allResults(metricIndex).metric = shortName;
    allResults(metricIndex).fieldName = fieldName;
    allResults(metricIndex).statistics = statisticsTable;
end

%% Combined result

save( ...
    fullfile(resultsBaseDir, 'Figure_S6_complete_results.mat'), ...
    'allResults', ...
    'metricInfo', ...
    'thresholdPercent', ...
    'socialRank' ...
);

fprintf('\nCompleted Supplementary Figure S6 analysis.\n');
fprintf('Outputs saved under:\n%s\n', resultsBaseDir);


%% ========================================================================
% Local functions
%% ========================================================================

function values = extractMetricMatrix(gstruc, fieldName)

    if ~isfield(gstruc, fieldName)
        error('Graph metric field "%s" is missing from gstruc.', fieldName);
    end

    numberOfThresholds = size(gstruc, 1);
    numberOfAnimals = size(gstruc, 2);

    values = nan(numberOfThresholds, numberOfAnimals);

    for thresholdIndex = 1:numberOfThresholds
        for animalIndex = 1:numberOfAnimals

            currentValue = ...
                gstruc(thresholdIndex, animalIndex).(fieldName);

            if ~isnumeric(currentValue) || numel(currentValue) ~= 1
                error( ...
                    'Expected scalar numeric %s at threshold %d, animal %d.', ...
                    fieldName, thresholdIndex, animalIndex ...
                );
            end

            values(thresholdIndex, animalIndex) = currentValue;
        end
    end
end


function semValues = semAcrossSubjects(values)

    n = sum(isfinite(values), 2);

    semValues = std(values, 0, 2, 'omitnan') ./ sqrt(n);
    semValues(n < 2) = NaN;
end


function formatShadedLine(handle, lineColor, lineStyle)

    handle.mainLine.Color = lineColor;
    handle.mainLine.LineStyle = lineStyle;
    handle.mainLine.LineWidth = 2;

    handle.patch.FaceColor = lineColor;
    handle.patch.FaceAlpha = 0.18;

    if isfield(handle, 'edge') && ~isempty(handle.edge)
        for edgeIndex = 1:numel(handle.edge)
            handle.edge(edgeIndex).Color = 'none';
        end
    end
end


function formatThresholdAxis(ax)

    box(ax, 'off');

    ax.XLim = [10 50];
    ax.XTick = 10:5:50;
    ax.XLabel.String = 'Sparsity threshold (%)';

    ax.FontSize = 10;
    ax.LineWidth = 1.5;
end


function markThresholdSignificance(ax, xValues, pValues)
% Reproduce the historical S6 significance display:
%
%   p < .10   #
%   p < .05   *
%   p < .01   two vertically stacked stars
%   p < .001  three vertically stacked stars
%
% The stars are deliberately placed on separate vertical rows, matching
% the appearance of the original Supplementary Figure S6.

    yLimits = ax.YLim;
    yRange = diff(yLimits);

    yTop = yLimits(1) + 0.96 * yRange;
    yMiddle = yLimits(1) + 0.91 * yRange;
    yBottom = yLimits(1) + 0.86 * yRange;

    for index = 1:numel(pValues)

        p = pValues(index);

        if ~isfinite(p)
            continue;
        end

        xPosition = xValues(index);

        if p < 0.001

            addSignificanceMarker(ax, xPosition, yTop, '*');
            addSignificanceMarker(ax, xPosition, yMiddle, '*');
            addSignificanceMarker(ax, xPosition, yBottom, '*');

        elseif p < 0.01

            addSignificanceMarker(ax, xPosition, yTop, '*');
            addSignificanceMarker(ax, xPosition, yMiddle, '*');

        elseif p < 0.05

            addSignificanceMarker(ax, xPosition, yTop, '*');

        elseif p < 0.1

            addSignificanceMarker(ax, xPosition, yTop, '#');
        end
    end
end


function addSignificanceMarker(ax, xPosition, yPosition, marker)

    text( ...
        ax, ...
        xPosition, ...
        yPosition, ...
        marker, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'Interpreter', 'none', ...
        'Clipping', 'on' ...
    );
end


function writeThresholdMatrix(fileName, thresholdPercent, values)

    numberOfAnimals = size(values, 2);
    variableNames = cell(1, numberOfAnimals);

    for animalIndex = 1:numberOfAnimals
        variableNames{animalIndex} = sprintf('Animal_%02d', animalIndex);
    end

    T = array2table(values, 'VariableNames', variableNames);

    T = addvars( ...
        T, ...
        thresholdPercent, ...
        'Before', 1, ...
        'NewVariableNames', 'SparsityPercent' ...
    );

    writetable(T, fileName);
end


function socialRank = loadSocialRankVector( ...
    overviewFile, ...
    animalMapFile, ...
    am1EarlyFile, ...
    am1LateFile, ...
    am2File ...
)

    T = readtable( ...
        overviewFile, ...
        'Sheet', 9, ...
        'ReadVariableNames', true ...
    );

    tmp = load(am1EarlyFile, 'DS_info');
    AM1early = prepareHierarchy(tmp.DS_info);

    tmp = load(am1LateFile, 'DS_info');
    AM1late = prepareHierarchy(tmp.DS_info);

    tmp = load(am2File, 'DS_info');
    AM2 = prepareHierarchy(tmp.DS_info);

    animalIDs = strings(0, 1);
    rankValues = nan(0, 1);

    for rowIndex = 1:height(T)

        autonomouse = getNumericScalar(T.Autonomouse(rowIndex));

        if ~ismember(autonomouse, [1 2])
            continue;
        end

        currentID = normalizeAnimalID( ...
            getTableValue(T.AnimalIDCombined, rowIndex) ...
        );

        if autonomouse == 1

            daysValue = normalizeText( ...
                getTableValue(T.DaysToConsider, rowIndex) ...
            );

            if contains(daysValue, '16')
                hierarchy = AM1early;
            elseif contains(daysValue, '21')
                hierarchy = AM1late;
            else
                error( ...
                    'Could not assign hierarchy window for AM1 animal %s.', ...
                    currentID ...
                );
            end

        else
            hierarchy = AM2;
        end

        hierarchyIndex = find(hierarchy.ID == currentID);

        if numel(hierarchyIndex) ~= 1
            error( ...
                'Animal ID %s could not be matched uniquely.', ...
                currentID ...
            );
        end

        animalIDs(end+1, 1) = currentID; %#ok<AGROW>
        rankValues(end+1, 1) = hierarchy.Rank(hierarchyIndex); %#ok<AGROW>
    end

    mapLoaded = load(animalMapFile);

    if ~isfield(mapLoaded, 'AnimalNumb_to_ID')
        error('AnimalNumb_to_ID missing from:\n%s', animalMapFile);
    end

    animalMap = mapLoaded.AnimalNumb_to_ID;

    mapIDs = strings(numel(animalMap), 1);

    for mapIndex = 1:numel(animalMap)
        mapIDs(mapIndex) = normalizeAnimalID(animalMap(mapIndex).ID);
    end

    animalNumbers = nan(numel(animalIDs), 1);

    for animalIndex = 1:numel(animalIDs)

        matches = find(mapIDs == animalIDs(animalIndex));

        if isempty(matches)
            error( ...
                'Animal ID %s not found in AnimalNumb_to_ID.', ...
                animalIDs(animalIndex) ...
            );
        end

        mappedNumbers = nan(numel(matches), 1);

        for matchIndex = 1:numel(matches)
            mappedNumbers(matchIndex) = getNumericScalar( ...
                animalMap(matches(matchIndex)).AnimalNumb ...
            );
        end

        mappedNumbers = unique(mappedNumbers);

        if numel(mappedNumbers) ~= 1
            error( ...
                'Animal ID %s maps to multiple AnimalNumb values.', ...
                animalIDs(animalIndex) ...
            );
        end

        animalNumbers(animalIndex) = mappedNumbers;
    end

    [~, sortIndex] = sort(animalNumbers);

    socialRank = rankValues(sortIndex);
    socialRank = socialRank(:);
end


function hierarchy = prepareHierarchy(rawHierarchy)

    if numel(rawHierarchy) == 1

        if ~isfield(rawHierarchy, 'ID') || ~isfield(rawHierarchy, 'DS')
            error('DS_info must contain ID and DS.');
        end

        hierarchy.ID = normalizeIDVector(rawHierarchy.ID);
        hierarchy.DS = rawHierarchy.DS(:);

    else

        if ~isfield(rawHierarchy, 'ID') || ~isfield(rawHierarchy, 'DS')
            error('DS_info must contain ID and DS.');
        end

        hierarchy.ID = strings(numel(rawHierarchy), 1);
        hierarchy.DS = nan(numel(rawHierarchy), 1);

        for index = 1:numel(rawHierarchy)
            hierarchy.ID(index) = normalizeAnimalID(rawHierarchy(index).ID);
            hierarchy.DS(index) = getNumericScalar(rawHierarchy(index).DS);
        end
    end

    [~, descendingIndex] = sort(hierarchy.DS, 'descend');

    hierarchy.Rank = nan(numel(hierarchy.DS), 1);
    hierarchy.Rank(descendingIndex) = (1:numel(descendingIndex))';
end


function ids = normalizeIDVector(rawIDs)

    if iscell(rawIDs)

        ids = strings(numel(rawIDs), 1);

        for index = 1:numel(rawIDs)
            ids(index) = normalizeAnimalID(rawIDs{index});
        end

    elseif isstring(rawIDs)

        ids = upper(strtrim(rawIDs(:)));

    elseif ischar(rawIDs)

        if size(rawIDs, 1) > 1
            ids = upper(strtrim(string(cellstr(rawIDs))));
        else
            ids = normalizeAnimalID(rawIDs);
        end

        ids = ids(:);

    else

        ids = upper(strtrim(string(rawIDs(:))));
    end
end


function value = getTableValue(variable, rowIndex)

    if iscell(variable)
        value = variable{rowIndex};
    else
        value = variable(rowIndex);
    end
end


function id = normalizeAnimalID(value)

    if iscell(value)
        value = value{1};
    end

    id = upper(strtrim(string(value)));
end


function value = normalizeText(rawValue)

    if iscell(rawValue)
        rawValue = rawValue{1};
    end

    value = string(rawValue);
end


function value = getNumericScalar(rawValue)

    if iscell(rawValue)
        rawValue = rawValue{1};
    end

    if isnumeric(rawValue)

        if numel(rawValue) ~= 1
            error('Expected one numeric scalar.');
        end

        value = double(rawValue);

    else

        value = str2double(string(rawValue));

        if ~isfinite(value)
            error('Could not convert value "%s" to numeric.', string(rawValue));
        end
    end
end
