% panel_D_E_fr_winner_globalGA.m
% Jonathan Reinwald
%
% Supplementary Figure S8D-E
%
% Fraction of wins (fr_winner) versus global graph-network adaptability
% in the conditioning fMRI cohort.
%
% Panel mapping:
%   Figure S8D: fr_winner vs g_delta_C
%   Figure S8E: fr_winner vs g_delta_L
%
% Analysis settings:
%   - conditioning cohort only
%   - proximal CR / TPnoPuff
%   - PRE  = trials 11-40
%   - TEST = trials 81-120
%   - graph-density AUC = 45-50%
%
% For each panel:
%   1. PRE vs TEST network metric
%   2. fr_winner vs PRE and TEST
%   3. fr_winner vs TEST-PRE change
%
% fr_winner is calculated within the relevant 14-day pre-scan hierarchy:
%
%   wins per animal = row sum of DS_info.match_matrix
%   fr_winner        = wins / total wins in that hierarchy
%
% Expected repository inputs:
%
% data/processed/NoSeMaze/
% ├── 01_General_Overview.xlsx
% ├── AnimalNumb_to_ID.mat
% └── tubetest/
%     ├── NoSeMaze_1/
%     │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%     │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%     └── NoSeMaze_2/
%         └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%
% data/processed/fMRI/Figure_4/Figure_4C_E/conditioning/
% ├── auc_struc_TPnoPuff11to40_45to50_p.mat
% └── auc_struc_TPnoPuff81to120_45to50_p.mat
%
% Required helpers under src/matlab/:
%   notBoxPlot_modified.m
%   permutest.m
%   sigstar.m
%
% Optional:
%   docDataSrc.m
%
% Outputs:
%   results/supplement/Figure_S8/Figure_S8D/
%   results/supplement/Figure_S8/Figure_S8E/
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

% repo/figures/supplement/Figure_S8/panel_D_E_fr_winner_globalGA.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot,'src','matlab');

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

noSeMazeDir = fullfile( ...
    repoRoot,'data','processed','NoSeMaze' ...
);

noSeMaze1Dir = fullfile( ...
    noSeMazeDir,'tubetest','NoSeMaze_1' ...
);

noSeMaze2Dir = fullfile( ...
    noSeMazeDir,'tubetest','NoSeMaze_2' ...
);

aucDir = fullfile( ...
    repoRoot,'data','processed','fMRI', ...
    'Figure_4','Figure_4C_E','conditioning' ...
);

resultsBaseDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S8' ...
);

if ~isfolder(resultsBaseDir)
    mkdir(resultsBaseDir);
end

%% Required helpers

requiredFunctions = {
    'notBoxPlot_modified'
    'permutest'
    'sigstar'
};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error([ ...
        'Required MATLAB helper functions not found:\n%s\n\n' ...
        'Place them somewhere under src/matlab/.' ...
    ], ...
        strjoin(missingFunctions,newline) ...
    );
end

if isempty(ver('stats'))
    error([ ...
        'Statistics and Machine Learning Toolbox is required ' ...
        'for corr, ttest and regression lines.' ...
    ]);
end

%% Analysis settings

numberOfPermutations = 10000;
randomSeed = 1234;

preName = 'TPnoPuff11to40';
testName = 'TPnoPuff81to120';

%% Input files

generalOverviewFile = fullfile( ...
    noSeMazeDir,'01_General_Overview.xlsx' ...
);

animalMapFile = fullfile( ...
    noSeMazeDir,'AnimalNumb_to_ID.mat' ...
);

am1EarlyFile = fullfile( ...
    noSeMaze1Dir, ...
    'DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

am1LateFile = fullfile( ...
    noSeMaze1Dir, ...
    'DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

am2File = fullfile( ...
    noSeMaze2Dir, ...
    'DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat' ...
);

aucPreFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_45to50_p.mat',preName) ...
);

aucTestFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_45to50_p.mat',testName) ...
);

requiredFiles = {
    generalOverviewFile
    animalMapFile
    am1EarlyFile
    am1LateFile
    am2File
    aucPreFile
    aucTestFile
};

missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error( ...
        'Required input files are missing:\n\n%s', ...
        strjoin(missingFiles,newline) ...
    );
end

%% Load General Overview

