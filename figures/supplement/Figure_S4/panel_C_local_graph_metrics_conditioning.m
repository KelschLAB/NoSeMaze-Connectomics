% panel_C_local_graph_metrics_conditioning.m
% Jonathan Reinwald
%
% Reviewer-facing regional local graph-metric analysis for
% Supplementary Figure S4C.
%
% Cohort: conditioning cohort
% Time point: proximal CR (TPnoPuff)
%
% PRE  = trials 11-40
% TEST = trials 81-120
%
% Metrics:
%   l_strength
%   l_cc
%
% Statistics:
%   paired t-test across animals for each ROI
%   FDR across ROIs separately for each metric
%
% Display:
%   positive T = TEST > PRE
%   negative T = PRE > TEST
%   reversed x-axis preserves the historical figure orientation
%   * = nominal p < .05
%   section sign = FDR-significant ROI
%
% Input:
%   data/processed/fMRI/Figure_4/Figure_4B/conditioning/
%       res_auc_struc_local.mat
%
% ROI labels:
%   data/processed/fMRI/Figure_3/conditioning/roidata*.mat
%
% Helpers are loaded recursively from src/matlab/.
% Colormap:
%   src/matlab/helpers/colormaps/myColormap_magentablue.mat
%
% Output:
%   results/supplement/Figure_S4/Figure_S4C/
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
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Paths

srcDir = fullfile(repoRoot, 'src', 'matlab');

inputFile = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', ...
    'Figure_4', 'Figure_4B', 'conditioning', ...
    'res_auc_struc_local.mat' ...
);

roiDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', ...
    'Figure_3', 'conditioning' ...
);

colormapFile = fullfile( ...
    srcDir, 'helpers', 'colormaps', ...
    'myColormap_magentablue.mat' ...
);

outputDir = fullfile( ...
    repoRoot, 'results', 'supplement', ...
    'Figure_S4', 'Figure_S4C' ...
);

%% Add repository MATLAB code

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {'FDR', 'vals2colormap_jr'};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)), requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error( ...
        'Required MATLAB helper functions not found:\n%s', ...
        strjoin(missingFunctions, newline) ...
    );
end

if isempty(ver('stats'))
    error([ ...
        'Statistics and Machine Learning Toolbox is required ' ...
        'for ttest and tinv.' ...
    ]);
end

%% Analysis settings

preName = 'TPnoPuff11to40';
testName = 'TPnoPuff81to120';

fdrAlpha = 0.05;

localMetrics = {'l_strength', 'l_cc'};
metricTitles = {'Strength', 'Local clustering coefficient'};

comparisonColorLimits = [-5, 5];

sorting = [ ...
    4:8, ...
    42:43, ...
    24:27, ...
    1:3, ...
    28, ...
    12:16, ...
    19, ...
    18, ...
    17, ...
    20, ...
    21, ...
    9:11, ...
    32:33, ...
    29:31, ...
    34:35, ...
    38:41, ...
    45:52, ...
    22:23, ...
    36, ...
    37, ...
    44 ...
];

%% Check inputs

if ~isfile(inputFile)
    error('Local AUC result file not found:\n%s', inputFile);
end

if ~isfolder(roiDir)
    error('ROI directory not found:\n%s', roiDir);
end

if ~isfile(colormapFile)
    error([ ...
        'Colormap file not found:\n%s\n\n' ...
        'Expected: src/matlab/helpers/colormaps/' ...
        'myColormap_magentablue.mat' ...
    ], colormapFile);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Load local AUC structure

loaded = load(inputFile);

if ~isfield(loaded, 'res_auc_struc')
    error('Variable "res_auc_struc" missing from:\n%s', inputFile);
end

res = loaded.res_auc_struc;

for metricIndex = 1:numel(localMetrics)

    metricName = localMetrics{metricIndex};

    if ~isfield(res, metricName)
        error('Metric "%s" missing from res_auc_struc.', metricName);
    end

    if ~isfield(res.(metricName), preName) || ...
            ~isfield(res.(metricName), testName)
        error( ...
            'Metric "%s" does not contain both PRE and TEST.', ...
            metricName ...
        );
    end
