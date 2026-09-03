% panel_C_lid_boxplot.m
% Jonathan Reinwald
%
% Supplementary Figure S1C:
% tonic eyelid opening across four periods in the
% conditioning/reappraisal cohort.
%
% Included periods:
%   PRE              = trials 11-40
%   PAIRING          = trials 41-80
%   TEST             = trials 81-120
%   ADDITIONAL TEST  = trials 121-160
%
% TEST and ADDITIONAL TEST are each treated as one 40-trial block.
% They are not subdivided into 20-trial sub-blocks.
%
% The script derives animal-level non-normalized eye-opening means from:
%
%   data/processed/eyelid/reappraisal/pupil_summary_all.mat
%
% Required field:
%   LidDiameterMatrix
%
% Output source table consumed by panel_C_lid_stats.R:
%   results/supplement/Figure_S1/Figure_S1C/
%       SourceData_Figure_S1C_tonic_lid_four_periods.csv

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

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

inputFile = fullfile( ...
    repoRoot, 'data', 'processed', 'eyelid', 'reappraisal', ...
    'pupil_summary_all.mat' ...
);

outputDir = fullfile( ...
    repoRoot, 'results', 'supplement', 'Figure_S1', 'Figure_S1C' ...
);

if ~isfile(inputFile)
    error('Figure S1C input file not found:\n%s', inputFile);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

if isempty(which('notBoxPlot_modified_pupilANDlid'))
    error([ ...
        'Required plotting helper not found: ' ...
        'notBoxPlot_modified_pupilANDlid.m' ...
    ]);
end

%% Load conditioning/reappraisal sessions

loadedData = load(inputFile);

if ~isfield(loadedData, 'summary_all')
    error('Variable "summary_all" missing from:\n%s', inputFile);
end

summary_all = loadedData.summary_all;
conditioningSessions = summary_all(1:3:end);

if isempty(conditioningSessions)
    error('No conditioning/reappraisal sessions were found.');
end

nAnimals = numel(conditioningSessions);

%% Trial ranges

trialRanges = {
    11:40
    41:80
    81:120
    121:160
};

blockCodes = [1, 2, 3, 4];

blockLabels = {
    'PRE'
    'PAIRING'
    'TEST'
    'ADDITIONAL TEST'
};

nBlocks = numel(trialRanges);

%% Calculate one non-normalized tonic value per mouse and period
%
% This follows the same tonic definition used for the main Figure 2C
% block means: LidDiameterMatrix is non-normalized, and the mean is taken
% across all samples from all trials in the selected period.

plotData = nan(nAnimals, nBlocks);

for animalIndex = 1:nAnimals

    if ~isfield(conditioningSessions(animalIndex), 'LidDiameterMatrix')
        error( ...
            'LidDiameterMatrix missing for conditioning animal %d.', ...
            animalIndex ...
        );
    end

    currentMatrix = conditioningSessions(animalIndex).LidDiameterMatrix;

    if size(currentMatrix,1) < 160
        error( ...
            'Animal %d contains only %d trials; Figure S1C requires 160.', ...
            animalIndex, size(currentMatrix,1) ...
        );
    end

    for blockIndex = 1:nBlocks

        currentTrials = trialRanges{blockIndex};
        currentValues = currentMatrix(currentTrials, :);

        plotData(animalIndex, blockIndex) = mean( ...
            currentValues(:), ...
            'omitnan' ...
        );
    end
end

%% Plot

fig = figure( ...
    'Name','Figure S1C: tonic eye-lid opening', ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,620,500] ...
);

ax = axes(fig);
hold(ax, 'on');

nb = notBoxPlot_modified_pupilANDlid(plotData);

plotColor = [0, 0.5, 0.5];

for blockIndex = 1:nBlocks

    nb(blockIndex).sdPtch.EdgeColor = 'none';
    nb(blockIndex).semPtch.EdgeColor = 'none';

    nb(blockIndex).sdPtch.FaceColor = plotColor;
    nb(blockIndex).semPtch.FaceColor = plotColor;

    nb(blockIndex).sdPtch.FaceAlpha = 0.10;
    nb(blockIndex).semPtch.FaceAlpha = 0.30;

    nb(blockIndex).mu.Color = plotColor;

    nb(blockIndex).data.MarkerFaceColor = plotColor;
    nb(blockIndex).data.MarkerEdgeColor = 'none';
    nb(blockIndex).data.MarkerSize = 8;
end

box(ax, 'off');

ax.XTick = 1:nBlocks;
ax.XTickLabel = blockLabels;
xtickangle(ax, 25);

ax.XLabel.String = 'Period';
ax.YLabel.String = {'Eye opening [A.U.]','non-normalized mean'};

ax.FontWeight = 'bold';
ax.LineWidth = 1;
ax.FontSize = 11;

title(ax, 'Tonic eye-lid opening');

%% Export long-format source data

animal_ID = repelem((1:nAnimals)', nBlocks);
block = repmat(blockCodes(:), nAnimals, 1);
block_label = repmat(string(blockLabels), nAnimals, 1);
lid = reshape(plotData', [], 1);

sourceData = table( ...
    animal_ID, ...
    block, ...
    block_label, ...
    lid, ...
    'VariableNames', {'animal_ID','block','block_label','lid'} ...
);

writetable( ...
    sourceData, ...
    fullfile(outputDir,'SourceData_Figure_S1C_tonic_lid_four_periods.csv') ...
);

%% Export wide plotting data

wideSourceData = array2table( ...
    plotData, ...
    'VariableNames', { ...
        'PRE', ...
        'PAIRING', ...
        'TEST', ...
        'ADDITIONAL_TEST' ...
    } ...
);

wideSourceData = addvars( ...
    wideSourceData, ...
    (1:nAnimals)', ...
    'Before',1, ...
    'NewVariableNames','animal_ID' ...
);

writetable( ...
    wideSourceData, ...
    fullfile(outputDir,'SourceData_Figure_S1C_tonic_lid_four_periods_wide.csv') ...
);

metadata = table( ...
    string('Figure S1C'), ...
    string('conditioning/reappraisal'), ...
    nAnimals, ...
    string('11-40;41-80;81-120;121-160'), ...
    string('LidDiameterMatrix; non-normalized'), ...
    string(inputFile), ...
    'VariableNames', { ...
        'Figure','Cohort','N_Animals','TrialRanges', ...
        'Measure','InputFile' ...
    } ...
);

writetable( ...
    metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S1C_plot.csv') ...
);

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig, outputDir, scriptFile, true);
    catch documentationError
        warning('docDataSrc failed: %s', documentationError.message);
    end
end

exportgraphics( ...
    fig, ...
    fullfile(outputDir,'Figure_S1C_tonic_lid_four_periods.pdf'), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile(outputDir,'Figure_S1C_tonic_lid_four_periods.png'), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

savefig(fig, fullfile(outputDir,'Figure_S1C_tonic_lid_four_periods.fig'));

save( ...
    fullfile(outputDir,'Figure_S1C_tonic_lid_four_periods_complete_results.mat'), ...
    'plotData','trialRanges','blockCodes','blockLabels','plotColor','inputFile' ...
);

fprintf('\nCompleted Supplementary Figure S1C tonic analysis.\n');
fprintf('Periods: PRE / PAIRING / TEST / ADDITIONAL TEST\n');
fprintf('Animals: %d\n', nAnimals);
fprintf('Outputs saved to:\n%s\n', outputDir);
