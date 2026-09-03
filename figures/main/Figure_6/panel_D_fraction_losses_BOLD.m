% panel_D_fraction_losses_BOLD.m
% Jonathan Reinwald
%
% Figure 6D: fraction of tube-test losses vs BOLD extracted from the
% fraction-loss-sensitive vHC cluster shown in Figure 6C.
%
% Reuses the existing NoSeMaze hierarchy data. The only new input is the
% mean-beta result MAT for the Figure 6C cluster. Copy that file into the
% Figure_6D folder and rename it:
%
%   beta_fraction_losses_vHC_T01.mat
%
% The MAT file must contain:
%   res.mean_betaNeg   % PRE
%   res.mean_betaPos   % TEST

clear;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

srcDir = fullfile(repoRoot,'src','matlab');
addpath(genpath(srcDir));

noSeMazeDir = fullfile(repoRoot,'data','processed','NoSeMaze');
noSeMaze1Dir = fullfile(noSeMazeDir,'tubetest','NoSeMaze_1');
noSeMaze2Dir = fullfile(noSeMazeDir,'tubetest','NoSeMaze_2');

inputDir = fullfile(repoRoot,'data','processed','fMRI','Figure_6','Figure_6D');
outputDir = fullfile(repoRoot,'results','main','Figure_6','Figure_6D');
if ~isfolder(outputDir), mkdir(outputDir); end

generalOverviewFile = fullfile(noSeMazeDir,'01_General_Overview.xlsx');
animalMapFile = fullfile(noSeMazeDir,'AnimalNumb_to_ID.mat');

am1EarlyFile = fullfile(noSeMaze1Dir, ...
    'DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat');
am1LateFile = fullfile(noSeMaze1Dir, ...
    'DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat');
am2File = fullfile(noSeMaze2Dir, ...
    'DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat');

betaFile = fullfile(inputDir,'beta_fraction_losses_vHC_T01.mat');

requiredFiles = {generalOverviewFile,animalMapFile,am1EarlyFile,am1LateFile,am2File,betaFile};
missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));
if ~isempty(missingFiles)
    error('Required files missing:\n%s',strjoin(missingFiles,newline));
end

T = readtable(generalOverviewFile,'Sheet',9,'ReadVariableNames',true, ...
    'VariableNamingRule','modify');

tmp=load(am1EarlyFile,'DS_info'); AM1early=prepareHierarchy(tmp.DS_info);
tmp=load(am1LateFile,'DS_info');  AM1late=prepareHierarchy(tmp.DS_info);
tmp=load(am2File,'DS_info');      AM2=prepareHierarchy(tmp.DS_info);

animalID = strings(0,1);
animalNumberOverview = [];
frLoser = [];

for rowIndex=1:height(T)
    autoValue=T.Autonomouse(rowIndex);
    if ~ismember(autoValue,[1,2]), continue; end

    currentID=normalizeAnimalID(T.AnimalIDCombined(rowIndex));

    if autoValue==1
        daysValue=normalizeText(T.DaysToConsider(rowIndex));
        if contains(daysValue,'16')
            hierarchy=AM1early;
        elseif contains(daysValue,'21')
            hierarchy=AM1late;
        else
            error('Could not assign AM1 window for %s.',currentID);
        end
    else
        hierarchy=AM2;
    end

    ids=upper(strtrim(string(hierarchy.ID(:))));
    idx=find(ids==currentID);
    if numel(idx)~=1
        error('Animal %s not uniquely found in hierarchy.',currentID);
    end

    animalID(end+1,1)=currentID; %#ok<SAGROW>
    animalNumberOverview(end+1,1)=getNumericScalar(T.AnimalNumber(rowIndex)); %#ok<SAGROW>
    frLoser(end+1,1)=hierarchy.fr_loser(idx); %#ok<SAGROW>
end

mapLoaded=load(animalMapFile);
AnimalNumb_to_ID=mapLoaded.AnimalNumb_to_ID;

mapIDs=strings(numel(AnimalNumb_to_ID),1);
for i=1:numel(AnimalNumb_to_ID)
    mapIDs(i)=normalizeAnimalID(AnimalNumb_to_ID(i).ID);
end

