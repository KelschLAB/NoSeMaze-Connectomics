% panel_A_localGA_odor_task_vs_control.m
% Jonathan Reinwald
%
% Supplementary Figure S7A:
% regional local graph-metric changes at the distal CR (odor onset).
%
% PRE  = Odor trials 11-40
% TEST = Odor trials 81-120
%
% Metrics:
%   l_strength
%   l_cc
%
% For each ROI:
%   conditioning change = TEST - PRE
%   control change      = TEST - PRE
%
% followed by an unpaired t-test between change scores.
%
% FDR correction is performed across ROIs separately for each metric.
%
% Historical plotting convention retained:
%   plotted T = -raw T
%
% Input:
%   data/processed/fMRI/Figure_S7/Figure_S7A/
%   ├── conditioning/res_auc_struc_local.mat
%   └── control/res_auc_struc_local.mat
%
% Helpers are loaded recursively from src/matlab/.
%
% Output:
%   results/supplement/Figure_S7/Figure_S7A/

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

inputDir = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_S7','Figure_S7A' ...
);

taskFile = fullfile(inputDir,'conditioning','res_auc_struc_local.mat');
controlFile = fullfile(inputDir,'control','res_auc_struc_local.mat');

outputDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S7','Figure_S7A' ...
);

%% Dependencies

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {'FDR','vals2colormap_jr'};
missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error('Required MATLAB helper functions not found:\n%s', ...
        strjoin(missingFunctions,newline));
end

if isempty(ver('stats'))
    error('Statistics and Machine Learning Toolbox is required for ttest2/tinv.');
end

%% Settings

comparisonName = 'Odor11to40VSOdor81to120';

preName = 'Odor11to40';
testName = 'Odor81to120';

fdrAlpha = 0.05;

minThresholdIndex = 36;
maxThresholdIndex = 41;

thresholdDisplayMin = minThresholdIndex + 9;
thresholdDisplayMax = maxThresholdIndex + 9;

sorting = [ ...
    4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11, ...
    32:33,29:31,34:35,38:41,45:52,22:23,36,37,44 ...
];

localMetrics = {'l_strength','l_cc'};

%% Check inputs

if ~isfile(taskFile)
    error('Conditioning AUC result file not found:\n%s',taskFile);
end

if ~isfile(controlFile)
    error('Control AUC result file not found:\n%s',controlFile);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Load AUC structures

taskData = load(taskFile);
controlData = load(controlFile);

if ~isfield(taskData,'res_auc_struc')
    error('Variable "res_auc_struc" missing from:\n%s',taskFile);
end

if ~isfield(controlData,'res_auc_struc')
    error('Variable "res_auc_struc" missing from:\n%s',controlFile);
end

lTask = taskData.res_auc_struc;
lControl = controlData.res_auc_struc;

for metricIndex = 1:numel(localMetrics)
    metricName = localMetrics{metricIndex};

    if ~isfield(lTask,metricName) || ~isfield(lControl,metricName)
        error('Required metric "%s" is missing.',metricName);
    end
end

%% Determine canonical ROI ordering

firstMetric = localMetrics{1};

if ~isfield(lTask.(firstMetric),testName)
    error('Expected TEST field "%s" missing.',testName);
end

regionNamesUnsorted = fieldnames(lTask.(firstMetric).(testName));

if max(sorting) > numel(regionNamesUnsorted)
    error('Sorting requires at least %d ROIs; only %d found.', ...
        max(sorting),numel(regionNamesUnsorted));
end

regionNames = regionNamesUnsorted(sorting);
numberOfRegions = numel(regionNames);

%% Original colormap

colorMap = [ ...
    [linspace(0,1,128)'; linspace(255/255,122/255,128)'], ...
    [linspace(42/128,1,128)'; linspace(255/255,46/255,128)'], ...
    [linspace(42/128,1,128)'; linspace(255/255,84/255,128)'] ...
];

%% Process local metrics

