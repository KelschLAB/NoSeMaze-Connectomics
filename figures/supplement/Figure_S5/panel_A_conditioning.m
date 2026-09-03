% panel_A_conditioning.m
% Jonathan Reinwald
%
% Supplementary Figure S5A:
% distal-CR (Odor) functional-connectivity matrices for the
% conditioning cohort.
%
% PRE  = Odor trials 11-40
% TEST = Odor trials 81-120
%
% Generates:
%   1. mean PRE connectivity matrix
%   2. mean TEST connectivity matrix
%   3. paired TEST > PRE T-statistic matrix
%   4. FDR-thresholded schemaball
%
% Statistics:
%   lei_pairedtt(cormatTest,cormatPre,0.05)
%
% Helpers are loaded recursively from src/matlab/.
% Colormap:
%   src/matlab/helpers/colormaps/myColormap_magentablue.mat

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

inputDir = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_3','conditioning' ...
);

outputDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S5','Figure_S5A','conditioning' ...
);

colormapFile = fullfile( ...
    srcDir,'helpers','colormaps','myColormap_magentablue.mat' ...
);

%% Settings

cohortName = 'Conditioning cohort';
analysisName = 'Odor';
cormatSuffix = 'v11';

preRangeLabel = '11to40';
testRangeLabel = '81to120';

fdrThreshold = 0.05;
meanColorLimits = [-1,1];
comparisonColorLimits = [-5,5];

sorting = [ ...
    4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11, ...
    32:33,29:31,34:35,38:41,45:52,22:23,36,37,44 ...
];

%% Dependencies

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {'lei_pairedtt','schemaball'};
missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error('Required MATLAB functions not found:\n%s', ...
        strjoin(missingFunctions,newline));
end

if ~isfolder(inputDir)
    error('Input directory not found:\n%s',inputDir);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

if ~isfile(colormapFile)
    error(['Custom colormap not found:\n%s\n\n' ...
        'Expected: src/matlab/helpers/colormaps/' ...
        'myColormap_magentablue.mat'],colormapFile);
end

tmp = load(colormapFile);

if ~isfield(tmp,'myColormap')
    error('Variable "myColormap" missing from:\n%s',colormapFile);
end

myColormap = tmp.myColormap;

%% ROI labels

roiDataFiles = dir(fullfile(inputDir,'roidata*.mat'));

if isempty(roiDataFiles)
    error('No roidata*.mat file found in:\n%s',inputDir);
end

[~,order] = sort({roiDataFiles.name});
roiDataFiles = roiDataFiles(order);

preferred = find(contains({roiDataFiles.name},cormatSuffix),1,'first');

if isempty(preferred)
    preferred = 1;
end

if numel(roiDataFiles) > 1
    warning('Multiple roidata files found. Using:\n%s', ...
        roiDataFiles(preferred).name);
end

roiDataFile = fullfile( ...
    roiDataFiles(preferred).folder, ...
    roiDataFiles(preferred).name ...
);

roiData = load(roiDataFile);

if ~isfield(roiData,'subj') || ...
        ~isfield(roiData.subj(1),'roi') || ...
        ~isfield(roiData.subj(1).roi,'name')
    error('Could not read ROI names from:\n%s',roiDataFile);
end

roiNamesUnsorted = {roiData.subj(1).roi.name};

if max(sorting) > numel(roiNamesUnsorted)
    error('Sorting requires at least %d ROIs; only %d found.', ...
        max(sorting),numel(roiNamesUnsorted));
end

roiNames = roiNamesUnsorted(sorting);
numberOfROIs = numel(roiNames);

%% Input cormats

preFileName = sprintf('cormat_%s_%s%s.mat', ...
    cormatSuffix,analysisName,preRangeLabel);

testFileName = sprintf('cormat_%s_%s%s.mat', ...
    cormatSuffix,analysisName,testRangeLabel);

preFile = fullfile(inputDir,preFileName);
testFile = fullfile(inputDir,testFileName);

if ~isfile(preFile)
    error('PRE cormat file not found:\n%s',preFile);
end

if ~isfile(testFile)
    error('TEST cormat file not found:\n%s',testFile);
end

preLoaded = load(preFile);
testLoaded = load(testFile);

if ~isfield(preLoaded,'cormat') || ~isfield(testLoaded,'cormat')
    error('Both PRE and TEST files must contain variable "cormat".');
end

