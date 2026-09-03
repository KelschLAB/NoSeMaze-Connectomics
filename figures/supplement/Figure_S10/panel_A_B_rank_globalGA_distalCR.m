% panel_A_B_rank_globalGA_distalCR.m
% Jonathan Reinwald
%
% Supplementary Figure S10
%
% Social rank versus global graph-network measures at the DISTAL CR.
%
% Restricted to:
%   - conditioning cohort only
%   - social Rank only
%   - g_delta_C  -> Figure S10A
%   - g_delta_L  -> Figure S10B
%   - threshold indices 36:41 (= displayed density range 45-50%)
%
% For each metric the script retains the original three-part layout:
%   1. PRE vs TEST network metric
%   2. Rank vs PRE and TEST
%   3. Rank vs TEST-PRE change
%
% IMPORTANT
% ---------
% The AUC files used here must be the DISTAL-CR graph-analysis outputs,
% not the proximal-CR files used for Figures 4 and 5.
%
% Expected repository structure:
%
% NoSeMaze-Connectomics/
% ├── figures/supplement/Figure_S10/
% │   └── panel_A_B_rank_globalGA_distalCR.m
% │
% ├── data/processed/NoSeMaze/
% │   ├── 01_General_Overview.xlsx
% │   ├── AnimalNumb_to_ID.mat
% │   └── tubetest/
% │       ├── NoSeMaze_1/
% │       │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │       │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │       └── NoSeMaze_2/
% │           └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
% │
% ├── data/processed/fMRI/Figure_S10/
% │   ├── auc_struc_Odor11to40_45to50_p.mat
% │   └── auc_struc_Odor81to120_45to50_p.mat
% │
% ├── src/matlab/
% │   ├── notBoxPlot_modified.m
% │   ├── permutest.m
% │   ├── sigstar.m
% │   └── docDataSrc.m              (optional)
% │
% └── results/supplement/Figure_S10/
%     ├── Figure_S10A/
%     └── Figure_S10B/
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

% repository/figures/supplement/Figure_S10/panel_A_B_rank_globalGA_distalCR.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot,'src','matlab');

noSeMazeDir = fullfile( ...
    repoRoot, ...
    'data','processed','NoSeMaze' ...
);

noSeMaze1Dir = fullfile( ...
    noSeMazeDir, ...
    'tubetest','NoSeMaze_1' ...
);

noSeMaze2Dir = fullfile( ...
    noSeMazeDir, ...
    'tubetest','NoSeMaze_2' ...
);

% Distal-CR AUC files are deliberately stored separately from the
% proximal-CR Figure 4/5 AUC files.
aucDir = fullfile( ...
    repoRoot, ...
    'data','processed','fMRI', ...
    'Figure_S10' ...
);

resultsBaseDir = fullfile( ...
    repoRoot, ...
    'results','supplement', ...
    'Figure_S10' ...
);

%% Add repository MATLAB helpers

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

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
        'for corr, ttest and lsline.' ...
    ]);
end

%% Fixed analysis settings

minThresholdIndex = 36;
maxThresholdIndex = 41;

% Historical display convention = threshold index + 9
thresholdDisplayMin = minThresholdIndex + 9;
thresholdDisplayMax = maxThresholdIndex + 9;

preName = 'Odor11to40';
testName = 'Odor81to120';

numberOfPermutations = 10000;
randomSeed = 1234;

metricFields = {
    'g_delta_C'
    'g_delta_L'
    'g_swp'
};

%% Input files: hierarchy / animal information

generalOverviewFile = fullfile( ...
    noSeMazeDir, ...
    '01_General_Overview.xlsx' ...
);