for metricIndex = 1:numel(localMetrics)

    metricName = localMetrics{metricIndex};

    requiredFieldsExist = ...
        isfield(lTask.(metricName),preName) && ...
        isfield(lTask.(metricName),testName) && ...
        isfield(lControl.(metricName),preName) && ...
        isfield(lControl.(metricName),testName);

    if ~requiredFieldsExist
        error('Metric %s is missing required PRE/TEST fields.',metricName);
    end

    tValue = nan(numberOfRegions,1);
    pValue = nan(numberOfRegions,1);
    hValue = false(numberOfRegions,1);
    dfValue = nan(numberOfRegions,1);

    nTask = nan(numberOfRegions,1);
    nControl = nan(numberOfRegions,1);

    meanDeltaTask = nan(numberOfRegions,1);
    meanDeltaControl = nan(numberOfRegions,1);

    for regionIndex = 1:numberOfRegions

        regionName = regionNames{regionIndex};

        taskDiff = ...
            lTask.(metricName).(testName).(regionName) - ...
            lTask.(metricName).(preName).(regionName);

        controlDiff = ...
            lControl.(metricName).(testName).(regionName) - ...
            lControl.(metricName).(preName).(regionName);

        taskDiff = taskDiff(:);
        controlDiff = controlDiff(:);

        taskDiff = taskDiff(isfinite(taskDiff));
        controlDiff = controlDiff(isfinite(controlDiff));

        nTask(regionIndex) = numel(taskDiff);
        nControl(regionIndex) = numel(controlDiff);

        meanDeltaTask(regionIndex) = mean(taskDiff,'omitnan');
        meanDeltaControl(regionIndex) = mean(controlDiff,'omitnan');

        if numel(taskDiff) < 2 || numel(controlDiff) < 2
            continue;
        end

        [hValue(regionIndex),pValue(regionIndex),~,stats] = ...
            ttest2(taskDiff,controlDiff);

        tValue(regionIndex) = stats.tstat;
        dfValue(regionIndex) = stats.df;
    end

    % Historical visual convention.
    plottedT = -tValue;

    %% FDR across ROIs

    finiteP = pValue(isfinite(pValue));

    if isempty(finiteP)
        fdrThreshold = [];
    else
        fdrThreshold = FDR(finiteP',fdrAlpha);
    end

    fdrSignificant = false(numberOfRegions,1);

    if ~isempty(fdrThreshold)
        fdrSignificant = isfinite(pValue) & pValue <= fdrThreshold;
    end

    %% Plot

    fig = figure( ...
        'Name',sprintf('Figure S7A: %s',metricName), ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,80,760,1050] ...
    );

    yPositions = 1:numberOfRegions;

    barHandle = barh( ...
        yPositions,flip(plottedT), ...
        'FaceColor','flat', ...
        'EdgeColor','none' ...
    );

    barHandle.CData = vals2colormap_jr( ...
        flip(plottedT),colorMap,[-5,5] ...
    );

    ax = gca;
    box(ax,'off');

    ax.YTick = yPositions;
    ax.YTickLabel = flip(regionNames);
    ax.TickLabelInterpreter = 'none';
    ax.FontSize = 10;
    ax.LineWidth = 1.5;

    xlabel(ax,'t statistic (original plotting orientation)','Interpreter','none');
    title(ax,metricName,'Interpreter','none','FontSize',14);

    finiteT = plottedT(isfinite(plottedT));

    if isempty(finiteT)
        maxAbsoluteT = 1;
    else
        maxAbsoluteT = max(1,ceil(max(abs(finiteT))));
    end

    ax.XLim = [-maxAbsoluteT,maxAbsoluteT];

    %% Display thresholds using actual df

    finiteDf = dfValue(isfinite(dfValue));

    if ~isempty(finiteDf)

        displayDf = min(finiteDf);
        uncorrectedTCritical = tinv(1-0.05/2,displayDf);

        xline(ax,uncorrectedTCritical,'--','LineWidth',1);
        xline(ax,-uncorrectedTCritical,'--','LineWidth',1);

        if ~isempty(fdrThreshold) && fdrThreshold > 0
            fdrTCritical = tinv(1-fdrThreshold/2,displayDf);

            xline(ax,fdrTCritical,'-','LineWidth',1.5);
            xline(ax,-fdrTCritical,'-','LineWidth',1.5);
        else
            fdrTCritical = NaN;
        end

    else
        displayDf = NaN;
        uncorrectedTCritical = NaN;
        fdrTCritical = NaN;
    end

    %% Exports

    resultTable = table( ...
        string(regionNames), ...
        tValue, ...
        plottedT, ...
        pValue, ...
        hValue, ...
        fdrSignificant, ...
        dfValue, ...
        nTask, ...
        nControl, ...
        meanDeltaTask, ...
        meanDeltaControl, ...
        'VariableNames',{ ...
            'Region', ...
            'T_Raw_ConditioningVsControl', ...
            'T_Plotted_Negated', ...
            'P', ...
            'P_LessThan_0_05', ...
            'FDR_Significant', ...
            'DegreesOfFreedom', ...
            'N_Conditioning', ...
            'N_Control', ...
            'MeanDelta_Conditioning', ...
            'MeanDelta_Control' ...
        } ...
    );

    writetable(resultTable, ...
        fullfile(outputDir,sprintf('SourceData_Figure_S7A_%s.csv',metricName)));

    fdrThresholdForTable = NaN;

    if ~isempty(fdrThreshold)
        fdrThresholdForTable = fdrThreshold;
    end

    metadata = table( ...
        string('Figure S7A'), ...
        string(metricName), ...
        string(comparisonName), ...
        minThresholdIndex, ...
        maxThresholdIndex, ...
        thresholdDisplayMin, ...
        thresholdDisplayMax, ...
        fdrAlpha, ...
        fdrThresholdForTable, ...
        displayDf, ...
        uncorrectedTCritical, ...
        fdrTCritical, ...
        string(taskFile), ...
        string(controlFile), ...
        'VariableNames',{ ...
            'Figure','Metric','Comparison', ...
            'MinThresholdIndex','MaxThresholdIndex', ...
            'MinThresholdDisplay','MaxThresholdDisplay', ...
            'FDR_Alpha','FDR_P_Threshold', ...
            'DisplayDegreesOfFreedom', ...
            'Uncorrected_T_Critical','FDR_T_Critical', ...
            'Conditioning_Input_File','Control_Input_File' ...
        } ...
    );

    writetable(metadata, ...
        fullfile(outputDir,sprintf('AnalysisMetadata_Figure_S7A_%s.csv',metricName)));

    save(fullfile(outputDir,sprintf('Statistics_Figure_S7A_%s.mat',metricName)), ...
        'tValue','plottedT','pValue','hValue','fdrSignificant', ...
        'fdrThreshold','dfValue','nTask','nControl', ...
        'meanDeltaTask','meanDeltaControl','regionNames', ...
        'metricName','comparisonName','sorting');

    if ~isempty(which('docDataSrc'))
        try
            docDataSrc(fig,outputDir,scriptFile,true);
        catch documentationError
            warning('docDataSrc failed: %s',documentationError.message);
        end
    end

    exportgraphics(fig, ...
        fullfile(outputDir,sprintf('Figure_S7A_%s_TaskVsControl.pdf',metricName)), ...
        'ContentType','vector','BackgroundColor','white');

    exportgraphics(fig, ...
        fullfile(outputDir,sprintf('Figure_S7A_%s_TaskVsControl.png',metricName)), ...
        'Resolution',300,'BackgroundColor','white');
end

processedMetric = string(localMetrics(:));
metricList = table(processedMetric,'VariableNames',{'Metric'});

writetable(metricList, ...
    fullfile(outputDir,'Figure_S7A_ProcessedMetrics.csv'));

fprintf('\nCompleted Figure S7A analysis.\n');
fprintf('Outputs saved to:\n%s\n',outputDir);
