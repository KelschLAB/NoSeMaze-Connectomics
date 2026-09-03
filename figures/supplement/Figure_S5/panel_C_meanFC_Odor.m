% panel_C_meanFC_Odor.m
% Jonathan Reinwald
%
% Supplementary Figure S5C:
% distal-CR (Odor) mean functional connectivity.
%
% PRE  = Odor trials 11-40
% TEST = Odor trials 81-120
%
% Analyses:
%   1. Conditioning: TEST vs PRE
%   2. Control: TEST vs PRE
%   3. TEST-PRE change: conditioning vs control
%
% Only positive edges are included, matching the active original analysis.
%
% Statistics:
%   paired and unpaired permutation tests
%   10,000 permutations
%   seed = 1234
%
% Parametric t-tests are exported as supplementary numerical output but
% the figure annotation uses permutation p-values.

clear;
close all;
clc;

%% Repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error(['MATLAB could not determine the script location. ' ...
        'Run the complete saved script rather than selected lines.']);
end

scriptDir = fileparts(scriptFile);
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Paths

srcDir = fullfile(repoRoot,'src','matlab');

inputDirConditioning = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_3','conditioning' ...
);

inputDirControl = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_3','control' ...
);

outputDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S5','Figure_S5C' ...
);

%% Settings

analysisName = 'Odor';

conditioningVersion = 'cormat_v11';
controlVersion = 'cormat_v6';

preName = [analysisName '11to40'];
testName = [analysisName '81to120'];

takeNegativeEdgesIntoAccount = false;

numberOfPermutations = 10000;
permutationSeed = 1234;

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
    error('Required MATLAB functions not found:\n%s', ...
        strjoin(missingFunctions,newline));
end

if isempty(ver('stats'))
    error('Statistics and Machine Learning Toolbox is required for ttest/ttest2.');
end

if ~isfolder(inputDirConditioning)
    error('Conditioning input directory not found:\n%s',inputDirConditioning);
end

if ~isfolder(inputDirControl)
    error('Control input directory not found:\n%s',inputDirControl);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Input files

conditioningPreFile = fullfile( ...
    inputDirConditioning,[conditioningVersion '_' preName '.mat'] ...
);

conditioningTestFile = fullfile( ...
    inputDirConditioning,[conditioningVersion '_' testName '.mat'] ...
);

controlPreFile = fullfile( ...
    inputDirControl,[controlVersion '_' preName '.mat'] ...
);

controlTestFile = fullfile( ...
    inputDirControl,[controlVersion '_' testName '.mat'] ...
);

requiredFiles = { ...
    conditioningPreFile,conditioningTestFile, ...
    controlPreFile,controlTestFile ...
};

missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error('Required cormat files are missing:\n%s', ...
        strjoin(missingFiles,newline));
end

%% Load cormats

conditioningPreData = load(conditioningPreFile);
conditioningTestData = load(conditioningTestFile);
controlPreData = load(controlPreFile);
controlTestData = load(controlTestFile);

loaded = { ...
    conditioningPreData,conditioningTestData, ...
    controlPreData,controlTestData ...
};

loadedNames = { ...
    conditioningPreFile,conditioningTestFile, ...
    controlPreFile,controlTestFile ...
};

for k = 1:numel(loaded)
    if ~isfield(loaded{k},'cormat')
        error('Variable "cormat" missing from:\n%s',loadedNames{k});
    end
end

cPreConditioning = cat(3,conditioningPreData.cormat{:});
cTestConditioning = cat(3,conditioningTestData.cormat{:});
cPreControl = cat(3,controlPreData.cormat{:});
cTestControl = cat(3,controlTestData.cormat{:});

nConditioning = size(cPreConditioning,3);
nControl = size(cPreControl,3);

if nConditioning ~= size(cTestConditioning,3)
    error('Conditioning PRE and TEST subject counts differ.');
end

if nControl ~= size(cTestControl,3)
    error('Control PRE and TEST subject counts differ.');
end

%% Remove diagonal/self-connections

cPreConditioning = removeDiagonal(cPreConditioning);
cTestConditioning = removeDiagonal(cTestConditioning);
cPreControl = removeDiagonal(cPreControl);
cTestControl = removeDiagonal(cTestControl);

%% Positive edges only

if ~takeNegativeEdgesIntoAccount
    cPreConditioning(cPreConditioning <= 0) = NaN;
    cTestConditioning(cTestConditioning <= 0) = NaN;
    cPreControl(cPreControl <= 0) = NaN;
    cTestControl(cTestControl <= 0) = NaN;
end

%% Subject-wise mean FC

meanFCPreConditioning = subjectMeanFC(cPreConditioning);
meanFCTestConditioning = subjectMeanFC(cTestConditioning);
meanFCPreControl = subjectMeanFC(cPreControl);
meanFCTestControl = subjectMeanFC(cTestControl);

meanFCDiffConditioning = ...
    meanFCTestConditioning - meanFCPreConditioning;

