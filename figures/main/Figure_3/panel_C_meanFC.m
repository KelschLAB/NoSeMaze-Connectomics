% panel_C_meanFC.m
% Jonathan Reinwald
%
% Repository-adapted mean functional-connectivity analysis.
%
% Figure: Figure 3C
% Analysis: TPnoPuff
%
% This script compares mean functional connectivity between:
%   PRE  = trials 11-40
%   TEST = trials 81-120
%
% for the conditioning and control cohorts.
%
% It reproduces the three analyses from the original script:
%   1. Conditioning: TEST vs PRE
%   2. Control:      TEST vs PRE
%   3. Change score: conditioning vs control
%
% By default, only positive edges are included, as in the active
% configuration of the original script.

clear;
close all;
clc;

%% Locate repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error([ ...
        'MATLAB could not determine the location of this script. ' ...
        'Run the complete saved script rather than selected lines.' ...
    ]);
end

scriptDir = fileparts(scriptFile);
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot, 'src', 'matlab');

inputDirTask = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'Figure_3', 'conditioning' ...
);

inputDirControl = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'Figure_3', 'control' ...
);

outputDir = fullfile(repoRoot, 'results', 'main', 'Figure_3', 'Figure_3C');

%% Analysis settings

analysisName = 'TPnoPuff';
nameTP1 = [analysisName '11to40'];
nameTP2 = [analysisName '81to120'];

cormatVersionTask = 'cormat_v11';
cormatVersionControl = 'cormat_v6';

takeNegativeEdgesIntoAccount = false;

numberOfPermutations = 10000;
permutationAlpha = 0.05;
permutationSeed = 1234;

%% Add repository MATLAB helpers

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {
    'notBoxPlot_modified'
    'permutation_test_paired'
    'permutation_test_unpaired'
    'sigstar'
};

functionPaths = cellfun(@which, requiredFunctions, 'UniformOutput', false);
missingFunctions = requiredFunctions(cellfun(@isempty, functionPaths));

if ~isempty(missingFunctions)
    error([ ...
        'Required MATLAB functions not found:\n%s\n\n' ...
        'Place them somewhere under src/matlab/.' ...
    ], strjoin(missingFunctions, newline));
end

if isempty(ver('stats'))
    error([ ...
        'Statistics and Machine Learning Toolbox is required ' ...
        'for ttest and ttest2.' ...
    ]);
end

%% Check/create directories

if ~isfolder(inputDirTask)
    error('Conditioning input directory not found:\n%s', inputDirTask);
end

if ~isfolder(inputDirControl)
    error('Control input directory not found:\n%s', inputDirControl);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Define input files

taskPreFile = fullfile(inputDirTask, [cormatVersionTask '_' nameTP1 '.mat']);
taskTestFile = fullfile(inputDirTask, [cormatVersionTask '_' nameTP2 '.mat']);
controlPreFile = fullfile(inputDirControl, [cormatVersionControl '_' nameTP1 '.mat']);
controlTestFile = fullfile(inputDirControl, [cormatVersionControl '_' nameTP2 '.mat']);

requiredFiles = {
    taskPreFile
    taskTestFile
    controlPreFile
    controlTestFile
};

missingFiles = requiredFiles(~cellfun(@isfile, requiredFiles));

if ~isempty(missingFiles)
    error('Required cormat files are missing:\n\n%s', strjoin(missingFiles, newline));
end

%% Load cormats

taskPreData = load(taskPreFile);
taskTestData = load(taskTestFile);
controlPreData = load(controlPreFile);
controlTestData = load(controlTestFile);

loadedData = {taskPreData, taskTestData, controlPreData, controlTestData};
loadedNames = {taskPreFile, taskTestFile, controlPreFile, controlTestFile};

for fileIndex = 1:numel(loadedData)
    if ~isfield(loadedData{fileIndex}, 'cormat')
        error('Variable "cormat" missing from:\n%s', loadedNames{fileIndex});
    end
end

c1Task = cat(3, taskPreData.cormat{:});
c3Task = cat(3, taskTestData.cormat{:});
c1Control = cat(3, controlPreData.cormat{:});
c3Control = cat(3, controlTestData.cormat{:});

%% Validate subject counts

nTaskPre = size(c1Task, 3);
nTaskTest = size(c3Task, 3);
nControlPre = size(c1Control, 3);
nControlTest = size(c3Control, 3);

if nTaskPre ~= nTaskTest
    error('Conditioning PRE and TEST contain different subject counts.');
end

if nControlPre ~= nControlTest
    error('Control PRE and TEST contain different subject counts.');
end

nTask = nTaskPre;
nControl = nControlPre;

%% Exclude diagonal/self-connections

