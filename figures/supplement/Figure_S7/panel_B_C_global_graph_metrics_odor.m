% panel_B_C_global_graph_metrics_odor.m
% Jonathan Reinwald
%
% Supplementary Figure S7B-C at the distal CR (odor onset).
%
% Figure S7B: Delta C (g_delta_C)
% Figure S7C: Delta L (g_delta_L)
%
% Internal FDR metric only:
%   Small-world propensity (g_swp)
%
% PRE  = Odor trials 11-40
% TEST = Odor trials 81-120
%
% Plotted comparisons:
%   1. Conditioning PRE vs TEST
%   2. TEST-PRE change: conditioning vs control
%
% Statistics:
%   paired t-test + permutation_test_paired
%   unpaired t-test + permutation_test_unpaired
%   10,000 permutations, seed 1234
%
% Benjamini-Hochberg FDR is performed across the three predefined global
% metrics (Delta C, Delta L, SWP), separately for each comparison family.
%
% IMPORTANT:
% SWP is included in metricInfo below but plotPanel = false. This is
% necessary so the FDR family truly contains three metrics.

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
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Paths

srcDir = fullfile(repoRoot,'src','matlab');

inputBaseDir = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_S7','Figure_S7B_C' ...
);

inputDirTask = fullfile(inputBaseDir,'conditioning');
inputDirControl = fullfile(inputBaseDir,'control');

summaryOutputDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S7' ...
);

%% Dependencies

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = { ...
    'notBoxPlot_modified', ...
    'permutation_test_paired', ...
    'permutation_test_unpaired', ...
    'sigstar' ...
};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error('Required MATLAB helper functions not found:\n%s', ...
        strjoin(missingFunctions,newline));
end

if isempty(ver('stats'))
    error('Statistics and Machine Learning Toolbox is required for ttest/ttest2.');
end

%% Settings

preName = 'Odor11to40';
testName = 'Odor81to120';

thresholdDisplayMin = 45;
thresholdDisplayMax = 50;

numberOfPermutations = 10000;
randomSeed = 1234;
fdrAlpha = 0.05;

%% Input files

taskPreFile = fullfile(inputDirTask, ...
    sprintf('auc_struc_%s_%dto%d_p.mat', ...
    preName,thresholdDisplayMin,thresholdDisplayMax));

taskTestFile = fullfile(inputDirTask, ...
    sprintf('auc_struc_%s_%dto%d_p.mat', ...
    testName,thresholdDisplayMin,thresholdDisplayMax));

controlPreFile = fullfile(inputDirControl, ...
    sprintf('auc_struc_%s_%dto%d_p.mat', ...
    preName,thresholdDisplayMin,thresholdDisplayMax));

controlTestFile = fullfile(inputDirControl, ...
    sprintf('auc_struc_%s_%dto%d_p.mat', ...
    testName,thresholdDisplayMin,thresholdDisplayMax));

requiredFiles = {taskPreFile,taskTestFile,controlPreFile,controlTestFile};
missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error('Required AUC files are missing:\n%s', ...
        strjoin(missingFiles,newline));
end

%% Load

taskPreLoaded = load(taskPreFile);
taskTestLoaded = load(taskTestFile);
controlPreLoaded = load(controlPreFile);
controlTestLoaded = load(controlTestFile);

loadedData = { ...
    taskPreLoaded,taskTestLoaded,controlPreLoaded,controlTestLoaded ...
};

loadedNames = { ...
    taskPreFile,taskTestFile,controlPreFile,controlTestFile ...
};

for fileIndex = 1:numel(loadedData)
    if ~isfield(loadedData{fileIndex},'auc_struc')
        error('Variable "auc_struc" missing from:\n%s', ...
            loadedNames{fileIndex});
    end
end

aucTaskPre = taskPreLoaded.auc_struc;
aucTaskTest = taskTestLoaded.auc_struc;
aucControlPre = controlPreLoaded.auc_struc;
aucControlTest = controlTestLoaded.auc_struc;

%% Three predefined global metrics

metricInfo = struct([]);

