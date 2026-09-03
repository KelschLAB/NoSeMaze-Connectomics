% panel_B_lid_timecourses.m
% Jonathan Reinwald
%
% Supplementary Figure S1B:
% time course of phasic conditioned eyelid responses in the
% conditioning/reappraisal cohort.
%
% Displayed periods:
%   PRE                 = trials 11-40
%   TEST sub-block 1    = trials 81-100
%   TEST sub-block 2    = trials 101-120
%   TEST sub-block 3    = trials 121-140
%   TEST sub-block 4    = trials 141-160
%
% The pairing block (trials 41-80) is deliberately excluded from the
% displayed time courses and from the reviewer-facing S1B statistics.
%
% Input:
%   data/processed/eyelid/reappraisal/pupil_summary_all.mat
%
% Required field:
%   LidBaseDiameterMatrix_Corrected
%
% Outputs:
%   results/supplement/Figure_S1/Figure_S1B/

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
    repoRoot, 'results', 'supplement', 'Figure_S1', 'Figure_S1B' ...
);

if ~isfile(inputFile)
    error('Figure S1B input file not found:\n%s', inputFile);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Dependencies

requiredHelpers = {'shadedErrorBar', 'SEM_calc'};

for helperIndex = 1:numel(requiredHelpers)
    if isempty(which(requiredHelpers{helperIndex}))
        error('Required helper not found: %s.m', requiredHelpers{helperIndex});
    end
end

%% Load conditioning/reappraisal sessions

loadedData = load(inputFile);

if ~isfield(loadedData, 'summary_all')
    error('Variable "summary_all" missing from:\n%s', inputFile);
end

summary_all = loadedData.summary_all;

% Historical ordering:
% 1 = conditioning/reappraisal, 2 = 1 h post, 3 = 24 h post.
conditioningSessions = summary_all(1:3:end);

if isempty(conditioningSessions)
    error('No conditioning/reappraisal sessions were found.');
end

nAnimals = numel(conditioningSessions);

%% Trial ranges

trialRanges = {
    11:40
    81:100
    101:120
    121:140
    141:160
};

rangeNames = {
    'PRE'
    'TEST 81-100'
    'TEST 101-120'
    'TEST 121-140'
    'TEST 141-160'
};

trialRangeLabels = {
    '11to40'
    '81to100'
    '101to120'
    '121to140'
    '141to160'
};

plotColors = {
    [204/255, 51/255, 204/255]
    [102/255, 194/255, 255/255]
    [0/255,   102/255, 204/255]
    [144/255, 238/255, 144/255]
    [0/255,   128/255, 0/255]
};

lineStyles = {'--','-','-','-','-'};
lineWidth = 1.8;

%% Extract pooled baseline-normalized traces

dataByRange = cell(numel(trialRanges), 1);
animalIDByRange = cell(numel(trialRanges), 1);
trialIDByRange = cell(numel(trialRanges), 1);

for rangeIndex = 1:numel(trialRanges)

    currentRange = trialRanges{rangeIndex};

    dataByRange{rangeIndex} = [];
    animalIDByRange{rangeIndex} = [];
    trialIDByRange{rangeIndex} = [];

    for animalIndex = 1:nAnimals

        if ~isfield( ...
                conditioningSessions(animalIndex), ...
                'LidBaseDiameterMatrix_Corrected' ...
            )
            error( ...
                'LidBaseDiameterMatrix_Corrected missing for animal %d.', ...
                animalIndex ...
            );
        end

        currentMatrix = ...
            conditioningSessions(animalIndex).LidBaseDiameterMatrix_Corrected;

        if size(currentMatrix, 1) < max(currentRange)
            error( ...
                'Animal %d contains only %d trials; trial %d is required.', ...
                animalIndex, size(currentMatrix,1), max(currentRange) ...
            );
        end

        dataByRange{rangeIndex} = [
            dataByRange{rangeIndex};
            currentMatrix(currentRange, :)
        ];

        animalIDByRange{rangeIndex} = [
            animalIDByRange{rangeIndex};
            repmat(animalIndex, numel(currentRange), 1)
        ];

        trialIDByRange{rangeIndex} = [
            trialIDByRange{rangeIndex};
            currentRange(:)
        ];
    end
end

%% Figure

fig = figure( ...
    'Name', 'Figure S1B: phasic eyelid time courses', ...
    'Visible', 'on', ...
    'Color', 'white', ...
    'Position', [100,100,520,420] ...
);

ax = axes(fig);
hold(ax, 'on');

plotHandles = gobjects(numel(trialRanges), 1);