meanFCDiffControl = ...
    meanFCTestControl - meanFCPreControl;

%% Statistics

rng(permutationSeed,'twister');

parametricH = nan(3,1);
parametricP = nan(3,1);
permutationP = nan(3,1);
permutationPValues = cell(3,1);

[parametricH(1),parametricP(1)] = ...
    ttest(meanFCTestConditioning,meanFCPreConditioning);

[~,~,permutationPValues{1}] = permutation_test_paired( ...
    meanFCTestConditioning, ...
    meanFCPreConditioning, ...
    numberOfPermutations, ...
    'mean' ...
);

[parametricH(2),parametricP(2)] = ...
    ttest(meanFCTestControl,meanFCPreControl);

[~,~,permutationPValues{2}] = permutation_test_paired( ...
    meanFCTestControl, ...
    meanFCPreControl, ...
    numberOfPermutations, ...
    'mean' ...
);

[parametricH(3),parametricP(3)] = ...
    ttest2(meanFCDiffConditioning,meanFCDiffControl);

[~,~,permutationPValues{3}] = permutation_test_unpaired( ...
    meanFCDiffConditioning, ...
    meanFCDiffControl, ...
    numberOfPermutations, ...
    'mean' ...
);

for k = 1:3
    permutationP(k) = getPermutationPValue(permutationPValues{k});
end

%% Figure

fig = figure( ...
    'Name','Figure S5C: Odor mean functional connectivity', ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,1350,500] ...
);

plotData = { ...
    [meanFCPreConditioning,meanFCTestConditioning], ...
    [meanFCPreControl,meanFCTestControl], ...
    [meanFCDiffConditioning,meanFCDiffControl] ...
};

subplotTitles = {'conditioning','control','conditioning vs control'};

subplotXLabels = { ...
    {'Pre','Test'}, ...
    {'Pre','Test'}, ...
    {'conditioning','control'} ...
};

axesHandles = gobjects(3,1);

for subplotIndex = 1:3

    subplot(1,3,subplotIndex);
    boxPlotHandles = notBoxPlot_modified(plotData{subplotIndex});

    for boxIndex = 1:numel(boxPlotHandles)
        boxPlotHandles(boxIndex).data.MarkerSize = 8;
        boxPlotHandles(boxIndex).data.MarkerEdgeColor = 'none';
        boxPlotHandles(boxIndex).semPtch.EdgeColor = 'none';
        boxPlotHandles(boxIndex).sdPtch.EdgeColor = 'none';
    end

    if subplotIndex <= 2
        setBoxColors(boxPlotHandles(1), ...
            [204/255,51/255,204/255], ...
            [255/255,102/255,204/255], ...
            [255/255,204/255,204/255]);

        setBoxColors(boxPlotHandles(2), ...
            [0,160/255,227/255], ...
            [75/255,207/255,227/255], ...
            [150/255,255/255,227/255]);
    else
        setBoxColors(boxPlotHandles(1), ...
            [0,128/255,128/255], ...
            [102/255,200/255,200/255], ...
            [204/255,230/255,230/255]);

        setBoxColors(boxPlotHandles(2), ...
            [75/255,75/255,75/255], ...
            [125/255,125/255,125/255], ...
            [175/255,175/255,175/255]);
    end

    ax = gca;
    axesHandles(subplotIndex) = ax;

    box(ax,'off');
    ax.YLabel.String = 'Mean FC [A.U.]';
    ax.XTick = [1,2];
    ax.XTickLabel = subplotXLabels{subplotIndex};
    ax.XLim = [0.5,2.5];
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ax.LineWidth = 2;

    title(ax,subplotTitles{subplotIndex},'Interpreter','none');

    if isfinite(permutationP(subplotIndex)) && ...
            permutationP(subplotIndex) < 0.05
        sigstar({[1,2]},permutationP(subplotIndex),0,30);
    end

    text( ...
        ax, ...
        ax.XLim(1)+0.08*diff(ax.XLim), ...
        ax.YLim(1)+0.12*diff(ax.YLim), ...
        sprintf('p_{perm} = %.4g',permutationP(subplotIndex)), ...
        'Interpreter','tex', ...
        'FontSize',10 ...
    );
end

%% Match y-limits for PRE/TEST cohort panels

sharedMinimum = min([axesHandles(1).YLim,axesHandles(2).YLim]);
sharedMaximum = max([axesHandles(1).YLim,axesHandles(2).YLim]);
sharedMaximum = round(sharedMaximum,1)+0.05;

axesHandles(1).YLim = [sharedMinimum,sharedMaximum];
axesHandles(2).YLim = [sharedMinimum,sharedMaximum];

sgtitle('Figure S5C: Odor mean functional connectivity', ...
    'Interpreter','none');

%% Source data

maxN = max(nConditioning,nControl);

preConditioning = nan(maxN,1);
testConditioning = nan(maxN,1);
diffConditioning = nan(maxN,1);
preControl = nan(maxN,1);
testControl = nan(maxN,1);
diffControl = nan(maxN,1);

