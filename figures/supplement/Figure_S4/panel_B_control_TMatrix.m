% panel_B_control_TMatrix.m
% Jonathan Reinwald
%
% Reviewer-facing BASCO paired connectivity comparison for
% Supplementary Figure S4B.
%
% Cohort: Control cohort
%
% PRE  = TPnoPuff trials 11-40
% TEST = TPnoPuff trials 81-120
%
% Statistics:
%   paired edge-wise test using lei_pairedtt
%   FDR alpha = 0.05
%
% Display:
%   lower triangle of TEST > PRE T-statistics
%   custom magenta-blue colormap
%   color limits = [-5 5]
%   FDR-significant cells outlined
%
% Input:
%   data/processed/fMRI/Figure_3/control/
%       cormat_v6_TPnoPuff11to40.mat
%       cormat_v6_TPnoPuff81to120.mat
%       roidata*.mat
%
% Helpers are loaded recursively from src/matlab/.
% The colormap is expected under:
%   src/matlab/helpers/colormaps/myColormap_magentablue.mat
%
% Output:
%   results/supplement/Figure_S4/Figure_S4B/
%
% -------------------------------------------------------------------------

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

inputDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', ...
    'Figure_3', 'control' ...
);

outputDir = fullfile( ...
    repoRoot, 'results', 'supplement', ...
    'Figure_S4', 'Figure_S4B' ...
);

colormapFile = fullfile( ...
    srcDir, 'helpers', 'colormaps', ...
    'myColormap_magentablue.mat' ...
);

%% Analysis settings

cohortName = 'Control cohort';
analysisName = 'TPnoPuff';
cormatSuffix = 'v6';

preRangeLabel = '11to40';
testRangeLabel = '81to120';

fdrAlpha = 0.05;
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

%% Add repository MATLAB code

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

if isempty(which('lei_pairedtt'))
    error([ ...
        'Required helper lei_pairedtt.m was not found. ' ...
        'Place it somewhere under src/matlab/.' ...
    ]);
end

%% Check inputs

if ~isfolder(inputDir)
    error('Input directory not found:\n%s', inputDir);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

if ~isfile(colormapFile)
    error([ ...
        'Custom colormap not found:\n%s\n\n' ...
        'Expected: src/matlab/helpers/colormaps/' ...
        'myColormap_magentablue.mat' ...
    ], colormapFile);
end

colormapData = load(colormapFile);

if ~isfield(colormapData, 'myColormap')
    error('Variable "myColormap" missing from:\n%s', colormapFile);
end

myColormap = colormapData.myColormap;

%% Load ROI names

roiDataFiles = dir(fullfile(inputDir, 'roidata*.mat'));

if isempty(roiDataFiles)
    error('No roidata*.mat file found in:\n%s', inputDir);
end

[~, roiOrder] = sort({roiDataFiles.name});
roiDataFiles = roiDataFiles(roiOrder);

% Prefer the cohort-specific BASCO version if several ROI files are present.
preferred = find(contains({roiDataFiles.name}, cormatSuffix), 1, 'first');

if isempty(preferred)
    preferred = 1;
end

if numel(roiDataFiles) > 1
    warning( ...
        'Multiple roidata files found. Using:\n%s', ...
        roiDataFiles(preferred).name ...
    );
end

roiDataFile = fullfile( ...
    roiDataFiles(preferred).folder, ...
    roiDataFiles(preferred).name ...
);

roiData = load(roiDataFile);

if ~isfield(roiData, 'subj') || ...
        ~isfield(roiData.subj(1), 'roi') || ...
        ~isfield(roiData.subj(1).roi, 'name')
    error('Could not read ROI names from:\n%s', roiDataFile);
end

roiNamesUnsorted = {roiData.subj(1).roi.name};

if max(sorting) > numel(roiNamesUnsorted)
    error([ ...
        'The sorting vector requires at least %d ROIs, ' ...
        'but only %d were found.' ...
    ], max(sorting), numel(roiNamesUnsorted));
end