animalNumberMapped=nan(numel(animalID),1);
for i=1:numel(animalID)
    matches=find(mapIDs==animalID(i));
    if isempty(matches), error('ID %s missing from AnimalNumb_to_ID.',animalID(i)); end

    nums=nan(numel(matches),1);
    for j=1:numel(matches)
        nums(j)=getNumericScalar(AnimalNumb_to_ID(matches(j)).AnimalNumb);
    end
    nums=unique(nums);
    if numel(nums)~=1, error('ID %s maps ambiguously.',animalID(i)); end
    animalNumberMapped(i)=nums;
end

[animalNumberSorted,sortIdx]=sort(animalNumberMapped,'ascend');
animalIDSorted=animalID(sortIdx);
frLoserInput=frLoser(sortIdx);

[betaPre,betaTest,betaDiff]=extractBetaVectors(betaFile);

if numel(frLoserInput)~=numel(betaPre)
    error('Sample-size mismatch: fr_loser n=%d; beta n=%d.', ...
        numel(frLoserInput),numel(betaPre));
end

fprintf('Figure 6D: n=%d\n',numel(frLoserInput));

makeFigure('Figure_6D','FractionLosses',frLoserInput,betaPre,betaTest, ...
    outputDir,10000,1234,scriptFile);

sourceData=table(animalIDSorted,animalNumberSorted,frLoserInput, ...
    betaPre,betaTest,betaDiff, ...
    'VariableNames',{'AnimalID','AnimalNumber','FractionLosses', ...
    'BOLD_Pre','BOLD_Test','BOLD_TestMinusPre'});
writetable(sourceData,fullfile(outputDir,'SourceData_Figure_6D.csv'));


%% ========================================================================
% Local functions
%% ========================================================================

function hierarchy = prepareHierarchy(DS_info)
    hierarchy = DS_info;

    [~, sortedIndex] = sort([hierarchy.DS], 'descend');
    [~, rank] = sort(sortedIndex);
    hierarchy.Rank = rank;

    nLosses = sum(hierarchy.match_matrix, 1)';
    totalLosses = sum(nLosses);

    if totalLosses == 0
        error('Hierarchy match_matrix contains zero total losses.');
    end

    hierarchy.fr_loser = nLosses ./ totalLosses;
end

function value = normalizeAnimalID(rawValue)
    while iscell(rawValue)
        if numel(rawValue) ~= 1
            error('Animal ID cell contains more than one element.');
        end
        rawValue = rawValue{1};
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

function p = getScalarPermutationP(pValues)
    if isempty(pValues)
        p = NaN;
        return;
    end

    pValues = pValues(:);

    if numel(pValues) > 1
        warning(['permutest returned %d p-values. ' ...
            'Using the smallest p-value.'], numel(pValues));
    end

    p = min(pValues);
end

function [betaPre, betaTest, betaDiff] = extractBetaVectors(betaFile)
    loaded = load(betaFile);

    if ~isfield(loaded, 'res')
        error('Variable "res" missing from beta file:\n%s', betaFile);
    end

    res = loaded.res;

    if ~isfield(res, 'mean_betaNeg') || ~isfield(res, 'mean_betaPos')
        error(['Expected res.mean_betaNeg and res.mean_betaPos are ' ...
            'missing from:\n%s'], betaFile);
    end

    betaPre = [res.mean_betaNeg]';
    betaTest = [res.mean_betaPos]';
    betaDiff = betaTest - betaPre;
end