c1Task = removeDiagonal(c1Task);
c3Task = removeDiagonal(c3Task);
c1Control = removeDiagonal(c1Control);
c3Control = removeDiagonal(c3Control);

%% Optionally exclude negative edges

if ~takeNegativeEdgesIntoAccount
    c1Task(c1Task <= 0) = NaN;
    c3Task(c3Task <= 0) = NaN;
    c1Control(c1Control <= 0) = NaN;
    c3Control(c3Control <= 0) = NaN;
end

%% Calculate subject-wise mean FC

meanFCPreTask = subjectMeanFC(c1Task);
meanFCTestTask = subjectMeanFC(c3Task);
meanFCPreControl = subjectMeanFC(c1Control);
meanFCTestControl = subjectMeanFC(c3Control);

meanFCDiffTask = meanFCTestTask - meanFCPreTask;
meanFCDiffControl = meanFCTestControl - meanFCPreControl;

medianFCPreTask = subjectMedianFC(c1Task);
medianFCTestTask = subjectMedianFC(c3Task);
medianFCPreControl = subjectMedianFC(c1Control);
medianFCTestControl = subjectMedianFC(c3Control);
medianFCDiffTask = medianFCTestTask - medianFCPreTask;
medianFCDiffControl = medianFCTestControl - medianFCPreControl;

%% Reproducible permutation setting

rng(permutationSeed, 'twister');

%% Create figure

fig = figure( ...
    'Name', 'Figure 3C mean functional connectivity', ...
    'Visible', 'on', ...
    'Color', 'white', ...
    'Position', [100, 100, 1350, 500] ...
);

plotData = {
    [meanFCPreTask, meanFCTestTask]
    [meanFCPreControl, meanFCTestControl]
    [meanFCDiffTask, meanFCDiffControl]
};

subplotTitles = {'conditioning', 'control', 'conditioning vs control'};
subplotXLabels = {
    {'Pre', 'Test'}
    {'Pre', 'Test'}
    {'conditioning', 'control'}
};

parametricP = nan(3, 1);
permutationP = nan(3, 1);
parametricH = nan(3, 1);

permutationPValues = cell(3, 1);

axesHandles = gobjects(3, 1);

for subplotIndex = 1:3

    subplot(1, 3, subplotIndex);
    boxPlotHandles = notBoxPlot_modified(plotData{subplotIndex});

    for boxIndex = 1:numel(boxPlotHandles)
        boxPlotHandles(boxIndex).data.MarkerSize = 8;
        boxPlotHandles(boxIndex).data.MarkerEdgeColor = 'none';
        boxPlotHandles(boxIndex).semPtch.EdgeColor = 'none';
        boxPlotHandles(boxIndex).sdPtch.EdgeColor = 'none';
    end

    %% Preserve original colors

    if subplotIndex <= 2
        boxPlotHandles(1).data.MarkerFaceColor = [204/255, 51/255, 204/255];
        boxPlotHandles(1).mu.Color = [204/255, 51/255, 204/255];
        boxPlotHandles(1).semPtch.FaceColor = [255/255, 102/255, 204/255];
        boxPlotHandles(1).sdPtch.FaceColor = [255/255, 204/255, 204/255];

        boxPlotHandles(2).data.MarkerFaceColor = [0, 160/255, 227/255];
        boxPlotHandles(2).mu.Color = [0, 160/255, 227/255];
        boxPlotHandles(2).semPtch.FaceColor = [75/255, 207/255, 227/255];
        boxPlotHandles(2).sdPtch.FaceColor = [150/255, 255/255, 227/255];
    else
        boxPlotHandles(1).data.MarkerFaceColor = [0, 128/255, 128/255];
        boxPlotHandles(1).mu.Color = [0, 128/255, 128/255];
        boxPlotHandles(1).semPtch.FaceColor = [102/255, 200/255, 200/255];
        boxPlotHandles(1).sdPtch.FaceColor = [204/255, 230/255, 230/255];

        boxPlotHandles(2).data.MarkerFaceColor = [75/255, 75/255, 75/255];
        boxPlotHandles(2).mu.Color = [75/255, 75/255, 75/255];
        boxPlotHandles(2).semPtch.FaceColor = [125/255, 125/255, 125/255];
        boxPlotHandles(2).sdPtch.FaceColor = [175/255, 175/255, 175/255];
    end

    %% Axes

    box off;
    axesHandles(subplotIndex) = gca;
    axesHandles(subplotIndex).YLabel.String = 'Mean FC [A.U.]';
    axesHandles(subplotIndex).XTick = [1, 2];
    axesHandles(subplotIndex).XTickLabel = subplotXLabels{subplotIndex};
    axesHandles(subplotIndex).XLim = [0.5, 2.5];
    axesHandles(subplotIndex).FontSize = 16;
    axesHandles(subplotIndex).FontWeight = 'bold';
    axesHandles(subplotIndex).LineWidth = 2;

    title(subplotTitles{subplotIndex}, 'Interpreter', 'none');

    %% Statistics

    if subplotIndex == 1
        [parametricH(subplotIndex), parametricP(subplotIndex)] = ...
            ttest(meanFCTestTask, meanFCPreTask);

        [~, ~, permutationPValues{subplotIndex}] = ...
            permutation_test_paired( ...
                meanFCTestTask, ...
                meanFCPreTask, ...
                numberOfPermutations, ...
                'mean' ...
            );

    elseif subplotIndex == 2
        [parametricH(subplotIndex), parametricP(subplotIndex)] = ...
            ttest(meanFCTestControl, meanFCPreControl);

        [~, ~, permutationPValues{subplotIndex}] = ...
            permutation_test_paired( ...
                meanFCTestControl, ...
                meanFCPreControl, ...
                numberOfPermutations, ...
                'mean' ...
            );

    else
        [parametricH(subplotIndex), parametricP(subplotIndex)] = ...
            ttest2(meanFCDiffTask, meanFCDiffControl);

        [~, ~, permutationPValues{subplotIndex}] = ...
            permutation_test_unpaired( ...
                meanFCDiffTask, ...
                meanFCDiffControl, ...
                numberOfPermutations, ...
                'mean' ...
            );
    end

    permutationP(subplotIndex) = getPermutationPValue( ...
        permutationPValues{subplotIndex} ...
    );

    if isfinite(permutationP(subplotIndex)) && permutationP(subplotIndex) < 0.05
        sigstar({[1, 2]}, permutationP(subplotIndex), 0, 30);
    end

    currentAxis = axesHandles(subplotIndex);

    text( ...
        currentAxis.XLim(1) + 0.08 * diff(currentAxis.XLim), ...
        currentAxis.YLim(1) + 0.12 * diff(currentAxis.YLim), ...
        sprintf('p_{perm} = %.4g', permutationP(subplotIndex)), ...
        'Interpreter', 'tex', ...
        'FontSize', 10 ...
    );