metricInfo(1).panel = 'Figure_S7B';
metricInfo(1).shortName = 'deltaC';
metricInfo(1).displayName = '\DeltaC';
metricInfo(1).fieldName = 'g_delta_C';
metricInfo(1).plotPanel = true;

metricInfo(2).panel = 'Figure_S7C';
metricInfo(2).shortName = 'deltaL';
metricInfo(2).displayName = '\DeltaL';
metricInfo(2).fieldName = 'g_delta_L';
metricInfo(2).plotPanel = true;

% Internal metric for FDR only.
metricInfo(3).panel = '';
metricInfo(3).shortName = 'SWP';
metricInfo(3).displayName = 'SWP';
metricInfo(3).fieldName = 'g_swp';
metricInfo(3).plotPanel = false;

for metricIndex = 1:numel(metricInfo)

    fieldName = metricInfo(metricIndex).fieldName;

    fieldExistsEverywhere = ...
        isfield(aucTaskPre,fieldName) && ...
        isfield(aucTaskTest,fieldName) && ...
        isfield(aucControlPre,fieldName) && ...
        isfield(aucControlTest,fieldName);

    if ~fieldExistsEverywhere
        error([ ...
            'Required global metric field "%s" is not present in all ' ...
            'four AUC input structures.' ...
        ],fieldName);
    end

    fprintf('%s uses field: %s\n', ...
        metricInfo(metricIndex).shortName,fieldName);
end

%% Statistics

numberOfMetrics = numel(metricInfo);

results = struct([]);
permutationPTask = nan(numberOfMetrics,1);
permutationPDiff = nan(numberOfMetrics,1);

for metricIndex = 1:numberOfMetrics

    fieldName = metricInfo(metricIndex).fieldName;

    preTask = getMetricVector(aucTaskPre,fieldName);
    testTask = getMetricVector(aucTaskTest,fieldName);
    preControl = getMetricVector(aucControlPre,fieldName);
    testControl = getMetricVector(aucControlTest,fieldName);

    if numel(preTask) ~= numel(testTask)
        error('%s: conditioning PRE and TEST sample sizes differ.',fieldName);
    end

    if numel(preControl) ~= numel(testControl)
        error('%s: control PRE and TEST sample sizes differ.',fieldName);
    end

    diffTask = testTask - preTask;
    diffControl = testControl - preControl;

    [hTask,pTask,~,statsTask] = ttest(preTask,testTask);
    [hDiff,pDiff,~,statsDiff] = ttest2(diffTask,diffControl);

    rng(randomSeed,'twister');
    [~,~,pValuesTask] = permutation_test_paired( ...
        preTask,testTask,numberOfPermutations,'mean');

    rng(randomSeed,'twister');
    [~,~,pValuesDiff] = permutation_test_unpaired( ...
        diffTask,diffControl,numberOfPermutations,'mean');

    permutationPTask(metricIndex) = getScalarPermutationP(pValuesTask);
    permutationPDiff(metricIndex) = getScalarPermutationP(pValuesDiff);

    results(metricIndex).panel = metricInfo(metricIndex).panel;
    results(metricIndex).shortName = metricInfo(metricIndex).shortName;
    results(metricIndex).displayName = metricInfo(metricIndex).displayName;
    results(metricIndex).fieldName = fieldName;

    results(metricIndex).preTask = preTask;
    results(metricIndex).testTask = testTask;
    results(metricIndex).preControl = preControl;
    results(metricIndex).testControl = testControl;
    results(metricIndex).diffTask = diffTask;
    results(metricIndex).diffControl = diffControl;

    results(metricIndex).parametric.task.h = hTask;
    results(metricIndex).parametric.task.p = pTask;
    results(metricIndex).parametric.task.stats = statsTask;

    results(metricIndex).parametric.diff.h = hDiff;
    results(metricIndex).parametric.diff.p = pDiff;
    results(metricIndex).parametric.diff.stats = statsDiff;

    results(metricIndex).permutation.task.pValues = pValuesTask;
    results(metricIndex).permutation.task.p = permutationPTask(metricIndex);

    results(metricIndex).permutation.diff.pValues = pValuesDiff;
    results(metricIndex).permutation.diff.p = permutationPDiff(metricIndex);