T = readtable( ...
    generalOverviewFile, ...
    'Sheet',9, ...
    'ReadVariableNames',true, ...
    'VariableNamingRule','modify' ...
);

%% Load hierarchy windows and calculate fr_winner

tmp = load(am1EarlyFile,'DS_info');
AM1_early = prepareWinnerFraction(tmp.DS_info);

tmp = load(am1LateFile,'DS_info');
AM1_late = prepareWinnerFraction(tmp.DS_info);

tmp = load(am2File,'DS_info');
AM2 = prepareWinnerFraction(tmp.DS_info);

%% Assign fr_winner to each conditioning MRI animal

animalID = strings(0,1);
frWinner = [];
scanDay = [];

for rowIndex = 1:height(T)

    autonomouse = getNumericScalar(T.Autonomouse(rowIndex));

    if ~ismember(autonomouse,[1,2])
        continue;
    end

    currentID = normalizeAnimalID( ...
        getTableValue(T.AnimalIDCombined,rowIndex) ...
    );

    if autonomouse == 1

        daysValue = normalizeText( ...
            getTableValue(T.DaysToConsider,rowIndex) ...
        );

        if contains(daysValue,'16')

            hierarchy = AM1_early;
            currentScanDay = 1;

        elseif contains(daysValue,'21')

            hierarchy = AM1_late;
            currentScanDay = 2;

        else

            error( ...
                'Could not assign AM1 hierarchy window for animal %s.', ...
                currentID ...
            );
        end

    else

        hierarchy = AM2;
        currentScanDay = 3;
    end

    hierarchyIDs = strings(numel(hierarchy.ID),1);

    for h = 1:numel(hierarchy.ID)
        hierarchyIDs(h) = normalizeAnimalID(hierarchy.ID{h});
    end

    hierarchyIndex = find(hierarchyIDs == currentID);

    if numel(hierarchyIndex) ~= 1
        error( ...
            'Animal ID %s could not be matched uniquely in hierarchy data.', ...
            currentID ...
        );
    end

    animalID(end+1,1) = currentID; %#ok<SAGROW>
    frWinner(end+1,1) = hierarchy.fr_winner(hierarchyIndex); %#ok<SAGROW>
    scanDay(end+1,1) = currentScanDay; %#ok<SAGROW>
end

%% Map IDs to MRI AnimalNumb and sort

mapLoaded = load(animalMapFile);

if ~isfield(mapLoaded,'AnimalNumb_to_ID')
    error( ...
        'Variable AnimalNumb_to_ID missing from:\n%s', ...
        animalMapFile ...
    );
end

AnimalNumb_to_ID = mapLoaded.AnimalNumb_to_ID;

mapIDs = strings(numel(AnimalNumb_to_ID),1);

for mapIndex = 1:numel(AnimalNumb_to_ID)

    mapIDs(mapIndex) = normalizeAnimalID( ...
        AnimalNumb_to_ID(mapIndex).ID ...
    );
end

animalNumber = nan(numel(animalID),1);

for animalIndex = 1:numel(animalID)

    matches = find(mapIDs == animalID(animalIndex));

    if isempty(matches)
        error( ...
            'Animal ID %s not found in AnimalNumb_to_ID.', ...
            animalID(animalIndex) ...
        );
    end

    mappedNumbers = nan(numel(matches),1);

    for matchIndex = 1:numel(matches)

        mappedNumbers(matchIndex) = getNumericScalar( ...
            AnimalNumb_to_ID(matches(matchIndex)).AnimalNumb ...
        );
    end

    mappedNumbers = unique(mappedNumbers);

    if numel(mappedNumbers) ~= 1
        error( ...
            'Animal ID %s maps to multiple AnimalNumb values.', ...
            animalID(animalIndex) ...
        );
    end

    animalNumber(animalIndex) = mappedNumbers;
end

[animalNumberSorted,sortIndex] = sort( ...
    animalNumber,'ascend' ...
);

animalIDSorted = animalID(sortIndex);
frWinnerInput = frWinner(sortIndex);
scanDaySorted = scanDay(sortIndex);

%% Load 45-50% graph AUC data

preLoaded = load(aucPreFile);
testLoaded = load(aucTestFile);

