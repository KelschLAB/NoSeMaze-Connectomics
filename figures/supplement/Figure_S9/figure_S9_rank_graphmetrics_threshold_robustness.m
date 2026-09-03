% figure_S9_rank_graphmetrics_threshold_robustness.m
% Jonathan Reinwald
%
% Supplementary Figure S9
%
% Conditioning cohort only.
% TPNoPuff PRE  = trials 11-40
% TPNoPuff TEST = trials 81-120
%
% Panel definitions:
%   Figure S9A: Rank, 45-50% sparsity
%   Figure S9B: Rank, 10-50% sparsity
%   Figure S9C: Rank, 40-50% sparsity
%   Figure S9D: z-scored David's score (DSz), 45-50% sparsity
%
% Metrics in every panel:
%   g_delta_C
%   g_delta_L
%   g_swp
%
% LAYOUT OF EACH PANEL
% --------------------
% Top row:
%   PRE and TEST shown together versus Rank / DSz
%
% Bottom row:
%   TEST-PRE change shown separately versus Rank / DSz
%
% Columns:
%   Delta C | Delta L | SWP
%
% Thus every Figure S9 panel is a 2 x 3 figure:
%
%            Delta C        Delta L        SWP
% PRE/TEST     ...            ...          ...
% DELTA        ...            ...          ...
%
% Raw Pearson p-values are displayed.
% FDR q-values are calculated across the three predefined graph metrics
% separately for PRE, TEST, and TEST-PRE.
%
% Expected AUC files:
%
% data/processed/fMRI/Figure_S9/conditioning/
% ├── auc_struc_TPnoPuff11to40_45to50_p.mat
% ├── auc_struc_TPnoPuff81to120_45to50_p.mat
% ├── auc_struc_TPnoPuff11to40_10to50_p.mat
% ├── auc_struc_TPnoPuff81to120_10to50_p.mat
% ├── auc_struc_TPnoPuff11to40_40to50_p.mat
% └── auc_struc_TPnoPuff81to120_40to50_p.mat
%
% Recommended script location:
%   figures/supplement/Figure_S9/
%   figure_S9_rank_graphmetrics_threshold_robustness.m
%
% Outputs:
%   results/supplement/Figure_S9/
%   ├── Figure_S9A/
%   ├── Figure_S9B/
%   ├── Figure_S9C/
%   └── Figure_S9D/
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

% repo/figures/supplement/Figure_S9/<script>.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository paths

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
    'Figure_S9','conditioning' ...
);

resultsBaseDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S9' ...
);

if ~isfolder(resultsBaseDir)
    mkdir(resultsBaseDir);
end

%% Required hierarchy / mapping files

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

%% AUC files

preName  = 'TPnoPuff11to40';
testName = 'TPnoPuff81to120';

auc45PreFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_45to50_p.mat',preName) ...
);

auc45TestFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_45to50_p.mat',testName) ...
);

auc10PreFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_10to50_p.mat',preName) ...
);

auc10TestFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_10to50_p.mat',testName) ...
);

auc40PreFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_40to50_p.mat',preName) ...
);

auc40TestFile = fullfile( ...
    aucDir, ...
    sprintf('auc_struc_%s_40to50_p.mat',testName) ...
);

requiredFiles = {
    generalOverviewFile
    animalMapFile
    am1EarlyFile
    am1LateFile
    am2File
    auc45PreFile
    auc45TestFile
    auc10PreFile
    auc10TestFile
    auc40PreFile
    auc40TestFile
};

missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error( ...
        'Required input files are missing:\n\n%s', ...
        strjoin(missingFiles,newline) ...
    );
end

if isempty(ver('stats'))
    error([ ...
        'Statistics and Machine Learning Toolbox is required ' ...
        'for corr and zscore.' ...
    ]);
end

%% Reconstruct Rank and DSz

T = readtable( ...
    generalOverviewFile, ...
    'Sheet',9, ...
    'ReadVariableNames',true, ...
    'VariableNamingRule','modify' ...
);

tmp = load(am1EarlyFile,'DS_info');
AM1_early = prepareHierarchy(tmp.DS_info);

tmp = load(am1LateFile,'DS_info');
AM1_late = prepareHierarchy(tmp.DS_info);

tmp = load(am2File,'DS_info');
AM2 = prepareHierarchy(tmp.DS_info);