cormatPre = preLoaded.cormat;
cormatTest = testLoaded.cormat;

if ~iscell(cormatPre) || ~iscell(cormatTest)
    error('Both cormat variables must be cell arrays.');
end

if numel(cormatPre) ~= numel(cormatTest)
    error('PRE and TEST subject counts differ.');
end

numberOfSubjects = numel(cormatPre);

if numberOfSubjects == 0
    error('cormat arrays are empty.');
end

%% Reorder ROIs

for subjectIndex = 1:numberOfSubjects

    preMatrix = cormatPre{subjectIndex};
    testMatrix = cormatTest{subjectIndex};

    validateCormat(preMatrix,sorting,'PRE',subjectIndex);
    validateCormat(testMatrix,sorting,'TEST',subjectIndex);

    cormatPre{subjectIndex} = preMatrix(sorting,sorting);
    cormatTest{subjectIndex} = testMatrix(sorting,sorting);
end

%% Mean PRE and TEST matrices

pre3D = cat(3,cormatPre{:});
test3D = cat(3,cormatTest{:});

meanPre = mean(pre3D,3,'omitnan');
meanTest = mean(test3D,3,'omitnan');

figPre = plotMeanMatrix( ...
    meanPre,roiNames,meanColorLimits, ...
    sprintf('%s: Odor PRE (trials 11-40)',cohortName) ...
);

figTest = plotMeanMatrix( ...
    meanTest,roiNames,meanColorLimits, ...
    sprintf('%s: Odor TEST (trials 81-120)',cohortName) ...
);

exportgraphics(figPre, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_PRE_11to40.pdf'), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(figPre, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_PRE_11to40.png'), ...
    'Resolution',300,'BackgroundColor','white');

exportgraphics(figTest, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_81to120.pdf'), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(figTest, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_81to120.png'), ...
    'Resolution',300,'BackgroundColor','white');

writeLabeledMatrix( ...
    fullfile(outputDir,'SourceData_Figure_S5A_conditioning_Odor_PRE_11to40.csv'), ...
    meanPre,roiNames);

writeLabeledMatrix( ...
    fullfile(outputDir,'SourceData_Figure_S5A_conditioning_Odor_TEST_81to120.csv'), ...
    meanTest,roiNames);

%% Paired TEST > PRE

[T,p,p2,fdrMatrix,meanValue,standardDeviation] = ...
    lei_pairedtt(cormatTest,cormatPre,fdrThreshold);

if ~isequal(size(T),[numberOfROIs,numberOfROIs])
    error('lei_pairedtt returned an unexpected T-matrix size.');
end

% Robust logical symmetric mask: avoids double weighting if the helper
% already returns a symmetric matrix.
fdrDisplay = logical(fdrMatrix | fdrMatrix');

lowerMask = tril(true(size(T)),-1);
displayT = nan(size(T));
displayT(lowerMask) = T(lowerMask);

comparisonTitle = sprintf('%s: Odor TEST > PRE, paired',cohortName);

figComparison = figure( ...
    'Name',comparisonTitle, ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,900,780] ...
);

imagesc(displayT,'AlphaData',~isnan(displayT));

ax = gca;
axis(ax,'image');
box(ax,'off');
ax.CLim = comparisonColorLimits;
ax.TickLabelInterpreter = 'none';
ax.XTick = 1:numberOfROIs;
ax.XTickLabel = roiNames;
ax.YTick = 1:numberOfROIs;
ax.YTickLabel = roiNames;
ax.FontSize = 5;

colormap(ax,flipud(myColormap));
xtickangle(ax,90);
title(ax,comparisonTitle,'Interpreter','none');
colorbar;
hold(ax,'on');

for rowIndex = 2:numberOfROIs
    for columnIndex = 1:(rowIndex-1)
        if fdrDisplay(rowIndex,columnIndex)
            rectangle(ax, ...
                'Position',[columnIndex-0.5,rowIndex-0.5,1,1], ...
                'EdgeColor',[0.3,0.3,0.3], ...
                'LineWidth',1);
        end
    end
end

exportgraphics(figComparison, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_vs_PRE_PairedTMatrix.pdf'), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(figComparison, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_vs_PRE_PairedTMatrix.png'), ...
    'Resolution',300,'BackgroundColor','white');

%% FDR-thresholded schemaball

symmetricSignificantT = double(fdrDisplay) .* T;