animalMapFile = fullfile( ...
    noSeMazeDir, ...
    'AnimalNumb_to_ID.mat' ...
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

%% Input files: DISTAL CR graph-metric AUC

aucPreFile = fullfile( ...
    aucDir, ...
    sprintf( ...
        'auc_struc_%s_%dto%d_p.mat', ...
        preName, ...
        thresholdDisplayMin, ...
        thresholdDisplayMax ...
    ) ...
);

aucTestFile = fullfile( ...
    aucDir, ...
    sprintf( ...
        'auc_struc_%s_%dto%d_p.mat', ...
        testName, ...
        thresholdDisplayMin, ...
        thresholdDisplayMax ...
    ) ...
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

if ~isfolder(resultsBaseDir)
    mkdir(resultsBaseDir);
end

%% Reconstruct Rank from hierarchy files

T = readtable( ...
    generalOverviewFile, ...
    'Sheet',9, ...
    'ReadVariableNames',true, ...
    'VariableNamingRule','modify' ...
);

tmp = load(am1EarlyFile,'DS_info');
DS_AM1_early = prepareHierarchy(tmp.DS_info);

tmp = load(am1LateFile,'DS_info');
DS_AM1_late = prepareHierarchy(tmp.DS_info);

tmp = load(am2File,'DS_info');
DS_AM2 = prepareHierarchy(tmp.DS_info);

%% Build animal-wise rank information

info = struct;
counter = 0;

for rowIndex = 1:height(T)

    autonomouse = T.Autonomouse(rowIndex);

    if ~ismember(autonomouse,[1,2])
        continue;
    end

    counter = counter + 1;

    animalID = normalizeAnimalID( ...
        getTableValue(T.AnimalIDCombined,rowIndex) ...
    );

    info.ID{counter,1} = char(animalID);
    info.NoSeMaze(counter,1) = autonomouse;

    if autonomouse == 1

        daysValue = normalizeText( ...
            getTableValue(T.DaysToConsider,rowIndex) ...
        );

        if contains(daysValue,'16')
            hierarchy = DS_AM1_early;
            info.ScanDay(counter,1) = 1;

        elseif contains(daysValue,'21')
            hierarchy = DS_AM1_late;
            info.ScanDay(counter,1) = 2;

        else
            error( ...
                'Could not assign AM1 hierarchy window for animal %s.', ...
                animalID ...
            );
        end

    else

        hierarchy = DS_AM2;
        info.ScanDay(counter,1) = 3;
    end

    hierarchyIDs = strings(numel(hierarchy.ID),1);

    for h = 1:numel(hierarchy.ID)
        hierarchyIDs(h) = normalizeAnimalID(hierarchy.ID{h});
    end

    animalIndex = find(hierarchyIDs == animalID);

    if numel(animalIndex) ~= 1
        error( ...
            'Animal ID %s could not be matched uniquely in hierarchy data.', ...
            animalID ...
        );
    end

    info.Rank(counter,1) = hierarchy.Rank(animalIndex);
end

%% Map animal IDs to MRI animal numbers and sort

mapLoaded = load(animalMapFile);

if ~isfield(mapLoaded,'AnimalNumb_to_ID')
    error( ...
        'Variable "AnimalNumb_to_ID" missing from:\n%s', ...
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

animalNumbers = nan(counter,1);

for animalIndex = 1:counter

    targetID = normalizeAnimalID(info.ID{animalIndex});
    mapMatch = find(mapIDs == targetID);

    if isempty(mapMatch)
        error( ...
            'Animal ID %s was not found in AnimalNumb_to_ID.', ...
            targetID ...
        );
    end

    mappedNumbers = nan(numel(mapMatch),1);

    for matchIndex = 1:numel(mapMatch)

        mappedNumbers(matchIndex) = getAnimalNumber( ...
            AnimalNumb_to_ID(mapMatch(matchIndex)).AnimalNumb ...
        );
    end

    uniqueMappedNumbers = unique(mappedNumbers);

    if numel(uniqueMappedNumbers) ~= 1
        error( ...
            'Animal ID %s maps to multiple AnimalNumb values.', ...
            targetID ...
        );
    end

    animalNumbers(animalIndex) = uniqueMappedNumbers;
end

[animalNumbersSorted,sortIndex] = sort(animalNumbers,'ascend');

animalIDsSorted = string(info.ID(sortIndex));
rankInput = info.Rank(sortIndex);
scanDaySorted = info.ScanDay(sortIndex);

%% Load DISTAL CR graph metric AUC structures

preLoaded = load(aucPreFile);
testLoaded = load(aucTestFile);

if ~isfield(preLoaded,'auc_struc')
    error('Variable "auc_struc" missing from DISTAL PRE AUC file.');
end

if ~isfield(testLoaded,'auc_struc')
    error('Variable "auc_struc" missing from DISTAL TEST AUC file.');
end

aucPre = preLoaded.auc_struc;
aucTest = testLoaded.auc_struc;

%% Verify only requested metrics

for metricIndex = 1:numel(metricFields)

    fieldName = metricFields{metricIndex};

    if ~isfield(aucPre,fieldName) || ~isfield(aucTest,fieldName)
        error( ...
            'Required graph metric "%s" is missing from PRE or TEST AUC file.', ...
            fieldName ...
        );
    end
end

%% Extract Delta C / Delta L / SWP

deltaCPre = [aucPre.g_delta_C]';
deltaCTest = [aucTest.g_delta_C]';

deltaLPre = [aucPre.g_delta_L]';
deltaLTest = [aucTest.g_delta_L]';

swpPre = [aucPre.g_swp]';
swpTest = [aucTest.g_swp]';

nGraphAnimals = numel(deltaCPre);

if any([ ...
        numel(deltaCTest), ...
        numel(deltaLPre), ...
        numel(deltaLTest), ...
        numel(swpPre), ...
        numel(swpTest) ...
    ] ~= nGraphAnimals)

    error('The distal-CR graph metric vectors have unequal sample sizes.');
end

if numel(rankInput) ~= nGraphAnimals
    error([ ...
        'Behavior/MRI sample-size mismatch: Rank n=%d, graph n=%d.' ...
    ], ...
        numel(rankInput), ...
        nGraphAnimals ...
    );
end

fprintf('\nSupplementary Figure S10 input check\n');
fprintf('CR: DISTAL\n');
fprintf('Threshold indices: %d:%d\n', ...
    minThresholdIndex,maxThresholdIndex);
fprintf('Displayed density range: %d-%d\n', ...
    thresholdDisplayMin,thresholdDisplayMax);
fprintf('Animals: %d\n',nGraphAnimals);
fprintf('Metrics plotted: g_delta_C, g_delta_L; internal FDR metric: g_swp\n');
fprintf('Behavior: Rank only\n\n');

%% Rank-correlation FDR across Delta C / Delta L / SWP
%
% The manuscript defines these three global metrics as one multiple-
% testing family. SWP is not plotted in Figure S10, but contributes to
% FDR correction for Rank-vs-PRE, Rank-vs-TEST and Rank-vs-TEST-PRE.

allMetricPre = {
    deltaCPre
    deltaLPre
    swpPre
};

allMetricTest = {
    deltaCTest
    deltaLTest
    swpTest
};

rawPPre = nan(3,1);
rawPTest = nan(3,1);
rawPDiff = nan(3,1);

for metricIndex = 1:3

    currentPre = allMetricPre{metricIndex};
    currentTest = allMetricTest{metricIndex};
    currentDiff = currentTest - currentPre;

    [~,rawPPre(metricIndex)] = corr( ...
        rankInput,currentPre, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [~,rawPTest(metricIndex)] = corr( ...
        rankInput,currentTest, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [~,rawPDiff(metricIndex)] = corr( ...
        rankInput,currentDiff, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );
end

[qPre,fdrSigPre] = bhFdrAdjustedP(rawPPre,0.05);
[qTest,fdrSigTest] = bhFdrAdjustedP(rawPTest,0.05);
[qDiff,fdrSigDiff] = bhFdrAdjustedP(rawPDiff,0.05);

%% Define Figure S10 analyses

analysis = struct([]);

% Figure S10A: Rank vs Delta C
analysis(1).panel = 'Figure_S10A';
analysis(1).metricField = 'g_delta_C';
analysis(1).metricPre = deltaCPre;
analysis(1).metricTest = deltaCTest;
analysis(1).fdrMetricIndex = 1;

% Figure S10B: Rank vs Delta L
analysis(2).panel = 'Figure_S10B';
analysis(2).metricField = 'g_delta_L';
analysis(2).metricPre = deltaLPre;
analysis(2).metricTest = deltaLTest;
analysis(2).fdrMetricIndex = 2;

%% Run analyses

for analysisIndex = 1:numel(analysis)

    panelName = analysis(analysisIndex).panel;
    metricField = analysis(analysisIndex).metricField;

    metricPre = analysis(analysisIndex).metricPre(:);
    metricTest = analysis(analysisIndex).metricTest(:);
    metricDiff = metricTest - metricPre;

    fdrMetricIndex = analysis(analysisIndex).fdrMetricIndex;

    qPreCurrent = qPre(fdrMetricIndex);
    qTestCurrent = qTest(fdrMetricIndex);
    qDiffCurrent = qDiff(fdrMetricIndex);

    fdrPreCurrent = fdrSigPre(fdrMetricIndex);
    fdrTestCurrent = fdrSigTest(fdrMetricIndex);
    fdrDiffCurrent = fdrSigDiff(fdrMetricIndex);

    outputDir = fullfile(resultsBaseDir,panelName);

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    %% Rank correlations

    [rPre,pPre] = corr( ...
        rankInput,metricPre, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rTest,pTest] = corr( ...
        rankInput,metricTest, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rDiff,pDiff] = corr( ...
        rankInput,metricDiff, ...
        'Type','Pearson', ...
        'Rows','complete' ...
    );

    [rhoDiff,pSpearmanDiff] = corr( ...
        rankInput,metricDiff, ...
        'Type','Spearman', ...
        'Rows','complete' ...
    );

    %% PRE vs TEST

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
        'Name', ...
        sprintf('%s | distal CR | %s | Rank', ...
            panelName,metricField), ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,80,1050,720] ...
    );

    %% 1. PRE vs TEST

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

    %% 2. Rank vs PRE and TEST

    subplot(2,3,[2,3]);

    scatterPre = scatter(rankInput,metricPre,40,'filled');
    hold on;
    scatterTest = scatter(rankInput,metricTest,40,'filled');

    scatterPre.MarkerEdgeColor = 'none';
    scatterTest.MarkerEdgeColor = 'none';

    scatterPre.MarkerFaceColor = [204/255,51/255,204/255];
    scatterTest.MarkerFaceColor = [0,160/255,227/255];

    ax2 = gca;
    box(ax2,'off');
    axis(ax2,'square');

    xlabel(ax2,'Rank');
    ylabel(ax2,metricField,'Interpreter','none');

    ax2.XLim = [1,12];
    ax2.XTick = 1:12;

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
        ax2, ...
        rPre,pPre,fdrPreCurrent, ...
        rTest,pTest,fdrTestCurrent ...
    );

    %% 3. Rank vs TEST-PRE change

    subplot(2,3,[5,6]);

    diffColor = ...
        ([204/255,51/255,204/255] + [0,160/255,227/255]) ./ 2;

    scatterDiff = scatter( ...
        rankInput,metricDiff,40,'filled' ...
    );

    scatterDiff.MarkerEdgeColor = 'none';
    scatterDiff.MarkerFaceColor = diffColor;

    ax3 = gca;
    box(ax3,'off');
    axis(ax3,'square');

    xlabel(ax3,'Rank');

    ylabel( ...
        ax3, ...
        {metricField,'Test - Pre'}, ...
        'Interpreter','none' ...
    );

    ax3.XLim = [1,12];
    ax3.XTick = 1:12;

    ax3.FontSize = 10;
    ax3.FontWeight = 'bold';
    ax3.LineWidth = 1;

    diffLine = lsline;
    diffLine.Color = diffColor;
    diffLine.LineWidth = 1;

    addDifferenceCorrelationText( ...
        ax3, ...
        rDiff,pDiff,fdrDiffCurrent, ...
        rhoDiff,pSpearmanDiff ...
    );

    sgtitle( ...
        sprintf('%s | distal CR | %s | Rank', ...
            panelName,metricField), ...
        'Interpreter','none' ...
    );

    %% Source data

    sourceData = table( ...
        animalIDsSorted, ...
        animalNumbersSorted, ...
        scanDaySorted, ...
        rankInput, ...
        metricPre, ...
        metricTest, ...
        metricDiff, ...
        'VariableNames', {
            'AnimalID'
            'AnimalNumber'
            'ScanDay'
            'Rank'
            'Pre'
            'Test'
            'Delta_TestMinusPre'
        } ...
    );

    writetable( ...
        sourceData, ...
        fullfile( ...
            outputDir, ...
            sprintf( ...
                'SourceData_%s_%s_Rank.csv', ...
                panelName,metricField ...
            ) ...
        ) ...
    );

    %% Statistics

    statisticsTable = table( ...
        [
            "Pearson_Rank_vs_PRE"
            "Pearson_Rank_vs_TEST"
            "Pearson_Rank_vs_delta"
            "Spearman_Rank_vs_delta"
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
        [
            qPreCurrent
            qTestCurrent
            qDiffCurrent
            NaN
            NaN
            NaN
        ], ...
        [
            fdrPreCurrent
            fdrTestCurrent
            fdrDiffCurrent
            false
            false
            false
        ], ...
        'VariableNames', {
            'Statistic'
            'Estimate'
            'P'
            'FDR_Q_across_DeltaC_DeltaL_SWP'
            'FDR_Significant'
        } ...
    );

    writetable( ...
        statisticsTable, ...
        fullfile( ...
            outputDir, ...
            sprintf( ...
                'Statistics_%s_%s_Rank.csv', ...
                panelName,metricField ...
            ) ...
        ) ...
    );

    %% Complete result

    result = struct;

    result.panel = panelName;
    result.CR = 'distal';
    result.metric = metricField;
    result.behavior = 'Rank';

    result.thresholdIndices = [ ...
        minThresholdIndex,maxThresholdIndex ...
    ];

    result.thresholdDisplay = [ ...
        thresholdDisplayMin,thresholdDisplayMax ...
    ];

    result.animalIDs = animalIDsSorted;
    result.animalNumbers = animalNumbersSorted;
    result.scanDay = scanDaySorted;

    result.Rank = rankInput;
    result.pre = metricPre;
    result.test = metricTest;
    result.delta = metricDiff;

    result.correlation.pre = [rPre,pPre];
    result.correlation.test = [rTest,pTest];
    result.correlation.deltaPearson = [rDiff,pDiff];
    result.correlation.deltaSpearman = [rhoDiff,pSpearmanDiff];

    result.correlationFDR.pre.q = qPreCurrent;
    result.correlationFDR.pre.significant = fdrPreCurrent;

    result.correlationFDR.test.q = qTestCurrent;
    result.correlationFDR.test.significant = fdrTestCurrent;

    result.correlationFDR.delta.q = qDiffCurrent;
    result.correlationFDR.delta.significant = fdrDiffCurrent;

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

    result.aucPreFile = makeRepoRelative(aucPreFile,repoRoot);
    result.aucTestFile = makeRepoRelative(aucTestFile,repoRoot);

    save( ...
        fullfile( ...
            outputDir, ...
            sprintf( ...
                'Results_%s_%s_Rank.mat', ...
                panelName,metricField ...
            ) ...
        ), ...
        'result' ...
    );

    %% Optional provenance

    if ~isempty(which('docDataSrc'))
        try
            docDataSrc(fig,outputDir,scriptFile,true);
        catch documentationError
            warning( ...
                'docDataSrc failed: %s', ...
                documentationError.message ...
            );
        end
    end

    %% Export

    outputBaseName = sprintf( ...
        '%s_%s_Rank_distalCR', ...
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

    fprintf( ...
        'Completed %s: Rank vs %s at distal CR\n', ...
        panelName,metricField ...
    );
end

fdrSummary = table( ...
    ["deltaC";"deltaL";"SWP"], ...
    ["g_delta_C";"g_delta_L";"g_swp"], ...
    rawPPre,qPre,fdrSigPre, ...
    rawPTest,qTest,fdrSigTest, ...
    rawPDiff,qDiff,fdrSigDiff, ...
    'VariableNames', { ...
        'Metric'
        'AUC_Structure_Field'
        'Rank_PRE_P_Raw'
        'Rank_PRE_FDR_Q'
        'Rank_PRE_FDR_Significant'
        'Rank_TEST_P_Raw'
        'Rank_TEST_FDR_Q'
        'Rank_TEST_FDR_Significant'
        'Rank_Delta_P_Raw'
        'Rank_Delta_FDR_Q'
        'Rank_Delta_FDR_Significant'
    } ...
);

writetable( ...
    fdrSummary, ...
    fullfile( ...
        resultsBaseDir, ...
        'Figure_S10_Rank_GlobalMetrics_FDR_Summary.csv' ...
    ) ...
);

fprintf('\nCompleted Supplementary Figure S10 analyses.\n');
fprintf('Results saved under:\n%s\n',resultsBaseDir);


%% ========================================================================
% Local functions
%% ========================================================================

function hierarchy = prepareHierarchy(DS_info)

    hierarchy = DS_info;

    [~,sortedIndex] = sort([hierarchy.DS],'descend');
    [~,rank] = sort(sortedIndex);

    hierarchy.Rank = rank;
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

    if numel(value) ~= 1 || ismissing(value) || strlength(value) == 0
        error('Could not convert an Animal ID to a valid string.');
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


function number = getAnimalNumber(rawNumber)

    while iscell(rawNumber)
        if numel(rawNumber) ~= 1
            error('AnimalNumb cell contains more than one element.');
        end
        rawNumber = rawNumber{1};
    end

    if isstring(rawNumber) || ischar(rawNumber) || iscategorical(rawNumber)
        number = str2double(string(rawNumber));
    else
        number = double(rawNumber);
    end

    if numel(number) ~= 1 || ~isfinite(number)
        error('Could not convert AnimalNumb to one finite numeric value.');
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
            'permutest returned %d p-values. ' ...
            'Using the smallest p-value.' ...
        ],numel(pValues));
    end

    p = min(pValues);
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


function addCorrelationText( ...
    ax,rPre,pPre,fdrPre,rTest,pTest,fdrTest ...
)

    xLeft = ax.XLim(1) + 0.10*diff(ax.XLim);
    xRight = ax.XLim(1) + 0.55*diff(ax.XLim);

    yPre = ax.YLim(1) + 0.10*diff(ax.YLim);
    yTest = ax.YLim(1) + 0.20*diff(ax.YLim);

    preLabel = sprintf('p = %.3g',pPre);
    testLabel = sprintf('p = %.3g',pTest);

    if fdrPre
        preLabel = [preLabel '  \dagger'];
    end

    if fdrTest
        testLabel = [testLabel '  \dagger'];
    end

    text(ax,xLeft,yPre,preLabel, ...
        'Color',[204/255,51/255,204/255], ...
        'FontWeight','bold', ...
        'Interpreter','tex');

    text(ax,xRight,yPre,sprintf('r = %.3f',rPre), ...
        'Color',[204/255,51/255,204/255], ...
        'FontWeight','bold');

    text(ax,xLeft,yTest,testLabel, ...
        'Color',[0,160/255,227/255], ...
        'FontWeight','bold', ...
        'Interpreter','tex');

    text(ax,xRight,yTest,sprintf('r = %.3f',rTest), ...
        'Color',[0,160/255,227/255], ...
        'FontWeight','bold');
end


function addDifferenceCorrelationText( ...
    ax,rPearson,pPearson,fdrPearson,rhoSpearman,pSpearman ...
)

    plotColor = ...
        ([204/255,51/255,204/255] + [0,160/255,227/255]) ./ 2;

    xLeft = ax.XLim(1) + 0.10*diff(ax.XLim);
    xRight = ax.XLim(1) + 0.55*diff(ax.XLim);

    yPearson = ax.YLim(1) + 0.10*diff(ax.YLim);
    ySpearman = ax.YLim(1) + 0.20*diff(ax.YLim);

    pearsonLabel = sprintf('p = %.3g',pPearson);

    if fdrPearson
        pearsonLabel = [pearsonLabel '  \dagger'];
    end

    text(ax,xLeft,yPearson,pearsonLabel, ...
        'Color',plotColor,'FontWeight','bold', ...
        'Interpreter','tex');

    text(ax,xRight,yPearson,sprintf('r = %.3f',rPearson), ...
        'Color',plotColor,'FontWeight','bold');

    text(ax,xLeft,ySpearman,sprintf('p_s = %.3g',pSpearman), ...
        'Color',plotColor,'FontWeight','bold', ...
        'Interpreter','tex');

    text(ax,xRight,ySpearman,sprintf('\rho_s = %.3f',rhoSpearman), ...
        'Color',plotColor,'FontWeight','bold', ...
        'Interpreter','tex');
end



function [qValues,significant] = bhFdrAdjustedP(pValues,alpha)
% Benjamini-Hochberg FDR-adjusted p-values.

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
            adjustedSorted(index), ...
            adjustedSorted(index+1) ...
        );
    end

    adjustedSorted = min(adjustedSorted,1);

    adjustedFinite = nan(m,1);
    adjustedFinite(sortIndex) = adjustedSorted;

    qValues(finiteMask) = adjustedFinite;
    significant(finiteMask) = adjustedFinite <= alpha;
end


function rel = makeRepoRelative(pathString,repoRoot)

    p = strrep(char(pathString),'\','/');
    r = strrep(char(repoRoot),'\','/');

    if startsWith(lower(p),lower(r))
        rel = extractAfter(string(p),strlength(r));
        rel = regexprep(rel,'^[\\/]+','');
    else
        rel = string(p);
    end
end