animalID = strings(0,1);
animalNumberOverview = [];
rankValue = [];
dszValue = [];
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
                'Could not assign hierarchy window for AM1 animal %s.', ...
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
            'Animal ID %s could not be matched uniquely.', ...
            currentID ...
        );
    end

    animalID(end+1,1) = currentID; %#ok<SAGROW>

    animalNumberOverview(end+1,1) = ...
        getNumericScalar(T.AnimalNumber(rowIndex)); %#ok<SAGROW>

    rankValue(end+1,1) = ...
        hierarchy.Rank(hierarchyIndex); %#ok<SAGROW>

    dszValue(end+1,1) = ...
        hierarchy.DSz(hierarchyIndex); %#ok<SAGROW>

    scanDay(end+1,1) = currentScanDay; %#ok<SAGROW>
end

%% Map IDs to MRI AnimalNumb and sort

mapLoaded = load(animalMapFile);

if ~isfield(mapLoaded,'AnimalNumb_to_ID')
    error( ...
        'AnimalNumb_to_ID missing from:\n%s', ...
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

animalNumberMapped = nan(numel(animalID),1);

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

    animalNumberMapped(animalIndex) = mappedNumbers;
end

if ~isequal(animalNumberMapped,animalNumberOverview)

    warning([ ...
        'AnimalNumber from General Overview differs from AnimalNumb_to_ID ' ...
        'for at least one animal. MRI mapping is used for sorting.' ...
    ]);
end

[animalNumberSorted,sortIndex] = sort( ...
    animalNumberMapped,'ascend' ...
);

animalIDSorted = animalID(sortIndex);
rankInput = rankValue(sortIndex);
dszInput = dszValue(sortIndex);
scanDaySorted = scanDay(sortIndex);

%% Load AUC datasets

auc45 = loadAucPair(auc45PreFile,auc45TestFile);
auc10 = loadAucPair(auc10PreFile,auc10TestFile);
auc40 = loadAucPair(auc40PreFile,auc40TestFile);

metricFields = {
    'g_delta_C'
    'g_delta_L'
    'g_swp'
};

metricLabels = {
    '\DeltaC'
    '\DeltaL'
    'SWP'
};

allAuc = {auc45,auc10,auc40};

for a = 1:numel(allAuc)

    for m = 1:numel(metricFields)

        fieldName = metricFields{m};

        if ~isfield(allAuc{a}.pre,fieldName) || ...
                ~isfield(allAuc{a}.test,fieldName)

            error( ...
                'Metric %s missing from one of the AUC datasets.', ...
                fieldName ...
            );
        end
    end
end

%% Validate graph-data sample sizes

nAnimals = numel([auc45.pre.g_delta_C]);

if numel(rankInput) ~= nAnimals || numel(dszInput) ~= nAnimals
    error([ ...
        'Behavior sample size does not match graph-data sample size: ' ...
        'Rank n=%d, DSz n=%d, graph n=%d.' ...
    ], ...
        numel(rankInput),numel(dszInput),nAnimals ...
    );
end

for a = 1:numel(allAuc)

    for m = 1:numel(metricFields)

        fieldName = metricFields{m};

        nPre = numel([allAuc{a}.pre.(fieldName)]);
        nTest = numel([allAuc{a}.test.(fieldName)]);

        if nPre ~= nAnimals || nTest ~= nAnimals
            error([ ...
                'Sample-size mismatch for %s in AUC dataset %d: ' ...
                'PRE n=%d, TEST n=%d, expected n=%d.' ...
            ], ...
                fieldName,a,nPre,nTest,nAnimals ...
            );
        end
    end
end

%% Panel definitions

panels = struct([]);

panels(1).name = 'Figure_S9A';
panels(1).displayName = 'Figure S9A | Rank | 45-50%';
panels(1).predictorName = 'Rank';
panels(1).predictor = rankInput;
panels(1).auc = auc45;
panels(1).threshold = '45-50';
panels(1).preFile = auc45PreFile;
panels(1).testFile = auc45TestFile;

panels(2).name = 'Figure_S9B';
panels(2).displayName = 'Figure S9B | Rank | 10-50%';
panels(2).predictorName = 'Rank';
panels(2).predictor = rankInput;
panels(2).auc = auc10;
panels(2).threshold = '10-50';
panels(2).preFile = auc10PreFile;
panels(2).testFile = auc10TestFile;

panels(3).name = 'Figure_S9C';
panels(3).displayName = 'Figure S9C | Rank | 40-50%';
panels(3).predictorName = 'Rank';
panels(3).predictor = rankInput;
panels(3).auc = auc40;
panels(3).threshold = '40-50';
panels(3).preFile = auc40PreFile;
panels(3).testFile = auc40TestFile;

panels(4).name = 'Figure_S9D';
panels(4).displayName = 'Figure S9D | David''s score (z) | 45-50%';
panels(4).predictorName = 'DSz';
panels(4).predictor = dszInput;
panels(4).auc = auc45;
panels(4).threshold = '45-50';
panels(4).preFile = auc45PreFile;
panels(4).testFile = auc45TestFile;

%% Colors

preColor = [204/255,51/255,204/255];
testColor = [0,160/255,227/255];
diffColor = (preColor + testColor)./2;

%% Calculate correlations and FDR

stats = struct;

for p = 1:numel(panels)

    predictor = panels(p).predictor(:);

    for m = 1:numel(metricFields)

        metric = metricFields{m};

        pre = [panels(p).auc.pre.(metric)]';
        test = [panels(p).auc.test.(metric)]';
        delta = test - pre;

        [rPre,pPre] = corr( ...
            predictor,pre, ...
            'Type','Pearson', ...
            'Rows','complete' ...
        );

        [rTest,pTest] = corr( ...
            predictor,test, ...
            'Type','Pearson', ...
            'Rows','complete' ...
        );

        [rDelta,pDelta] = corr( ...
            predictor,delta, ...
            'Type','Pearson', ...
            'Rows','complete' ...
        );

        stats(p).metric(m).field = metric;

        stats(p).metric(m).pre = pre;
        stats(p).metric(m).test = test;
        stats(p).metric(m).delta = delta;

        stats(p).metric(m).rPre = rPre;
        stats(p).metric(m).pPre = pPre;

        stats(p).metric(m).rTest = rTest;
        stats(p).metric(m).pTest = pTest;

        stats(p).metric(m).rDelta = rDelta;
        stats(p).metric(m).pDelta = pDelta;
    end

    % FDR across Delta C, Delta L and SWP separately for each phase.
    qPre = bhFdr(arrayfun(@(x) x.pPre,stats(p).metric));
    qTest = bhFdr(arrayfun(@(x) x.pTest,stats(p).metric));
    qDelta = bhFdr(arrayfun(@(x) x.pDelta,stats(p).metric));

    for m = 1:numel(metricFields)

        stats(p).metric(m).qPre = qPre(m);
        stats(p).metric(m).qTest = qTest(m);
        stats(p).metric(m).qDelta = qDelta(m);
    end
end

%% Create each Figure S9 panel separately

for p = 1:numel(panels)

    panelOutputDir = fullfile( ...
        resultsBaseDir, ...
        panels(p).name ...
    );

    if ~isfolder(panelOutputDir)
        mkdir(panelOutputDir);
    end

    predictor = panels(p).predictor(:);

    fig = figure( ...
        'Name',panels(p).displayName, ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[80,80,1200,760] ...
    );

    tl = tiledlayout( ...
        fig, ...
        2,3, ...
        'TileSpacing','compact', ...
        'Padding','compact' ...
    );

    %% ------------------------------------------------------------
    % TOP ROW: PRE + TEST
    % -------------------------------------------------------------

    for m = 1:numel(metricFields)

        ax = nexttile(tl,m);

        s = stats(p).metric(m);

        hold(ax,'on');

        scPre = scatter( ...
            ax,predictor,s.pre,40,'filled' ...
        );

        scTest = scatter( ...
            ax,predictor,s.test,40,'filled' ...
        );

        scPre.MarkerEdgeColor = 'none';
        scTest.MarkerEdgeColor = 'none';

        scPre.MarkerFaceColor = preColor;
        scTest.MarkerFaceColor = testColor;

        addRegressionLine( ...
            ax,predictor,s.pre,preColor ...
        );

        addRegressionLine( ...
            ax,predictor,s.test,testColor ...
        );

        formatPredictorAxis(ax,panels(p).predictorName);

        ylabel( ...
            ax, ...
            metricLabels{m}, ...
            'Interpreter','tex' ...
        );

        title( ...
            ax, ...
            sprintf('%s | PRE + TEST',metricLabels{m}), ...
            'Interpreter','tex' ...
        );

        annotatePreTest( ...
            ax,s,preColor,testColor ...
        );

        if m == 1

            legend( ...
                ax, ...
                [scPre,scTest], ...
                {'Pre','Test'}, ...
                'Location','best', ...
                'Box','off' ...
            );
        end

        hold(ax,'off');
    end

    %% ------------------------------------------------------------
    % BOTTOM ROW: TEST - PRE
    % -------------------------------------------------------------

    for m = 1:numel(metricFields)

        ax = nexttile(tl,3+m);

        s = stats(p).metric(m);

        hold(ax,'on');

        scDelta = scatter( ...
            ax,predictor,s.delta,40,'filled' ...
        );

        scDelta.MarkerEdgeColor = 'none';
        scDelta.MarkerFaceColor = diffColor;

        addRegressionLine( ...
            ax,predictor,s.delta,diffColor ...
        );

        formatPredictorAxis(ax,panels(p).predictorName);

        ylabel( ...
            ax, ...
            sprintf('%s (Test - Pre)',metricLabels{m}), ...
            'Interpreter','tex' ...
        );

        title( ...
            ax, ...
            sprintf('%s | TEST - PRE',metricLabels{m}), ...
            'Interpreter','tex' ...
        );

        annotateDelta(ax,s,diffColor);

        hold(ax,'off');
    end

    title( ...
        tl, ...
        panels(p).displayName, ...
        'Interpreter','none', ...
        'FontWeight','bold' ...
    );

    %% Source data for this panel

    sourceData = buildPanelSourceData( ...
        panels(p), ...
        stats(p), ...
        metricFields, ...
        animalIDSorted, ...
        animalNumberSorted, ...
        scanDaySorted ...
    );

    writetable( ...
        sourceData, ...
        fullfile( ...
            panelOutputDir, ...
            sprintf('SourceData_%s.csv',panels(p).name) ...
        ) ...
    );

    %% Statistics for this panel

    statisticsTable = buildPanelStatistics( ...
        panels(p), ...
        stats(p), ...
        metricFields ...
    );

    writetable( ...
        statisticsTable, ...
        fullfile( ...
            panelOutputDir, ...
            sprintf('Statistics_%s.csv',panels(p).name) ...
        ) ...
    );

    %% Save analysis metadata

    metadata = table( ...
        string(panels(p).name), ...
        string(panels(p).predictorName), ...
        string(panels(p).threshold), ...
        nAnimals, ...
        string(preName), ...
        string(testName), ...
        string(strjoin(metricFields, ',')), ...
        string('Pearson'), ...
        string('BH FDR separately across g_delta_C, g_delta_L, g_swp for PRE, TEST, TEST-PRE'), ...
        string(makeRepoRelative(panels(p).preFile,repoRoot)), ...
        string(makeRepoRelative(panels(p).testFile,repoRoot)), ...
        'VariableNames', { ...
            'Panel'
            'Predictor'
            'SparsityRangePercent'
            'NumberOfAnimals'
            'PRE'
            'TEST'
            'Metrics'
            'CorrelationType'
            'MultipleTestingCorrection'
            'PreAucFile'
            'TestAucFile'
        } ...
    );

    writetable( ...
        metadata, ...
        fullfile( ...
            panelOutputDir, ...
            sprintf('AnalysisMetadata_%s.csv',panels(p).name) ...
        ) ...
    );

    %% Save result

    result = struct;

    result.panel = panels(p).name;
    result.predictorName = panels(p).predictorName;
    result.predictor = predictor;
    result.sparsityRange = panels(p).threshold;

    result.metricFields = metricFields;
    result.statistics = stats(p);

    result.AnimalID = animalIDSorted;
    result.AnimalNumber = animalNumberSorted;
    result.ScanDay = scanDaySorted;

    result.preAucFile = makeRepoRelative( ...
        panels(p).preFile,repoRoot ...
    );

    result.testAucFile = makeRepoRelative( ...
        panels(p).testFile,repoRoot ...
    );

    result.sourceData = sourceData;
    result.statisticsTable = statisticsTable;
    result.metadata = metadata;

    save( ...
        fullfile( ...
            panelOutputDir, ...
            sprintf('Results_%s.mat',panels(p).name) ...
        ), ...
        'result' ...
    );

    %% Optional provenance

    if ~isempty(which('docDataSrc'))

        try
            docDataSrc( ...
                fig, ...
                panelOutputDir, ...
                scriptFile, ...
                true ...
            );
        catch documentationError

            warning( ...
                'docDataSrc failed: %s', ...
                documentationError.message ...
            );
        end
    end

    %% Export

    exportgraphics( ...
        fig, ...
        fullfile( ...
            panelOutputDir, ...
            [panels(p).name '.pdf'] ...
        ), ...
        'ContentType','vector', ...
        'BackgroundColor','white' ...
    );

    exportgraphics( ...
        fig, ...
        fullfile( ...
            panelOutputDir, ...
            [panels(p).name '.png'] ...
        ), ...
        'Resolution',300, ...
        'BackgroundColor','white' ...
    );

    savefig( ...
        fig, ...
        fullfile( ...
            panelOutputDir, ...
            [panels(p).name '.fig'] ...
        ) ...
    );

    fprintf('Completed %s.\n',panels(p).name);
end

fprintf('\nSupplementary Figure S9 completed.\n');
fprintf('Results saved under:\n%s\n',resultsBaseDir);


%% ========================================================================
% Local functions
%% ========================================================================

function hierarchy = prepareHierarchy(DS_info)

    hierarchy = DS_info;

    [~,sortedIndex] = sort( ...
        [hierarchy.DS], ...
        'descend' ...
    );

    [~,rank] = sort(sortedIndex);

    hierarchy.Rank = rank(:);

    ds = [hierarchy.DS]';
    hierarchy.DSz = zscore(ds);
end


function pair = loadAucPair(preFile,testFile)

    preLoaded = load(preFile);
    testLoaded = load(testFile);

    if ~isfield(preLoaded,'auc_struc')
        error( ...
            'Variable auc_struc missing from:\n%s', ...
            preFile ...
        );
    end

    if ~isfield(testLoaded,'auc_struc')
        error( ...
            'Variable auc_struc missing from:\n%s', ...
            testFile ...
        );
    end

    pair.pre = preLoaded.auc_struc;
    pair.test = testLoaded.auc_struc;
end


function formatPredictorAxis(ax,predictorName)

    box(ax,'off');
    axis(ax,'square');

    ax.FontSize = 10;
    ax.FontWeight = 'bold';
    ax.LineWidth = 1;

    if strcmp(predictorName,'Rank')

        xlabel(ax,'Rank');

        ax.XLim = [1,12];
        ax.XTick = 1:12;

    else

        xlabel(ax,'David''s score (z)');
    end
end


function addRegressionLine(ax,x,y,lineColor)

    valid = isfinite(x) & isfinite(y);

    if sum(valid) < 2
        return;
    end

    coefficients = polyfit( ...
        x(valid), ...
        y(valid), ...
        1 ...
    );

    xFit = linspace( ...
        min(x(valid)), ...
        max(x(valid)), ...
        100 ...
    );

    yFit = polyval(coefficients,xFit);

    plot( ...
        ax, ...
        xFit, ...
        yFit, ...
        'Color',lineColor, ...
        'LineWidth',1.2 ...
    );
end


function annotatePreTest(ax,s,preColor,testColor)

    preMarker = '';
    testMarker = '';

    if s.qPre < 0.05
        preMarker = ' \dagger';
    end

    if s.qTest < 0.05
        testMarker = ' \dagger';
    end

    x = ax.XLim(1) + 0.05*diff(ax.XLim);

    yBottom = ax.YLim(1);
    yRange = diff(ax.YLim);

    text( ...
        ax, ...
        x, ...
        yBottom + 0.14*yRange, ...
        sprintf( ...
            'Pre: r = %.2f, p = %.3g%s', ...
            s.rPre,s.pPre,preMarker ...
        ), ...
        'Color',preColor, ...
        'FontSize',8, ...
        'Interpreter','tex' ...
    );

    text( ...
        ax, ...
        x, ...
        yBottom + 0.06*yRange, ...
        sprintf( ...
            'Test: r = %.2f, p = %.3g%s', ...
            s.rTest,s.pTest,testMarker ...
        ), ...
        'Color',testColor, ...
        'FontSize',8, ...
        'Interpreter','tex' ...
    );
end


function annotateDelta(ax,s,diffColor)

    deltaMarker = '';

    if s.qDelta < 0.05
        deltaMarker = ' \dagger';
    end

    x = ax.XLim(1) + 0.05*diff(ax.XLim);

    yBottom = ax.YLim(1);
    yRange = diff(ax.YLim);

    text( ...
        ax, ...
        x, ...
        yBottom + 0.07*yRange, ...
        sprintf( ...
            'r = %.2f, p = %.3g%s', ...
            s.rDelta,s.pDelta,deltaMarker ...
        ), ...
        'Color',diffColor, ...
        'FontSize',8, ...
        'Interpreter','tex' ...
    );
end


function tableOut = buildPanelSourceData( ...
    panel, ...
    panelStats, ...
    metricFields, ...
    animalIDs, ...
    animalNumbers, ...
    scanDay ...
)

    rows = {};

    predictor = panel.predictor(:);

    for m = 1:numel(metricFields)

        s = panelStats.metric(m);

        for i = 1:numel(predictor)

            rows(end+1,:) = { ... %#ok<SAGROW>
                panel.name, ...
                panel.threshold, ...
                panel.predictorName, ...
                metricFields{m}, ...
                animalIDs(i), ...
                animalNumbers(i), ...
                scanDay(i), ...
                predictor(i), ...
                s.pre(i), ...
                s.test(i), ...
                s.delta(i) ...
            };
        end
    end

    tableOut = cell2table( ...
        rows, ...
        'VariableNames', {
            'Panel'
            'SparsityRange'
            'Predictor'
            'Metric'
            'AnimalID'
            'AnimalNumber'
            'ScanDay'
            'PredictorValue'
            'Pre'
            'Test'
            'TestMinusPre'
        } ...
    );
end


function tableOut = buildPanelStatistics( ...
    panel, ...
    panelStats, ...
    metricFields ...
)

    rows = {};

    for m = 1:numel(metricFields)

        s = panelStats.metric(m);

        rows(end+1,:) = { ... %#ok<SAGROW>
            panel.name, ...
            panel.threshold, ...
            panel.predictorName, ...
            metricFields{m}, ...
            'PRE', ...
            s.rPre, ...
            s.pPre, ...
            s.qPre ...
        };

        rows(end+1,:) = { ... %#ok<SAGROW>
            panel.name, ...
            panel.threshold, ...
            panel.predictorName, ...
            metricFields{m}, ...
            'TEST', ...
            s.rTest, ...
            s.pTest, ...
            s.qTest ...
        };

        rows(end+1,:) = { ... %#ok<SAGROW>
            panel.name, ...
            panel.threshold, ...
            panel.predictorName, ...
            metricFields{m}, ...
            'TEST_minus_PRE', ...
            s.rDelta, ...
            s.pDelta, ...
            s.qDelta ...
        };
    end

    tableOut = cell2table( ...
        rows, ...
        'VariableNames', {
            'Panel'
            'SparsityRange'
            'Predictor'
            'Metric'
            'Phase'
            'PearsonR'
            'RawP'
            'FDR_Q_across_3_metrics'
        } ...
    );
end


function q = bhFdr(p)

    originalSize = size(p);

    p = p(:);
    q = nan(size(p));

    valid = isfinite(p);

    if ~any(valid)

        q = reshape(q,originalSize);
        return;
    end

    pv = p(valid);
    m = numel(pv);

    [ps,order] = sort(pv,'ascend');

    qs = ps .* m ./ (1:m)';
    qs = flipud(cummin(flipud(qs)));
    qs(qs > 1) = 1;

    qValid = nan(m,1);
    qValid(order) = qs;

    q(valid) = qValid;
    q = reshape(q,originalSize);
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
        error('Could not convert value to one finite numeric scalar.');
    end
end


function rel = makeRepoRelative(pathString,repoRoot)

    p = strrep(char(pathString),'\','/');
    r = strrep(char(repoRoot),'\','/');

    if startsWith(lower(p),lower(r))

        rel = extractAfter( ...
            string(p), ...
            strlength(r) ...
        );

        rel = regexprep(rel,'^[\\/]+','');

    else

        rel = string(p);
    end
end