end

%% FDR across Delta C / Delta L / SWP

[qTask,fdrSigTask] = bhFdrAdjustedP(permutationPTask,fdrAlpha);
[qDiff,fdrSigDiff] = bhFdrAdjustedP(permutationPDiff,fdrAlpha);

%% Generate S7B and S7C

for metricIndex = 1:numberOfMetrics

    if ~metricInfo(metricIndex).plotPanel
        continue;
    end

    panelName = metricInfo(metricIndex).panel;
    metricShortName = metricInfo(metricIndex).shortName;
    metricDisplayName = metricInfo(metricIndex).displayName;
    fieldName = metricInfo(metricIndex).fieldName;

    preTask = results(metricIndex).preTask;
    testTask = results(metricIndex).testTask;
    preControl = results(metricIndex).preControl;
    testControl = results(metricIndex).testControl;
    diffTask = results(metricIndex).diffTask;
    diffControl = results(metricIndex).diffControl;

    outputDir = fullfile( ...
        repoRoot,'results','supplement','Figure_S7',panelName ...
    );

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    fig = figure( ...
        'Name',sprintf('%s: %s',panelName,metricShortName), ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,100,850,450] ...
    );

    %% Conditioning PRE vs TEST

    ax1 = subplot(1,2,1);
    bb1 = notBoxPlot_modified([preTask,testTask]);

    formatNotBoxPlotPair(bb1,'pretest');
    formatAxis(ax1,{'Pre','Test'},'conditioning');

    addPermutationAnnotation( ...
        ax1,permutationPTask(metricIndex),fdrSigTask(metricIndex));

    if permutationPTask(metricIndex) < 0.05
        sigstar({[1,2]},permutationPTask(metricIndex),0,30);
    end

    %% TEST-PRE change between cohorts

    ax2 = subplot(1,2,2);
    bb2 = notBoxPlot_modified([diffTask,diffControl]);

    formatNotBoxPlotPair(bb2,'cohortdiff');
    formatAxis(ax2,{'conditioning','control'},'TEST - PRE');

    addPermutationAnnotation( ...
        ax2,permutationPDiff(metricIndex),fdrSigDiff(metricIndex));

    if permutationPDiff(metricIndex) < 0.05
        sigstar({[1,2]},permutationPDiff(metricIndex),0,30);
    end

    sgtitle(sprintf('%s | %s | %s', ...
        panelName,metricDisplayName,fieldName), ...
        'Interpreter','none');

    %% Source data

    maxN = max([ ...
        numel(preTask),numel(testTask), ...
        numel(preControl),numel(testControl), ...
        numel(diffTask),numel(diffControl) ...
    ]);

    sourceData = table( ...
        padVector(preTask,maxN), ...
        padVector(testTask,maxN), ...
        padVector(preControl,maxN), ...
        padVector(testControl,maxN), ...
        padVector(diffTask,maxN), ...
        padVector(diffControl,maxN), ...
        'VariableNames',{ ...
            'Pre_Conditioning','Test_Conditioning', ...
            'Pre_Control','Test_Control', ...
            'Delta_Conditioning','Delta_Control' ...
        } ...
    );

    writetable(sourceData, ...
        fullfile(outputDir,sprintf( ...
        'SourceData_%s_%s.csv',panelName,metricShortName)));

    %% Statistics

    comparison = { ...
        'Conditioning_PRE_vs_TEST'; ...
        'Delta_Conditioning_vs_Control' ...
    };

    statisticsTable = table( ...
        comparison, ...
        [results(metricIndex).parametric.task.p; ...
         results(metricIndex).parametric.diff.p], ...
        [permutationPTask(metricIndex);permutationPDiff(metricIndex)], ...
        [qTask(metricIndex);qDiff(metricIndex)], ...
        [fdrSigTask(metricIndex);fdrSigDiff(metricIndex)], ...
        repmat(numberOfPermutations,2,1), ...
        repmat(randomSeed,2,1), ...
        'VariableNames',{ ...
            'Comparison','Parametric_P','Permutation_P_Raw', ...
            'Permutation_FDR_Q','FDR_Significant', ...
            'NumberOfPermutations','RandomSeed' ...
        } ...
    );

    writetable(statisticsTable, ...
        fullfile(outputDir,sprintf( ...
        'Statistics_%s_%s.csv',panelName,metricShortName)));

    %% Metadata/results

    metadata = table( ...
        string(panelName), ...
        string(metricShortName), ...
        string(metricDisplayName), ...
        string(fieldName), ...
        thresholdDisplayMin, ...
        thresholdDisplayMax, ...
        numberOfPermutations, ...
        randomSeed, ...
        fdrAlpha, ...
        string(taskPreFile), ...
        string(taskTestFile), ...
        string(controlPreFile), ...
        string(controlTestFile), ...
        'VariableNames',{ ...
            'Panel','Metric','DisplayName','AUC_Structure_Field', ...
            'ThresholdPercentMin','ThresholdPercentMax', ...
            'NumberOfPermutations','RandomSeed','FDR_Alpha', ...
            'Conditioning_Pre_File','Conditioning_Test_File', ...
            'Control_Pre_File','Control_Test_File' ...
        } ...
    );

    writetable(metadata, ...
        fullfile(outputDir,sprintf( ...
        'AnalysisMetadata_%s_%s.csv',panelName,metricShortName)));

    currentResult = results(metricIndex);

    currentResult.fdr.task.q = qTask(metricIndex);
    currentResult.fdr.task.significant = fdrSigTask(metricIndex);

    currentResult.fdr.diff.q = qDiff(metricIndex);
    currentResult.fdr.diff.significant = fdrSigDiff(metricIndex);

    save(fullfile(outputDir,sprintf( ...
        'Results_%s_%s.mat',panelName,metricShortName)), ...
        'currentResult');

    if ~isempty(which('docDataSrc'))
        try
            docDataSrc(fig,outputDir,scriptFile,true);
        catch documentationError
            warning('docDataSrc failed: %s',documentationError.message);
        end
    end

    exportgraphics(fig, ...
        fullfile(outputDir,sprintf('%s_%s.pdf',panelName,metricShortName)), ...
        'ContentType','vector','BackgroundColor','white');

    exportgraphics(fig, ...
        fullfile(outputDir,sprintf('%s_%s.png',panelName,metricShortName)), ...
        'Resolution',300,'BackgroundColor','white');