if ~isfield(preLoaded,'auc_struc') || ...
        ~isfield(testLoaded,'auc_struc')

    error('Variable auc_struc missing from PRE or TEST AUC file.');
end

aucPre = preLoaded.auc_struc;
aucTest = testLoaded.auc_struc;

requiredMetrics = {
    'g_delta_C'
    'g_delta_L'
};

for i = 1:numel(requiredMetrics)

    metric = requiredMetrics{i};

    if ~isfield(aucPre,metric) || ~isfield(aucTest,metric)

        error( ...
            'Metric %s missing from PRE or TEST AUC file.', ...
            metric ...
        );
    end
end

deltaCPre = [aucPre.g_delta_C]';
deltaCTest = [aucTest.g_delta_C]';

deltaLPre = [aucPre.g_delta_L]';
deltaLTest = [aucTest.g_delta_L]';

nAnimals = numel(frWinnerInput);

if any([ ...
        numel(deltaCPre), ...
        numel(deltaCTest), ...
        numel(deltaLPre), ...
        numel(deltaLTest) ...
    ] ~= nAnimals)

    error( ...
        'Behavior and graph-data sample sizes do not match.' ...
    );
end

fprintf('\nSupplementary Figure S8D-E\n');
fprintf('Animals: %d\n',nAnimals);
fprintf('Behavior: fr_winner only\n');
fprintf('S8D: g_delta_C\n');
fprintf('S8E: g_delta_L\n\n');

%% Panel definitions

analysis = struct([]);

analysis(1).panel = 'Figure_S8D';
analysis(1).metricField = 'g_delta_C';
analysis(1).metricPre = deltaCPre;
analysis(1).metricTest = deltaCTest;

analysis(2).panel = 'Figure_S8E';
analysis(2).metricField = 'g_delta_L';
analysis(2).metricPre = deltaLPre;
analysis(2).metricTest = deltaLTest;

%% Run S8D and S8E