preConditioning(1:nConditioning) = meanFCPreConditioning;
testConditioning(1:nConditioning) = meanFCTestConditioning;
diffConditioning(1:nConditioning) = meanFCDiffConditioning;

preControl(1:nControl) = meanFCPreControl;
testControl(1:nControl) = meanFCTestControl;
diffControl(1:nControl) = meanFCDiffControl;

sourceData = table( ...
    (1:maxN)', ...
    preConditioning,testConditioning, ...
    preControl,testControl, ...
    diffConditioning,diffControl, ...
    'VariableNames',{ ...
        'SubjectIndex', ...
        'Pre_Conditioning','Test_Conditioning', ...
        'Pre_Control','Test_Control', ...
        'FCdiff_Conditioning','FCdiff_Control' ...
    } ...
);

writetable(sourceData, ...
    fullfile(outputDir,'SourceData_Figure_S5C_Odor_MeanFC.csv'));

%% Statistics table

comparisonNames = { ...
    'Conditioning_Test_vs_Pre'; ...
    'Control_Test_vs_Pre'; ...
    'FCdiff_Conditioning_vs_Control' ...
};

statisticsTable = table( ...
    comparisonNames,parametricH,parametricP,permutationP, ...
    repmat(numberOfPermutations,3,1), ...
    repmat(permutationSeed,3,1), ...
    'VariableNames',{ ...
        'Comparison','Parametric_H','Parametric_P', ...
        'Permutation_P','NumberOfPermutations','RandomSeed' ...
    } ...
);

writetable(statisticsTable, ...
    fullfile(outputDir,'Statistics_Figure_S5C_Odor_MeanFC.csv'));

%% Complete results and metadata

save(fullfile(outputDir,'Figure_S5C_Odor_CompleteMeanFCResults.mat'), ...
    'meanFCPreConditioning','meanFCTestConditioning', ...
    'meanFCPreControl','meanFCTestControl', ...
    'meanFCDiffConditioning','meanFCDiffControl', ...
    'parametricH','parametricP','permutationP','permutationPValues', ...
    'numberOfPermutations','permutationSeed', ...
    'takeNegativeEdgesIntoAccount','analysisName', ...
    'nConditioning','nControl');

metadata = table( ...
    string('Figure S5C'), ...
    string(analysisName), ...
    nConditioning,nControl, ...
    takeNegativeEdgesIntoAccount, ...
    numberOfPermutations,permutationSeed, ...
    string(conditioningPreFile),string(conditioningTestFile), ...
    string(controlPreFile),string(controlTestFile), ...
    'VariableNames',{ ...
        'Figure','Analysis','N_Conditioning','N_Control', ...
        'NegativeEdgesIncluded','NumberOfPermutations','RandomSeed', ...
        'Conditioning_Pre_File','Conditioning_Test_File', ...
        'Control_Pre_File','Control_Test_File' ...
    } ...
);

writetable(metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S5C_Odor.csv'));

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig,outputDir,scriptFile,true);
    catch documentationError
        warning('docDataSrc failed: %s',documentationError.message);
    end
end

if takeNegativeEdgesIntoAccount
    edgeLabel = 'PositiveAndNegativeEdges';
else
    edgeLabel = 'PositiveEdgesOnly';
end

exportgraphics(fig, ...
    fullfile(outputDir,sprintf('Figure_S5C_Odor_MeanFC_%s.pdf',edgeLabel)), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(fig, ...
    fullfile(outputDir,sprintf('Figure_S5C_Odor_MeanFC_%s.png',edgeLabel)), ...
    'Resolution',300,'BackgroundColor','white');

fprintf('\nCompleted Supplementary Figure S5C.\n');
fprintf('Conditioning n = %d; control n = %d\n',nConditioning,nControl);
fprintf('Outputs saved to:\n%s\n',outputDir);

%% Local functions

function matrix3D = removeDiagonal(matrix3D)

    nROI = size(matrix3D,1);
    nSubjects = size(matrix3D,3);
    diagonalIndex = 1:(nROI+1):(nROI^2);

    for subjectIndex = 1:nSubjects
        currentMatrix = matrix3D(:,:,subjectIndex);
        currentMatrix(diagonalIndex) = NaN;
        matrix3D(:,:,subjectIndex) = currentMatrix;
    end
end

function values = subjectMeanFC(matrix3D)

    values = squeeze( ...
        mean(mean(matrix3D,1,'omitnan'),2,'omitnan') ...
    );

    values = values(:);
end

function pValue = getPermutationPValue(pValues)

    if isempty(pValues)
        pValue = NaN;
    else
        pValue = min(pValues(:));
    end
end

function setBoxColors(boxHandle,mainColor,semColor,sdColor)

    boxHandle.data.MarkerFaceColor = mainColor;
    boxHandle.mu.Color = mainColor;
    boxHandle.semPtch.FaceColor = semColor;
    boxHandle.sdPtch.FaceColor = sdColor;
end