end

%% Combined FDR summary including SWP

if ~isfolder(summaryOutputDir)
    mkdir(summaryOutputDir);
end

summaryMetric = string({metricInfo.shortName})';
summaryField = string({metricInfo.fieldName})';

fdrSummary = table( ...
    summaryMetric, ...
    summaryField, ...
    permutationPTask, ...
    qTask, ...
    fdrSigTask, ...
    permutationPDiff, ...
    qDiff, ...
    fdrSigDiff, ...
    'VariableNames',{ ...
        'Metric', ...
        'AUC_Structure_Field', ...
        'Conditioning_P_Raw', ...
        'Conditioning_FDR_Q', ...
        'Conditioning_FDR_Significant', ...
        'DeltaBetweenCohorts_P_Raw', ...
        'DeltaBetweenCohorts_FDR_Q', ...
        'DeltaBetweenCohorts_FDR_Significant' ...
    } ...
);

writetable(fdrSummary, ...
    fullfile(summaryOutputDir, ...
    'Figure_S7B_C_GlobalMetrics_FDR_Summary.csv'));

save(fullfile(summaryOutputDir, ...
    'Figure_S7B_C_GlobalMetrics_complete_results.mat'), ...
    'results','metricInfo','fdrSummary');

fprintf('\nCompleted Figure S7B-C analysis.\n');
fprintf('FDR family: Delta C, Delta L, SWP.\n');
fprintf('Outputs saved under:\n%s\n',summaryOutputDir);

%% Local functions

function values = getMetricVector(aucStructure,fieldName)

    if ~isfield(aucStructure,fieldName)
        error('Metric field "%s" does not exist in auc_struc.',fieldName);
    end

    values = [aucStructure.(fieldName)];
    values = values(:);

    if ~isnumeric(values)
        error('Metric field "%s" is not numeric.',fieldName);
    end

    if any(~isfinite(values))
        warning('Metric field "%s" contains NaN/Inf values.',fieldName);
    end