roiNames = roiNamesUnsorted(sorting);
numberOfROIs = numel(roiNames);

%% PRE and TEST files

preFileName = sprintf( ...
    'cormat_%s_%s%s.mat', ...
    cormatSuffix, analysisName, preRangeLabel ...
);

testFileName = sprintf( ...
    'cormat_%s_%s%s.mat', ...
    cormatSuffix, analysisName, testRangeLabel ...
);

preFile = fullfile(inputDir, preFileName);
testFile = fullfile(inputDir, testFileName);

if ~isfile(preFile)
    error('PRE cormat file not found:\n%s', preFile);
end

if ~isfile(testFile)
    error('TEST cormat file not found:\n%s', testFile);
end

preLoaded = load(preFile);
testLoaded = load(testFile);

if ~isfield(preLoaded, 'cormat') || ~isfield(testLoaded, 'cormat')
    error('Both PRE and TEST files must contain variable "cormat".');
end

cormatPre = preLoaded.cormat;
cormatTest = testLoaded.cormat;

if ~iscell(cormatPre) || ~iscell(cormatTest)
    error('Both cormat variables must be cell arrays.');
end

if numel(cormatPre) ~= numel(cormatTest)
    error( ...
        'PRE and TEST subject counts differ: %d versus %d.', ...
        numel(cormatPre), numel(cormatTest) ...
    );
end

numberOfSubjects = numel(cormatPre);

if numberOfSubjects == 0
    error('cormat arrays are empty.');
end

%% Validate and reorder ROIs

for subjectIndex = 1:numberOfSubjects

    preMatrix = cormatPre{subjectIndex};
    testMatrix = cormatTest{subjectIndex};

    if ~ismatrix(preMatrix) || size(preMatrix,1) ~= size(preMatrix,2)
        error('PRE matrix for subject %d is not square.', subjectIndex);
    end

    if ~ismatrix(testMatrix) || size(testMatrix,1) ~= size(testMatrix,2)
        error('TEST matrix for subject %d is not square.', subjectIndex);
    end

    if size(preMatrix,1) < max(sorting) || size(testMatrix,1) < max(sorting)
        error( ...
            'Subject %d contains fewer ROIs than required.', ...
            subjectIndex ...
        );
    end

    cormatPre{subjectIndex} = preMatrix(sorting, sorting);
    cormatTest{subjectIndex} = testMatrix(sorting, sorting);
end

%% Paired edge-wise TEST > PRE comparison

[T, p, p2, fdrMatrix, meanValue, standardDeviation] = ...
    lei_pairedtt(cormatTest, cormatPre, fdrAlpha);

if ~isequal(size(T), [numberOfROIs, numberOfROIs])
    error('lei_pairedtt returned an unexpected T-matrix size.');
end