end

%% Match y-axis limits for conditioning and control panels

sharedMinimum = min([axesHandles(1).YLim, axesHandles(2).YLim]);
sharedMaximum = max([axesHandles(1).YLim, axesHandles(2).YLim]);
sharedMaximum = round(sharedMaximum, 1) + 0.05;

axesHandles(1).YLim = [sharedMinimum, sharedMaximum];
axesHandles(2).YLim = [sharedMinimum, sharedMaximum];

sgtitle( ...
    sprintf('Figure 3C: %s mean functional connectivity', analysisName), ...
    'Interpreter', 'none' ...
);

%% Save source data

maxN = max(nTask, nControl);

preTaskColumn = nan(maxN, 1);
testTaskColumn = nan(maxN, 1);
diffTaskColumn = nan(maxN, 1);
preControlColumn = nan(maxN, 1);
testControlColumn = nan(maxN, 1);
diffControlColumn = nan(maxN, 1);

preTaskColumn(1:nTask) = meanFCPreTask;
testTaskColumn(1:nTask) = meanFCTestTask;
diffTaskColumn(1:nTask) = meanFCDiffTask;
preControlColumn(1:nControl) = meanFCPreControl;
testControlColumn(1:nControl) = meanFCTestControl;
diffControlColumn(1:nControl) = meanFCDiffControl;

sourceData = table( ...
    (1:maxN)', ...
    preTaskColumn, ...
    testTaskColumn, ...
    preControlColumn, ...
    testControlColumn, ...
    diffTaskColumn, ...
    diffControlColumn, ...
    'VariableNames', {
        'SubjectIndex'
        'Pre_Conditioning'
        'Test_Conditioning'
        'Pre_Control'
        'Test_Control'
        'FCdiff_Conditioning'
        'FCdiff_Control'
    } ...
);

writetable( ...
    sourceData, ...
    fullfile(outputDir, 'Figure_3C_TPnoPuff_SourceData_MeanFC.csv') ...
);

%% Save statistical summary

comparisonNames = {
    'Conditioning_Test_vs_Pre'
    'Control_Test_vs_Pre'
    'FCdiff_Conditioning_vs_Control'
};

statisticsTable = table( ...
    comparisonNames, ...
    parametricH, ...
    parametricP, ...
    permutationP, ...
    repmat(numberOfPermutations, 3, 1), ...
    repmat(permutationSeed, 3, 1), ...
    'VariableNames', { ...
        'Comparison', ...
        'Parametric_H', ...
        'Parametric_P', ...
        'Permutation_P', ...
        'NumberOfPermutations', ...
        'RandomSeed' ...
    } ...
);