end

function p = getScalarPermutationP(pValues)

    if isempty(pValues)
        p = NaN;
        return;
    end

    pValues = pValues(:);

    if numel(pValues) > 1
        warning([ ...
            'Permutation test returned %d p-values for a scalar metric. ' ...
            'Using the smallest p-value.' ...
        ],numel(pValues));
    end

    p = min(pValues);
end

function [qValues,significant] = bhFdrAdjustedP(pValues,alpha)

    pValues = pValues(:);
    qValues = nan(size(pValues));
    significant = false(size(pValues));

    finiteMask = isfinite(pValues);

    if ~any(finiteMask)
        return;
    end

    pFinite = pValues(finiteMask);
    [sortedP,sortIndex] = sort(pFinite);
    m = numel(sortedP);

    adjustedSorted = sortedP .* m ./ (1:m)';

    for index = m-1:-1:1
        adjustedSorted(index) = min( ...
            adjustedSorted(index),adjustedSorted(index+1));
    end

    adjustedSorted = min(adjustedSorted,1);

    adjustedFinite = nan(m,1);
    adjustedFinite(sortIndex) = adjustedSorted;

    qValues(finiteMask) = adjustedFinite;
    significant(finiteMask) = adjustedFinite <= alpha;
end

function formatNotBoxPlotPair(bb,plotType)

    for index = 1:numel(bb)
        bb(index).data.MarkerSize = 8;
        bb(index).data.MarkerEdgeColor = 'none';
        bb(index).semPtch.EdgeColor = 'none';
        bb(index).sdPtch.EdgeColor = 'none';
    end

    if strcmp(plotType,'pretest')

        bb(1).data.MarkerFaceColor = [204/255 51/255 204/255];
        bb(1).mu.Color = [204/255 51/255 204/255];
        bb(1).semPtch.FaceColor = [221/255 118/255 221/255];
        bb(1).sdPtch.FaceColor = [247/255 221/255 247/255];

        bb(2).data.MarkerFaceColor = [0 160/255 227/255];
        bb(2).mu.Color = [0 160/255 227/255];
        bb(2).semPtch.FaceColor = [90/255 194/255 237/255];
        bb(2).sdPtch.FaceColor = [211/255 239/255 250/255];

    elseif strcmp(plotType,'cohortdiff')

        bb(1).data.MarkerFaceColor = [0/255 83/255 83/255];
        bb(1).mu.Color = [0/255 83/255 83/255];
        bb(1).semPtch.FaceColor = [104/255 154/255 154/255];
        bb(1).sdPtch.FaceColor = [209/255 224/255 224/255];

        bb(2).data.MarkerFaceColor = [122/255 46/255 84/255];
        bb(2).mu.Color = [122/255 46/255 84/255];
        bb(2).semPtch.FaceColor = [182/255 140/255 161/255];
        bb(2).sdPtch.FaceColor = [222/255 202/255 213/255];

    else
        error('Unknown plot type: %s',plotType);
    end
end

function formatAxis(ax,xLabels,titleText)

    box(ax,'off');
    ax.XLim = [0.5 2.5];
    ax.XTick = [1 2];
    ax.XTickLabel = xLabels;
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ax.LineWidth = 2.5;

    ylabel(ax,'A.U.');
    title(ax,titleText,'Interpreter','none');
end

function addPermutationAnnotation(ax,pValue,fdrSignificant)

    if fdrSignificant
        label = sprintf('p_{perm} = %.5g  \\dagger',pValue);
    else
        label = sprintf('p_{perm} = %.5g',pValue);
    end

    text( ...
        ax, ...
        ax.XLim(1)+0.08*diff(ax.XLim), ...
        ax.YLim(1)+0.18*diff(ax.YLim), ...
        label, ...
        'Interpreter','tex', ...
        'FontSize',10 ...
    );
end

function padded = padVector(values,targetLength)

    values = values(:);
    padded = nan(targetLength,1);
    padded(1:numel(values)) = values;
end