function makeFigure(panelName, predictorName, predictor, betaPre, betaTest, ...
    outputDir, numberOfPermutations, randomSeed, scriptFile)

    betaDiff = betaTest - betaPre;

    [rPreP, pPreP] = corr(predictor, betaPre, 'Type','Pearson', 'Rows','complete');
    [rPreS, pPreS] = corr(predictor, betaPre, 'Type','Spearman', 'Rows','complete');
    [rTestP, pTestP] = corr(predictor, betaTest, 'Type','Pearson', 'Rows','complete');
    [rTestS, pTestS] = corr(predictor, betaTest, 'Type','Spearman', 'Rows','complete');
    [rDiffP, pDiffP] = corr(predictor, betaDiff, 'Type','Pearson', 'Rows','complete');
    [rDiffS, pDiffS] = corr(predictor, betaDiff, 'Type','Spearman', 'Rows','complete');

    [hPaired, pPaired, ~, pairedStats] = ttest(betaPre, betaTest);

    rng(randomSeed, 'twister');
    [clusters, pPermValues, tSums, permDist] = permutest( ...
        betaPre', betaTest', true, 0.05, numberOfPermutations, true);
    pPerm = getScalarPermutationP(pPermValues);

    preColor = [204/255, 51/255, 204/255];
    testColor = [0, 160/255, 227/255];
    diffColor = (preColor + testColor) ./ 2;

    fig = figure( ...
        'Name', sprintf('%s: %s vs BOLD', panelName, predictorName), ...
        'Visible','on', 'Color','white', ...
        'Position',[100,80,1050,720]);

    % PRE vs TEST
    subplot(2,3,1);
    bb = notBoxPlot_modified([betaPre,betaTest]);

    for i = 1:numel(bb)
        bb(i).data.MarkerSize = 6;
        bb(i).data.MarkerEdgeColor = 'none';
        bb(i).semPtch.EdgeColor = 'none';
        bb(i).sdPtch.EdgeColor = 'none';
    end

    bb(1).data.MarkerFaceColor = preColor;
    bb(1).mu.Color = preColor;
    bb(1).semPtch.FaceColor = [255/255,102/255,204/255];
    bb(1).sdPtch.FaceColor = [255/255,204/255,204/255];

    bb(2).data.MarkerFaceColor = testColor;
    bb(2).mu.Color = testColor;
    bb(2).semPtch.FaceColor = [75/255,207/255,227/255];
    bb(2).sdPtch.FaceColor = [150/255,255/255,227/255];

    ax1 = gca;
    box(ax1,'off');
    ylabel(ax1,'mean BOLD');
    ax1.XTick = [1,2];
    ax1.XTickLabel = {'Pre','Test'};
    ax1.XLim = [0.5,2.5];
    ax1.FontSize = 10;
    ax1.FontWeight = 'bold';
    ax1.LineWidth = 1.5;

    if isfinite(pPerm) && pPerm < 0.05
        sigstar({[1,2]}, pPerm, 0, 10);
    end

    text(ax1, ax1.XLim(1)+0.1*diff(ax1.XLim), ...
        ax1.YLim(1)+0.2*diff(ax1.YLim), ...
        sprintf('p_{perm} = %.4g',pPerm), 'Interpreter','tex');

    % Predictor vs PRE / TEST
    subplot(2,3,[2,3]);
    s1 = scatter(predictor,betaPre,40,'filled'); hold on;
    s2 = scatter(predictor,betaTest,40,'filled');
    s1.MarkerEdgeColor = 'none'; s2.MarkerEdgeColor = 'none';
    s1.MarkerFaceColor = preColor; s2.MarkerFaceColor = testColor;

    ax2 = gca;
    box(ax2,'off'); axis(ax2,'square');
    xlabel(ax2,predictorName,'Interpreter','none');
    ylabel(ax2,'mean BOLD');
    ax2.FontSize = 10; ax2.FontWeight = 'bold'; ax2.LineWidth = 1.5;

    ll = lsline;
    if numel(ll) >= 2
        ll(1).Color = testColor; ll(1).LineWidth = 1.5;
        ll(2).Color = preColor;  ll(2).LineWidth = 1.5;
    end

    x1=ax2.XLim(1)+0.10*diff(ax2.XLim);
    x2=ax2.XLim(1)+0.55*diff(ax2.XLim);
    y1=ax2.YLim(1)+0.10*diff(ax2.YLim);
    y2=ax2.YLim(1)+0.20*diff(ax2.YLim);
    y3=ax2.YLim(1)+0.90*diff(ax2.YLim);
    y4=ax2.YLim(1)+0.80*diff(ax2.YLim);

    text(ax2,x1,y1,sprintf('p = %.3g',pPreP),'Color',preColor,'FontWeight','bold');
    text(ax2,x2,y1,sprintf('r = %.3f',rPreP),'Color',preColor,'FontWeight','bold');
    text(ax2,x1,y2,sprintf('p = %.3g',pTestP),'Color',testColor,'FontWeight','bold');
    text(ax2,x2,y2,sprintf('r = %.3f',rTestP),'Color',testColor,'FontWeight','bold');
    text(ax2,x1,y3,sprintf('p_s = %.3g',pPreS),'Color',preColor,'FontWeight','bold');
    text(ax2,x2,y3,sprintf('\\rho_s = %.3f',rPreS),'Color',preColor,'FontWeight','bold','Interpreter','tex');
    text(ax2,x1,y4,sprintf('p_s = %.3g',pTestS),'Color',testColor,'FontWeight','bold');
    text(ax2,x2,y4,sprintf('\\rho_s = %.3f',rTestS),'Color',testColor,'FontWeight','bold','Interpreter','tex');

    % Predictor vs TEST-PRE
    subplot(2,3,[5,6]);
    sd = scatter(predictor,betaDiff,40,'filled');
    sd.MarkerEdgeColor = 'none';
    sd.MarkerFaceColor = diffColor;

    ax3 = gca;
    box(ax3,'off'); axis(ax3,'square');
    xlabel(ax3,predictorName,'Interpreter','none');
    ylabel(ax3,{'mean BOLD','(Test - Pre)'});
    ax3.FontSize=10; ax3.FontWeight='bold'; ax3.LineWidth=1.5;

    ld = lsline;
    ld.Color = diffColor; ld.LineWidth = 1.5;

    x1=ax3.XLim(1)+0.10*diff(ax3.XLim);
    x2=ax3.XLim(1)+0.55*diff(ax3.XLim);
    y1=ax3.YLim(1)+0.10*diff(ax3.YLim);
    y2=ax3.YLim(1)+0.20*diff(ax3.YLim);

    text(ax3,x1,y1,sprintf('p = %.3g',pDiffP),'Color',diffColor,'FontWeight','bold');
    text(ax3,x2,y1,sprintf('r = %.3f',rDiffP),'Color',diffColor,'FontWeight','bold');
    text(ax3,x1,y2,sprintf('p_s = %.3g',pDiffS),'Color',diffColor,'FontWeight','bold');
    text(ax3,x2,y2,sprintf('\\rho_s = %.3f',rDiffS),'Color',diffColor,'FontWeight','bold','Interpreter','tex');

    sgtitle(sprintf('%s | %s',panelName,predictorName),'Interpreter','none');

    statsTable = table( ...
        ["Predictor_vs_PRE_Pearson";"Predictor_vs_PRE_Spearman"; ...
         "Predictor_vs_TEST_Pearson";"Predictor_vs_TEST_Spearman"; ...
         "Predictor_vs_Delta_Pearson";"Predictor_vs_Delta_Spearman"; ...
         "PRE_vs_TEST_PairedTTest";"PRE_vs_TEST_Permutation"], ...
        [rPreP;rPreS;rTestP;rTestS;rDiffP;rDiffS;pairedStats.tstat;NaN], ...
        [pPreP;pPreS;pTestP;pTestS;pDiffP;pDiffS;pPaired;pPerm], ...
        'VariableNames',{'Statistic','Estimate','P'});

    writetable(statsTable,fullfile(outputDir,['Statistics_' panelName '.csv']));

    result = struct;
    result.predictorName = predictorName;
    result.predictor = predictor;
    result.betaPre = betaPre;
    result.betaTest = betaTest;
    result.betaDiff = betaDiff;
    result.statistics = statsTable;
    result.pairedTTest = struct('h',hPaired,'p',pPaired,'stats',pairedStats);
    result.permutation = struct('clusters',clusters,'pValues',pPermValues, ...
        'p',pPerm,'tSums',tSums,'distribution',permDist, ...
        'numberOfPermutations',numberOfPermutations,'randomSeed',randomSeed);

    save(fullfile(outputDir,['Results_' panelName '.mat']),'result');

    if ~isempty(which('docDataSrc'))
        try
            docDataSrc(fig,outputDir,scriptFile,true);
        catch documentationError
            warning('docDataSrc failed: %s',documentationError.message);
        end
    end

    exportgraphics(fig,fullfile(outputDir,[panelName '.pdf']), ...
        'ContentType','vector','BackgroundColor','white');
    exportgraphics(fig,fullfile(outputDir,[panelName '.png']), ...
        'Resolution',300,'BackgroundColor','white');
end