writetable( ...
    statisticsTable, ...
    fullfile(outputDir, 'Figure_3C_TPnoPuff_Statistics_MeanFC.csv') ...
);

%% Save complete results

save( ...
    fullfile(outputDir, 'Figure_3C_TPnoPuff_CompleteMeanFCResults.mat'), ...
    'meanFCPreTask', ...
    'meanFCTestTask', ...
    'meanFCPreControl', ...
    'meanFCTestControl', ...
    'meanFCDiffTask', ...
    'meanFCDiffControl', ...
    'medianFCPreTask', ...
    'medianFCTestTask', ...
    'medianFCPreControl', ...
    'medianFCTestControl', ...
    'medianFCDiffTask', ...
    'medianFCDiffControl', ...
    'parametricH', ...
    'parametricP', ...
    'permutationP', ...
    'permutationPValues', ...
    'numberOfPermutations', ...
    'permutationSeed', ...
    'takeNegativeEdgesIntoAccount', ...
    'analysisName', ...
    'nTask', ...
    'nControl' ...
);

%% Save metadata

metadata = table( ...
    string('Figure 3C'), ...
    string(analysisName), ...
    nTask, ...
    nControl, ...
    takeNegativeEdgesIntoAccount, ...
    numberOfPermutations, ...
    permutationSeed, ...
    string(taskPreFile), ...
    string(taskTestFile), ...
    string(controlPreFile), ...
    string(controlTestFile), ...
    'VariableNames', { ...
        'Figure', ...
        'Analysis', ...
        'N_Conditioning', ...
        'N_Control', ...
        'NegativeEdgesIncluded', ...
        'NumberOfPermutations', ...
        'RandomSeed', ...
        'Conditioning_Pre_File', ...
        'Conditioning_Test_File', ...
        'Control_Pre_File', ...
        'Control_Test_File' ...
    } ...
);

writetable( ...
    metadata, ...
    fullfile(outputDir, 'Figure_3C_TPnoPuff_AnalysisMetadata.csv') ...
);

%% Optional source-script documentation

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig, outputDir, scriptFile, true);
    catch documentationError
        warning('docDataSrc failed: %s', documentationError.message);
    end
end

%% Export figure

if takeNegativeEdgesIntoAccount
    edgeLabel = 'PositiveAndNegativeEdges';
else
    edgeLabel = 'PositiveEdgesOnly';
end

figurePdf = fullfile( ...
    outputDir, ...
    sprintf('Figure_3C_TPnoPuff_MeanFC_%s.pdf', edgeLabel) ...
);

figurePng = fullfile( ...
    outputDir, ...
    sprintf('Figure_3C_TPnoPuff_MeanFC_%s.png', edgeLabel) ...
);

exportgraphics( ...
    fig, ...
    figurePdf, ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white' ...
);

exportgraphics( ...
    fig, ...
    figurePng, ...
    'Resolution', 300, ...
    'BackgroundColor', 'white' ...
);

fprintf('\nCompleted Figure 3C mean-FC analysis.\n');
fprintf('Analysis: %s\n', analysisName);
fprintf('Conditioning n = %d; control n = %d\n', nTask, nControl);
fprintf('Outputs saved to:\n%s\n', outputDir);

%% Local functions

function matrix3D = removeDiagonal(matrix3D)
% Replace diagonal/self-connections with NaN in every subject matrix.

    numberOfROIs = size(matrix3D, 1);
    numberOfSubjects = size(matrix3D, 3);
    diagonalIndex = 1:(numberOfROIs + 1):(numberOfROIs^2);

    for subjectIndex = 1:numberOfSubjects
        currentMatrix = matrix3D(:, :, subjectIndex);
        currentMatrix(diagonalIndex) = NaN;
        matrix3D(:, :, subjectIndex) = currentMatrix;
    end
end


function values = subjectMeanFC(matrix3D)
% Reproduce historical:
% squeeze(nanmean(nanmean(matrix3D)))

    values = squeeze( ...
        mean( ...
            mean(matrix3D, 1, 'omitnan'), ...
            2, ...
            'omitnan' ...
        ) ...
    );

    values = values(:);
end

function values = subjectMedianFC(matrix3D)
% Median of all included matrix entries for each subject.

    numberOfSubjects = size(matrix3D, 3);
    values = nan(numberOfSubjects, 1);

    for subjectIndex = 1:numberOfSubjects
        currentMatrix = matrix3D(:, :, subjectIndex);
        values(subjectIndex) = median(currentMatrix(:), 'omitnan');
    end
end


function pValue = getPermutationPValue(pValues)
% Return scalar p-value for annotation from the permutation helper.

    if isempty(pValues)
        pValue = NaN;
    else
        pValue = min(pValues(:));
    end
end