for analysisIndex = 1:numel(analysis)

    panelName = analysis(analysisIndex).panel;
    metricField = analysis(analysisIndex).metricField;

    metricPre = analysis(analysisIndex).metricPre(:);
    metricTest = analysis(analysisIndex).metricTest(:);
    metricDiff = metricTest - metricPre;

    outputDir = fullfile(resultsBaseDir,panelName);

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    %% Correlations

    [rPre,pPre] = corr( ...
        frWinnerInput,metricPre, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rTest,pTest] = corr( ...
        frWinnerInput,metricTest, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rDiff,pDiff] = corr( ...
        frWinnerInput,metricDiff, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rhoDiff,pSpearmanDiff] = corr( ...
        frWinnerInput,metricDiff, ...
        'Type','Spearman', ...
        'Rows','complete' ...
    );

    %% PRE vs TEST tests

    [hPaired,pPaired,~,pairedStats] = ttest( ...
        metricPre,metricTest ...
    );

    rng(randomSeed,'twister');

    [ ...
        clusters, ...
        permutationPValues, ...
        tSums, ...
        permutationDistribution ...
    ] = permutest( ...
        metricPre', ...
        metricTest', ...
        true, ...
        0.05, ...
        numberOfPermutations, ...
        true ...
    );

    permutationP = getScalarPermutationP( ...
        permutationPValues ...
    );

    %% Figure

    fig = figure( ...
        'Name',sprintf( ...
            '%s | fr_winner | %s', ...
            panelName,metricField), ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,80,1050,720] ...
    );

    %% 1. PRE vs TEST distribution

    subplot(2,3,1);

    bb = notBoxPlot_modified([metricPre,metricTest]);

    formatPreTestNotBoxPlot(bb);

    ax1 = gca;
    box(ax1,'off');

    ylabel(ax1,metricField,'Interpreter','none');

    ax1.XTick = [1,2];
    ax1.XTickLabel = {'Pre','Test'};
    ax1.XLim = [0.5,2.5];

    if contains(metricField,'delta')
        ax1.YLim(1) = 0;
    end

    ax1.FontSize = 10;
    ax1.FontWeight = 'bold';
    ax1.LineWidth = 1;

    if isfinite(permutationP) && permutationP < 0.05

        sigstar({[1,2]},permutationP,0,10);
    end

    text( ...
        ax1, ...
        ax1.XLim(1) + 0.10*diff(ax1.XLim), ...
        ax1.YLim(1) + 0.20*diff(ax1.YLim), ...
        sprintf('p_{perm} = %.4g',permutationP), ...
        'Interpreter','tex' ...
    );

    %% 2. fr_winner vs PRE and TEST

    subplot(2,3,[2,3]);

    scatterPre = scatter( ...
        frWinnerInput,metricPre,40,'filled' ...
    );

    hold on;

    scatterTest = scatter( ...
        frWinnerInput,metricTest,40,'filled' ...
    );

    scatterPre.MarkerEdgeColor = 'none';
    scatterTest.MarkerEdgeColor = 'none';

    scatterPre.MarkerFaceColor = [204/255,51/255,204/255];
    scatterTest.MarkerFaceColor = [0,160/255,227/255];

    ax2 = gca;
    box(ax2,'off');
    axis(ax2,'square');

    xlabel(ax2,'Fraction of wins');
    ylabel(ax2,metricField,'Interpreter','none');

    ax2.XLim(1) = 0;

    if contains(metricField,'delta')
        ax2.YLim(1) = 0;
    end

    if ax1.YLim(2) > ax2.YLim(2)
        ax2.YLim(2) = ax1.YLim(2);
    end

    ax2.FontSize = 10;
    ax2.FontWeight = 'bold';
    ax2.LineWidth = 1;

    lineHandles = lsline;

    if numel(lineHandles) >= 2

        lineHandles(1).Color = [0,160/255,227/255];
        lineHandles(1).LineWidth = 1;

        lineHandles(2).Color = [204/255,51/255,204/255];
        lineHandles(2).LineWidth = 1;
    end

    addCorrelationText( ...
        ax2,rPre,pPre,rTest,pTest ...
    );

    %% 3. fr_winner vs TEST-PRE

    subplot(2,3,[5,6]);

    diffColor = ...
        ([204/255,51/255,204/255] + ...
         [0,160/255,227/255])./2;

    scatterDiff = scatter( ...
        frWinnerInput,metricDiff,40,'filled' ...
    );

    scatterDiff.MarkerEdgeColor = 'none';
    scatterDiff.MarkerFaceColor = diffColor;

    ax3 = gca;
    box(ax3,'off');
    axis(ax3,'square');

    xlabel(ax3,'Fraction of wins');

    ylabel( ...
        ax3, ...
        {metricField,'Test - Pre'}, ...
        'Interpreter','none' ...
    );

    ax3.XLim(1) = 0;

    ax3.FontSize = 10;
    ax3.FontWeight = 'bold';
    ax3.LineWidth = 1;

    diffLine = lsline;
    diffLine.Color = diffColor;
    diffLine.LineWidth = 1;

    addDifferenceCorrelationText( ...
        ax3, ...
        rDiff,pDiff, ...
        rhoDiff,pSpearmanDiff ...
    );

    sgtitle( ...
        sprintf( ...
            '%s | fr_winner | %s', ...
            panelName,metricField ...
        ), ...
        'Interpreter','none' ...
    );

    %% Source data

    sourceData = table( ...
        animalIDSorted, ...
        animalNumberSorted, ...
        scanDaySorted, ...
        frWinnerInput, ...
        metricPre, ...
        metricTest, ...
        metricDiff, ...
        'VariableNames', {
            'AnimalID'
            'AnimalNumber'
            'ScanDay'
            'FractionWins'
            'Pre'
            'Test'
            'Delta_TestMinusPre'
        } ...
    );

    writetable( ...
        sourceData, ...
        fullfile( ...
            outputDir, ...
            sprintf('SourceData_%s_fr_winner_%s.csv', ...
                panelName,metricField) ...
        ) ...
    );

    %% Statistics

    statisticsTable = table( ...
        [
            "Pearson_fr_winner_vs_PRE"
            "Pearson_fr_winner_vs_TEST"
            "Pearson_fr_winner_vs_delta"
            "Spearman_fr_winner_vs_delta"
            "Paired_PRE_vs_TEST_ttest"
            "Paired_PRE_vs_TEST_permutation"
        ], ...
        [
            rPre
            rTest
            rDiff
            rhoDiff
            pairedStats.tstat
            NaN
        ], ...
        [
            pPre
            pTest
            pDiff
            pSpearmanDiff
            pPaired
            permutationP
        ], ...
        'VariableNames', {
            'Statistic'
            'Estimate'
            'P'
        } ...
    );

    writetable( ...
        statisticsTable, ...
        fullfile( ...
            outputDir, ...
            sprintf('Statistics_%s_fr_winner_%s.csv', ...
                panelName,metricField) ...
        ) ...
    );

    %% Complete result

    result = struct;

    result.panel = panelName;
    result.metric = metricField;
    result.behavior = 'fr_winner';

    result.animalID = animalIDSorted;
    result.animalNumber = animalNumberSorted;
    result.scanDay = scanDaySorted;

    result.fr_winner = frWinnerInput;

    result.pre = metricPre;
    result.test = metricTest;
    result.delta = metricDiff;

    result.correlation.pre = [rPre,pPre];
    result.correlation.test = [rTest,pTest];
    result.correlation.deltaPearson = [rDiff,pDiff];
    result.correlation.deltaSpearman = [rhoDiff,pSpearmanDiff];

    result.pairedTTest.h = hPaired;
    result.pairedTTest.p = pPaired;
    result.pairedTTest.stats = pairedStats;

    result.permutation.clusters = clusters;
    result.permutation.pValues = permutationPValues;
    result.permutation.p = permutationP;
    result.permutation.tSums = tSums;
    result.permutation.distribution = permutationDistribution;
    result.permutation.numberOfPermutations = numberOfPermutations;
    result.permutation.randomSeed = randomSeed;

    result.sourceData = sourceData;
    result.statisticsTable = statisticsTable;

    save( ...
        fullfile( ...
            outputDir, ...
            sprintf('Results_%s_fr_winner_%s.mat', ...
                panelName,metricField) ...
        ), ...
        'result' ...
    );

    %% Optional provenance

    if ~isempty(which('docDataSrc'))

        try

            docDataSrc( ...
                fig,outputDir,scriptFile,true ...
            );

        catch documentationError

            warning( ...
                'docDataSrc failed: %s', ...
                documentationError.message ...
            );
        end
    end

    %% Export

    outputBaseName = sprintf( ...
        '%s_fr_winner_%s', ...
        panelName,metricField ...
    );

    exportgraphics( ...
        fig, ...
        fullfile(outputDir,[outputBaseName '.pdf']), ...
        'ContentType','vector', ...
        'BackgroundColor','white' ...
    );

    exportgraphics( ...
        fig, ...
        fullfile(outputDir,[outputBaseName '.png']), ...
        'Resolution',300, ...
        'BackgroundColor','white' ...
    );

    savefig( ...
        fig, ...
        fullfile(outputDir,[outputBaseName '.fig']) ...
    );

    fprintf( ...
        'Completed %s: fr_winner vs %s\n', ...
        panelName,metricField ...
    );