% Use a symmetric logical mask for display. This is robust to helpers that
% populate only one triangle of the symmetric FDR matrix.
fdrDisplay = logical(fdrMatrix | fdrMatrix');

%% Display lower triangle

displayT = tril(T, -1);
displayT(displayT == 0) = NaN;

comparisonTitle = sprintf( ...
    'Figure_S4B: %s TPnoPuff TEST > PRE', ...
    cohortName ...
);

fig = figure( ...
    'Name', comparisonTitle, ...
    'Visible', 'on', ...
    'Color', 'white', ...
    'Position', [100, 100, 900, 780] ...
);

imagesc(displayT, 'AlphaData', ~isnan(displayT));

ax = gca;
axis(ax, 'image');
box(ax, 'off');

ax.CLim = comparisonColorLimits;
ax.TickLabelInterpreter = 'none';
ax.XTick = 1:numberOfROIs;
ax.XTickLabel = roiNames;
ax.YTick = 1:numberOfROIs;
ax.YTickLabel = roiNames;
ax.FontSize = 5;

colormap(ax, flipud(myColormap));
xtickangle(ax, 90);

title(ax, comparisonTitle, 'Interpreter', 'none');
colorbar;
hold(ax, 'on');

%% Mark FDR-significant cells

for rowIndex = 2:numberOfROIs
    for columnIndex = 1:(rowIndex - 1)

        if fdrDisplay(rowIndex, columnIndex)
            rectangle( ...
                ax, ...
                'Position', ...
                [columnIndex - 0.5, rowIndex - 0.5, 1, 1], ...
                'EdgeColor', [0.3, 0.3, 0.3], ...
                'LineWidth', 1 ...
            );
        end
    end
end

%% Save matrices

filePrefix = 'Figure_S4B_control_TPnoPuff_TEST_vs_PRE';

writeLabeledMatrix( ...
    fullfile(outputDir, ['SourceData_' filePrefix '_DisplayedTMatrix.csv']), ...
    displayT, roiNames ...
);

writeLabeledMatrix( ...
    fullfile(outputDir, ['Statistics_' filePrefix '_T_full.csv']), ...
    T, roiNames ...
);

writeLabeledMatrix( ...
    fullfile(outputDir, ['Statistics_' filePrefix '_P.csv']), ...
    p, roiNames ...
);

writeLabeledMatrix( ...
    fullfile(outputDir, ['Statistics_' filePrefix '_P2.csv']), ...
    p2, roiNames ...
);

writeLabeledMatrix( ...
    fullfile(outputDir, ['Statistics_' filePrefix '_FDR.csv']), ...
    double(fdrDisplay), roiNames ...
);

%% Save complete results

save( ...
    fullfile(outputDir, ['Statistics_' filePrefix '_CompleteResults.mat']), ...
    'T', 'p', 'p2', 'fdrMatrix', 'fdrDisplay', ...
    'meanValue', 'standardDeviation', 'displayT', ...
    'roiNames', 'sorting', 'preFileName', 'testFileName', ...
    'analysisName', 'cohortName', 'fdrAlpha', 'numberOfSubjects' ...
);

%% Metadata

metadata = table( ...
    string('Figure_S4B'), ...
    string(cohortName), ...
    string(analysisName), ...
    string(preFileName), ...
    string(testFileName), ...
    numberOfSubjects, ...
    numberOfROIs, ...
    fdrAlpha, ...
    string(roiDataFile), ...
    string(colormapFile), ...
    'VariableNames', { ...
        'Panel'
        'Cohort'
        'Analysis'
        'PreFile'
        'TestFile'
        'NumberOfSubjects'
        'NumberOfROIs'
        'FDRAlpha'
        'ROIDataFile'
        'ColormapFile'
    } ...
);

writetable( ...
    metadata, ...
    fullfile(outputDir, ['AnalysisMetadata_' filePrefix '.csv']) ...
);

%% Optional provenance

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig, outputDir, scriptFile, true);
    catch documentationError
        warning('docDataSrc failed: %s', documentationError.message);
    end
end

%% Export figure

exportgraphics( ...
    fig, ...
    fullfile(outputDir, [filePrefix '_PairedTMatrix.pdf']), ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white' ...
);

exportgraphics( ...
    fig, ...
    fullfile(outputDir, [filePrefix '_PairedTMatrix.png']), ...
    'Resolution', 300, ...
    'BackgroundColor', 'white' ...
);

savefig( ...
    fig, ...
    fullfile(outputDir, [filePrefix '_PairedTMatrix.fig']) ...
);

fprintf('\nCompleted Figure_S4B: %s.\n', cohortName);
fprintf('Outputs saved to:\n%s\n', outputDir);

%% ========================================================================
% Local function
%% ========================================================================

function writeLabeledMatrix(filePath, matrixData, labels)

    labels = labels(:);
    numberOfLabels = numel(labels);

    if ~isequal(size(matrixData), [numberOfLabels, numberOfLabels])
        error('Matrix dimensions do not match the ROI-label count.');
    end

    outputCell = cell(numberOfLabels + 1, numberOfLabels + 1);

    outputCell(1, 2:end) = labels';
    outputCell(2:end, 1) = labels;
    outputCell(2:end, 2:end) = num2cell(matrixData);

    writecell(outputCell, filePath);
end