end

%% Load ROI names and apply canonical ordering

roiFiles = dir(fullfile(roiDir, 'roidata*.mat'));

if isempty(roiFiles)
    error('No roidata*.mat file found in:\n%s', roiDir);
end

[~, roiOrder] = sort({roiFiles.name});
roiFiles = roiFiles(roiOrder);

% Use the cohort-specific BASCO version when available.
preferred = find(contains({roiFiles.name}, 'v11'), 1, 'first');

if isempty(preferred)
    preferred = 1;
end

if numel(roiFiles) > 1
    warning( ...
        'Multiple roidata files found. Using:\n%s', ...
        roiFiles(preferred).name ...
    );
end

roiDataFile = fullfile( ...
    roiFiles(preferred).folder, ...
    roiFiles(preferred).name ...
);

roiLoaded = load(roiDataFile);

if ~isfield(roiLoaded, 'subj') || ...
        ~isfield(roiLoaded.subj(1), 'roi') || ...
        ~isfield(roiLoaded.subj(1).roi, 'name')
    error('Could not read ROI names from:\n%s', roiDataFile);
end

roiNamesUnsorted = {roiLoaded.subj(1).roi.name};

if max(sorting) > numel(roiNamesUnsorted)
    error( ...
        'Sorting requires at least %d ROIs; only %d were found.', ...
        max(sorting), numel(roiNamesUnsorted) ...
    );
end

roiNames = roiNamesUnsorted(sorting);
numberOfROIs = numel(roiNames);

%% Verify ROI fields

for metricIndex = 1:numel(localMetrics)

    metricName = localMetrics{metricIndex};

    missingPre = roiNames( ...
        ~cellfun( ...
            @(x) isfield(res.(metricName).(preName), x), ...
            roiNames ...
        ) ...
    );

    missingTest = roiNames( ...
        ~cellfun( ...
            @(x) isfield(res.(metricName).(testName), x), ...
            roiNames ...
        ) ...
    );

    if ~isempty(missingPre) || ~isempty(missingTest)
        error( ...
            'ROI fields do not match canonical labels for metric %s.', ...
            metricName ...
        );
    end
end

%% Load colormap

colorData = load(colormapFile);

if ~isfield(colorData, 'myColormap')
    error('Variable "myColormap" missing from:\n%s', colormapFile);
end

myColormap = colorData.myColormap;

%% Run paired regional tests

results = struct([]);