end

fprintf('\nSupplementary Figure S8D-E completed.\n');
fprintf('Results saved under:\n%s\n',resultsBaseDir);


%% ========================================================================
% Local functions
%% ========================================================================

function hierarchy = prepareWinnerFraction(DS_info)
% Calculate fraction of all tube-test wins contributed by each animal.

    hierarchy = DS_info;

    winCounts = sum( ...
        hierarchy.match_matrix, ...
        2 ...
    );

    totalWins = sum(winCounts);

    if totalWins == 0
        error('Hierarchy match_matrix contains zero total wins.');
    end

    hierarchy.fr_winner = ...
        winCounts ./ totalWins;
end


function formatPreTestNotBoxPlot(bb)

    for index = 1:numel(bb)

        bb(index).data.MarkerSize = 4;
        bb(index).data.MarkerEdgeColor = 'none';

        bb(index).semPtch.EdgeColor = 'none';
        bb(index).sdPtch.EdgeColor = 'none';
    end

    % PRE
    bb(1).data.MarkerFaceColor = [204/255,51/255,204/255];
    bb(1).mu.Color = [204/255,51/255,204/255];
    bb(1).semPtch.FaceColor = [255/255,102/255,204/255];
    bb(1).sdPtch.FaceColor = [255/255,204/255,204/255];

    % TEST
    bb(2).data.MarkerFaceColor = [0,160/255,227/255];
    bb(2).mu.Color = [0,160/255,227/255];
    bb(2).semPtch.FaceColor = [75/255,207/255,227/255];
    bb(2).sdPtch.FaceColor = [150/255,255/255,227/255];