figSchemaball = figure( ...
    'Name',[comparisonTitle ' schemaball'], ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,900,780] ...
);

schemaball(roiNames,symmetricSignificantT,10,comparisonColorLimits);
title(comparisonTitle,'Interpreter','none');

exportgraphics(figSchemaball, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_vs_PRE_Schemaball.pdf'), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(figSchemaball, ...
    fullfile(outputDir,'Figure_S5A_conditioning_Odor_TEST_vs_PRE_Schemaball.png'), ...
    'Resolution',300,'BackgroundColor','white');

%% Source/statistics

filePrefix = 'Figure_S5A_conditioning_Odor_TEST_vs_PRE';

writeLabeledMatrix(fullfile(outputDir, ...
    ['SourceData_' filePrefix '_DisplayedTMatrix.csv']), ...
    displayT,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    ['Statistics_' filePrefix '_T_full.csv']), ...
    T,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    ['Statistics_' filePrefix '_P.csv']), ...
    p,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    ['Statistics_' filePrefix '_P2.csv']), ...
    p2,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    ['Statistics_' filePrefix '_FDR.csv']), ...
    double(fdrDisplay),roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    ['SourceData_' filePrefix '_FDRThresholdedT.csv']), ...
    symmetricSignificantT,roiNames);

save(fullfile(outputDir, ...
    ['Statistics_' filePrefix '_CompleteResults.mat']), ...
    'T','p','p2','fdrMatrix','fdrDisplay','meanValue', ...
    'standardDeviation','displayT','symmetricSignificantT', ...
    'meanPre','meanTest','roiNames','sorting', ...
    'preFileName','testFileName','analysisName','cohortName', ...
    'fdrThreshold','numberOfSubjects');

metadata = table( ...
    string('Figure S5A'), ...
    string(cohortName), ...
    string(analysisName), ...
    string(preFileName), ...
    string(testFileName), ...
    numberOfSubjects, ...
    numberOfROIs, ...
    fdrThreshold, ...
    string(roiDataFile), ...
    string(colormapFile), ...
    'VariableNames',{ ...
        'Panel','Cohort','Analysis','PreFile','TestFile', ...
        'NumberOfSubjects','NumberOfROIs','FDRThreshold', ...
        'ROIDataFile','ColormapFile' ...
    } ...
);

writetable(metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S5A_conditioning_Odor.csv'));

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(figComparison,outputDir,scriptFile,true);
    catch documentationError
        warning('docDataSrc failed: %s',documentationError.message);
    end
end

fprintf('\nCompleted Supplementary Figure S5A: %s.\n',cohortName);
fprintf('Outputs saved to:\n%s\n',outputDir);

%% Local functions

function validateCormat(matrixData,sorting,label,subjectIndex)
    if ~ismatrix(matrixData) || size(matrixData,1) ~= size(matrixData,2)
        error('%s matrix for subject %d is not square.',label,subjectIndex);
    end
    if size(matrixData,1) < max(sorting)
        error('%s matrix for subject %d contains too few ROIs.', ...
            label,subjectIndex);
    end
end

function figHandle = plotMeanMatrix(matrixData,roiNames,colorLimits,figureTitle)
    numberOfROIs = numel(roiNames);

    figHandle = figure( ...
        'Name',figureTitle, ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,100,900,780] ...
    );

    imagesc(matrixData,'AlphaData',~isnan(matrixData));

    ax = gca;
    axis(ax,'image');
    box(ax,'off');
    ax.CLim = colorLimits;
    ax.TickLabelInterpreter = 'none';
    ax.XTick = 1:numberOfROIs;
    ax.XTickLabel = roiNames;
    ax.YTick = 1:numberOfROIs;
    ax.YTickLabel = roiNames;
    ax.FontSize = 5;

    colormap(ax,jet(256));
    xtickangle(ax,90);
    title(ax,figureTitle,'Interpreter','none');
    colorbar;
end

function writeLabeledMatrix(filePath,matrixData,labels)
    labels = labels(:);
    n = numel(labels);

    if ~isequal(size(matrixData),[n,n])
        error('Matrix dimensions do not match ROI labels.');
    end

    outputCell = cell(n+1,n+1);
    outputCell(1,2:end) = labels';
    outputCell(2:end,1) = labels;
    outputCell(2:end,2:end) = num2cell(matrixData);

    writecell(outputCell,filePath);
end