for rangeIndex = 1:numel(trialRanges)

    currentData = dataByRange{rangeIndex};

    meanTrace = mean(currentData, 1, 'omitnan');
    semTrace = SEM_calc(currentData);

    sd = shadedErrorBar( ...
        1:size(currentData,2), ...
        meanTrace, ...
        semTrace ...
    );

    sd.patch.EdgeColor = 'none';
    sd.patch.FaceColor = plotColors{rangeIndex};
    sd.patch.FaceAlpha = 0.20;

    sd.mainLine.Color = plotColors{rangeIndex};
    sd.mainLine.LineWidth = lineWidth;
    sd.mainLine.LineStyle = lineStyles{rangeIndex};

    sd.edge(1).Color = 'none';
    sd.edge(2).Color = 'none';

    plotHandles(rangeIndex) = sd.mainLine;
end

ax.YLim = [0.9, 1.1];
ax.YLabel.String = 'Baseline-normalized eye opening [A.U.]';
ax.XLabel.String = 'Time [s]';

nTimeBins = size(dataByRange{1}, 2);
ax.XTick = 0:20:nTimeBins;
ax.XTickLabel = -2:2:(-2 + 2*(numel(ax.XTick)-1));

ax.FontWeight = 'bold';
ax.LineWidth = 1;
ax.FontSize = 11;
box(ax, 'off');

%% Odor period

odorStart = 20;
odorEnd = 44;

odorPatch = patch( ...
    ax, ...
    [odorStart, odorEnd, odorEnd, odorStart], ...
    [ax.YLim(1), ax.YLim(1), ax.YLim(2), ax.YLim(2)], ...
    [0.2,0.2,0.2], ...
    'FaceAlpha', 0.20, ...
    'EdgeColor', 'none' ...
);

odorPatch.HandleVisibility = 'off';

text( ...
    ax, ...
    odorStart + 1, ...
    ax.YLim(1) + 0.06*diff(ax.YLim), ...
    'Odor', ...
    'Color', [0.2,0.2,0.2] ...
);

legend( ...
    ax, ...
    plotHandles, ...
    rangeNames, ...
    'Location', 'best', ...
    'Box', 'off' ...
);

title(ax, 'Eye-lid opening');

%% Source data

for rangeIndex = 1:numel(trialRanges)

    currentData = dataByRange{rangeIndex};

    timeVariableNames = arrayfun( ...
        @(x) sprintf('timebin_%d', x), ...
        1:size(currentData,2), ...
        'UniformOutput', false ...
    );

    sourceTable = array2table( ...
        currentData, ...
        'VariableNames', timeVariableNames ...
    );

    sourceTable = addvars( ...
        sourceTable, ...
        animalIDByRange{rangeIndex}, ...
        trialIDByRange{rangeIndex}, ...
        'Before', 1, ...
        'NewVariableNames', {'Animal_ID','Trial_ID'} ...
    );

    writetable( ...
        sourceTable, ...
        fullfile( ...
            outputDir, ...
            sprintf( ...
                'SourceData_Figure_S1B_%s.csv', ...
                trialRangeLabels{rangeIndex} ...
            ) ...
        ) ...
    );
end

summaryTable = table();

for rangeIndex = 1:numel(trialRanges)

    currentData = dataByRange{rangeIndex};

    currentSummary = table( ...
        (1:size(currentData,2))', ...
        mean(currentData,1,'omitnan')', ...
        SEM_calc(currentData)', ...
        repmat(string(rangeNames{rangeIndex}), size(currentData,2), 1), ...
        'VariableNames', {'TimeBin','Mean','SEM','Condition'} ...
    );

    summaryTable = [summaryTable; currentSummary]; %#ok<AGROW>
end

writetable( ...
    summaryTable, ...
    fullfile(outputDir,'SourceData_Figure_S1B_group_mean_SEM.csv') ...
);

metadata = table( ...
    string('Figure S1B'), ...
    string('conditioning/reappraisal'), ...
    nAnimals, ...
    string('11-40;81-100;101-120;121-140;141-160'), ...
    string('41-80 excluded'), ...
    string(inputFile), ...
    'VariableNames', { ...
        'Figure','Cohort','N_Animals','DisplayedTrialRanges', ...
        'ExcludedTrials','InputFile' ...
    } ...
);

writetable( ...
    metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S1B_plot.csv') ...
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
    fullfile(outputDir,'Figure_S1B_lid_timecourses.pdf'), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile(outputDir,'Figure_S1B_lid_timecourses.png'), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

savefig(fig, fullfile(outputDir,'Figure_S1B_lid_timecourses.fig'));

save( ...
    fullfile(outputDir,'Figure_S1B_lid_timecourses_complete_results.mat'), ...
    'dataByRange','animalIDByRange','trialIDByRange', ...
    'trialRanges','rangeNames','plotColors','lineStyles','inputFile' ...
);

fprintf('\nCompleted Supplementary Figure S1B.\n');
fprintf('Animals: %d\n', nAnimals);
fprintf('Outputs saved to:\n%s\n', outputDir);