end


function addCorrelationText(ax,rPre,pPre,rTest,pTest)

    xLeft = ax.XLim(1) + 0.10*diff(ax.XLim);
    xRight = ax.XLim(1) + 0.55*diff(ax.XLim);

    yPre = ax.YLim(1) + 0.10*diff(ax.YLim);
    yTest = ax.YLim(1) + 0.20*diff(ax.YLim);

    preColor = [204/255,51/255,204/255];
    testColor = [0,160/255,227/255];

    text(ax,xLeft,yPre,sprintf('p = %.3g',pPre), ...
        'Color',preColor,'FontWeight','bold');

    text(ax,xRight,yPre,sprintf('r = %.3f',rPre), ...
        'Color',preColor,'FontWeight','bold');

    text(ax,xLeft,yTest,sprintf('p = %.3g',pTest), ...
        'Color',testColor,'FontWeight','bold');

    text(ax,xRight,yTest,sprintf('r = %.3f',rTest), ...
        'Color',testColor,'FontWeight','bold');
end


function addDifferenceCorrelationText( ...
    ax,rPearson,pPearson,rhoSpearman,pSpearman ...
)

    plotColor = ...
        ([204/255,51/255,204/255] + ...
         [0,160/255,227/255])./2;

    xLeft = ax.XLim(1) + 0.10*diff(ax.XLim);
    xRight = ax.XLim(1) + 0.55*diff(ax.XLim);

    yPearson = ax.YLim(1) + 0.10*diff(ax.YLim);
    ySpearman = ax.YLim(1) + 0.20*diff(ax.YLim);

    text(ax,xLeft,yPearson,sprintf('p = %.3g',pPearson), ...
        'Color',plotColor,'FontWeight','bold');

    text(ax,xRight,yPearson,sprintf('r = %.3f',rPearson), ...
        'Color',plotColor,'FontWeight','bold');

    text(ax,xLeft,ySpearman,sprintf('p_s = %.3g',pSpearman), ...
        'Color',plotColor,'FontWeight','bold', ...
        'Interpreter','tex');

    text(ax,xRight,ySpearman,sprintf('\rho_s = %.3f',rhoSpearman), ...
        'Color',plotColor,'FontWeight','bold', ...
        'Interpreter','tex');
end


function p = getScalarPermutationP(pValues)

    if isempty(pValues)
        p = NaN;
        return;
    end

    pValues = pValues(:);

    if numel(pValues) > 1

        warning([ ...
            'permutest returned %d p-values. ' ...
            'Using the smallest p-value.' ...
        ], ...
            numel(pValues) ...
        );
    end

    p = min(pValues);
end


function value = getTableValue(variable,rowIndex)

    if iscell(variable)
        value = variable{rowIndex};
    else
        value = variable(rowIndex);
    end
end


function value = normalizeAnimalID(rawValue)

    while iscell(rawValue)

        if numel(rawValue) ~= 1
            error('Animal ID cell contains more than one element.');
        end

        rawValue = rawValue{1};
    end

    if iscategorical(rawValue)
        rawValue = string(rawValue);
    end

    value = upper(strtrim(string(rawValue)));

    if numel(value) ~= 1 || ...
            ismissing(value) || ...
            strlength(value) == 0

        error( ...
            'Could not convert an Animal ID to a valid string.' ...
        );
    end
end


function value = normalizeText(rawValue)

    while iscell(rawValue)

        if numel(rawValue) ~= 1
            error('Text cell contains more than one element.');
        end

        rawValue = rawValue{1};
    end

    value = strtrim(string(rawValue));
end


function value = getNumericScalar(rawValue)

    while iscell(rawValue)

        if numel(rawValue) ~= 1
            error('Numeric cell contains more than one element.');
        end

        rawValue = rawValue{1};
    end

    if isnumeric(rawValue)
        value = double(rawValue);
    else
        value = str2double(string(rawValue));
    end

    if numel(value) ~= 1 || ~isfinite(value)
        error( ...
            'Could not convert value to one finite numeric scalar.' ...
        );
    end
end