for metricIndex = 1:numel(localMetrics)

    metricName = localMetrics{metricIndex};

    preValues = [];
    testValues = [];

    for regionIndex = 1:numberOfROIs

        regionName = roiNames{regionIndex};

        currentPre = res.(metricName).(preName).(regionName);
        currentTest = res.(metricName).(testName).(regionName);

        currentPre = currentPre(:);
        currentTest = currentTest(:);

        if numel(currentPre) ~= numel(currentTest)
            error( ...
                '%s / %s: PRE and TEST sample sizes differ.', ...
                metricName, regionName ...
            );
        end

        if regionIndex == 1
            numberOfSubjects = numel(currentPre);

            preValues = nan(numberOfSubjects, numberOfROIs);
            testValues = nan(numberOfSubjects, numberOfROIs);

        elseif numel(currentPre) ~= numberOfSubjects
            error( ...
                '%s / %s: sample size differs from other ROIs.', ...
                metricName, regionName ...
            );
        end

        preValues(:,regionIndex) = currentPre;
        testValues(:,regionIndex) = currentTest;
    end

    [h, p, ci, stats] = ttest(testValues, preValues);

    tRaw = stats.tstat(:);
    p = p(:);
    h = h(:);
    degreesOfFreedom = stats.df(:);

    finiteP = p(isfinite(p));

    if isempty(finiteP)
        fdrPThreshold = [];
    else
        fdrPThreshold = FDR(finiteP', fdrAlpha);
    end

    fdrSignificant = false(numberOfROIs,1);

    if ~isempty(fdrPThreshold)
        fdrSignificant = isfinite(p) & p <= fdrPThreshold;
    end

    results(metricIndex).metric = metricName;
    results(metricIndex).preValues = preValues;
    results(metricIndex).testValues = testValues;
    results(metricIndex).tRaw = tRaw;
    results(metricIndex).p = p;
    results(metricIndex).h = h;
    results(metricIndex).ci = ci;
    results(metricIndex).degreesOfFreedom = degreesOfFreedom;
    results(metricIndex).fdrPThreshold = fdrPThreshold;
    results(metricIndex).fdrSignificant = fdrSignificant;
    results(metricIndex).numberOfSubjects = numberOfSubjects;
end

%% Create Figure S4C

fig = figure( ...
    'Name', 'Figure S4C: regional local graph metrics', ...
    'Visible', 'on', ...
    'Color', 'white', ...
    'Position', [100, 60, 1300, 1050] ...
);

for metricIndex = 1:numel(localMetrics)

    tDisplayed = results(metricIndex).tRaw;
    p = results(metricIndex).p;
    fdrSignificant = results(metricIndex).fdrSignificant;
    dfValues = results(metricIndex).degreesOfFreedom;
    fdrPThreshold = results(metricIndex).fdrPThreshold;

    ax = subplot(1, 2, metricIndex);

    plotT = flip(tDisplayed);

    barHandle = barh( ...
        ax, ...
        1:numberOfROIs, ...
        plotT, ...
        'FaceColor', 'flat', ...
        'EdgeColor', 'none' ...
    );

    % Preserve historical orientation: positive TEST > PRE appears on the
    % blue side of the magenta-blue map.
    barHandle.CData = vals2colormap_jr( ...
        -plotT, ...
        myColormap, ...
        comparisonColorLimits ...
    );

    box(ax, 'off');

    ax.YTick = 1:numberOfROIs;
    ax.YTickLabel = flip(roiNames);
    ax.TickLabelInterpreter = 'none';
    ax.FontSize = 7;
    ax.LineWidth = 1.5;
    ax.XDir = 'reverse';

    xlabel( ...
        ax, ...
        'T statistic (positive = TEST > PRE; negative = PRE > TEST)', ...
        'Interpreter', 'none' ...
    );

    title( ...
        ax, ...
        metricTitles{metricIndex}, ...
        'Interpreter', 'none', ...
        'FontSize', 12 ...
    );

    finiteT = tDisplayed(isfinite(tDisplayed));

    if isempty(finiteT)
        maxAbsoluteT = 1;
    else
        maxAbsoluteT = max(1, ceil(max(abs(finiteT))));
    end

    ax.XLim = [-maxAbsoluteT, maxAbsoluteT];

    %% Significance markers

    for regionIndex = 1:numberOfROIs

        displayIndex = numberOfROIs + 1 - regionIndex;

        if fdrSignificant(regionIndex)
            text( ...
                ax, 0, displayIndex, char(167), ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center' ...
            );

        elseif isfinite(p(regionIndex)) && p(regionIndex) <= 0.05
            text( ...
                ax, 0, displayIndex, '*', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center' ...
            );
        end
    end

    %% Nominal and FDR T thresholds

    finiteDf = dfValues(isfinite(dfValues));

    if ~isempty(finiteDf)

        displayDf = min(finiteDf);

        nominalTCritical = tinv(1 - 0.05/2, displayDf);

        xline(ax, nominalTCritical, '--', 'LineWidth', 1);
        xline(ax, -nominalTCritical, '--', 'LineWidth', 1);

        if ~isempty(fdrPThreshold) && fdrPThreshold > 0
            fdrTCritical = tinv(1 - fdrPThreshold/2, displayDf);

            xline(ax, fdrTCritical, '-', 'LineWidth', 1.5);
            xline(ax, -fdrTCritical, '-', 'LineWidth', 1.5);
        else
            fdrTCritical = NaN;
        end
    else
        displayDf = NaN;
        nominalTCritical = NaN;
        fdrTCritical = NaN;
    end

    results(metricIndex).displayDf = displayDf;
    results(metricIndex).nominalTCritical = nominalTCritical;
    results(metricIndex).fdrTCritical = fdrTCritical;
end

sgtitle( ...
    'Figure S4C | conditioning cohort | TPnoPuff TEST > PRE', ...
    'Interpreter', 'none' ...
);

%% Save source data and statistics

for metricIndex = 1:numel(localMetrics)

    metricName = localMetrics{metricIndex};

    resultTable = table( ...
        string(roiNames(:)), ...
        results(metricIndex).tRaw, ...
        results(metricIndex).p, ...
        results(metricIndex).h, ...
        results(metricIndex).fdrSignificant, ...
        results(metricIndex).degreesOfFreedom, ...
        'VariableNames', { ...
            'Region'
            'T_TEST_minus_PRE'
            'P'
            'P_LessThan_0_05'
            'FDR_Significant'
            'DegreesOfFreedom'
        } ...
    );

    writetable( ...
        resultTable, ...
        fullfile( ...
            outputDir, ...
            sprintf('SourceData_Figure_S4C_%s.csv', metricName) ...
        ) ...
    );

    preTable = array2table( ...
        results(metricIndex).preValues, ...
        'VariableNames', matlab.lang.makeValidName(roiNames) ...
    );

    testTable = array2table( ...
        results(metricIndex).testValues, ...
        'VariableNames', matlab.lang.makeValidName(roiNames) ...
    );

    writetable( ...
        preTable, ...
        fullfile(outputDir, sprintf('SourceData_Figure_S4C_%s_PRE.csv', metricName)) ...
    );

    writetable( ...
        testTable, ...
        fullfile(outputDir, sprintf('SourceData_Figure_S4C_%s_TEST.csv', metricName)) ...
    );

    fdrThresholdForTable = NaN;

    if ~isempty(results(metricIndex).fdrPThreshold)
        fdrThresholdForTable = results(metricIndex).fdrPThreshold;
    end

    metadata = table( ...
        string('Figure S4C'), ...
        string('conditioning cohort'), ...
        string(metricName), ...
        string(preName), ...
        string(testName), ...
        results(metricIndex).numberOfSubjects, ...
        numberOfROIs, ...
        fdrAlpha, ...
        fdrThresholdForTable, ...
        results(metricIndex).displayDf, ...
        results(metricIndex).nominalTCritical, ...
        results(metricIndex).fdrTCritical, ...
        string(inputFile), ...
        string(roiDataFile), ...
        string(colormapFile), ...
        'VariableNames', { ...
            'Figure'
            'Cohort'
            'Metric'
            'PRE'
            'TEST'
            'NumberOfSubjects'
            'NumberOfROIs'
            'FDR_Alpha'
            'FDR_P_Threshold'
            'DisplayDegreesOfFreedom'
            'Nominal_P05_T_Critical'
            'FDR_T_Critical'
            'InputFile'
            'ROIDataFile'
            'ColormapFile'
        } ...
    );

    writetable( ...
        metadata, ...
        fullfile( ...
            outputDir, ...
            sprintf('AnalysisMetadata_Figure_S4C_%s.csv', metricName) ...
        ) ...
    );
end

%% Complete results

save( ...
    fullfile(outputDir, 'Statistics_Figure_S4C_complete_results.mat'), ...
    'results', 'localMetrics', 'roiNames', 'sorting', ...
    'preName', 'testName', 'fdrAlpha', ...
    'inputFile', 'roiDataFile', 'colormapFile' ...
);

%% Optional provenance

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
    fullfile(outputDir, 'Figure_S4C_local_graph_metrics.pdf'), ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white' ...
);

exportgraphics( ...
    fig, ...
    fullfile(outputDir, 'Figure_S4C_local_graph_metrics.png'), ...
    'Resolution', 300, ...
    'BackgroundColor', 'white' ...
);

savefig( ...
    fig, ...
    fullfile(outputDir, 'Figure_S4C_local_graph_metrics.fig') ...
);

fprintf('\nCompleted Supplementary Figure S4C.\n');
fprintf('Metrics: l_strength, l_cc\n');
fprintf('Outputs saved to:\n%s\n', outputDir);
