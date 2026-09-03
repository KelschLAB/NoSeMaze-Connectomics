% panel_A_social_rank_by_animal.m
% Jonathan Reinwald
%
% Supplementary Figure S8A
%
% Social rank of the conditioning fMRI animals.
%
% This is a minimal repository version derived from the historical
% social-hierarchy/GLM preparation script. It retains ONLY what is needed
% to assign the pre-scan tube-test rank to each MRI animal and plot it.
%
% Rank definition:
%   rank 1 = highest David's score
%   rank 12 = lowest David's score
%
% Hierarchy windows:
%   NoSeMaze 1, scan-day group 1 -> AM1 days 3-16
%   NoSeMaze 1, scan-day group 2 -> AM1 days 8-21
%   NoSeMaze 2                    -> AM2 days 1-14
%
% Animals are sorted by social rank for display, while the x-axis shows
% the corresponding AnimalIDCombined labels.
%
% Expected repository inputs:
%
% data/processed/NoSeMaze/
% ├── 01_General_Overview.xlsx
% └── tubetest/
%     ├── NoSeMaze_1/
%     │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%     │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%     └── NoSeMaze_2/
%         └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
%
% Outputs:
%   results/supplement/Figure_S8/Figure_S8A/
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

% repo/figures/supplement/Figure_S8/panel_A_social_rank_by_animal.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot,'src','matlab');

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

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

outputDir = fullfile( ...
    repoRoot, ...
    'results','supplement', ...
    'Figure_S8','Figure_S8A' ...
);

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Input files

generalOverviewFile = fullfile( ...
    noSeMazeDir, ...
    '01_General_Overview.xlsx' ...
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

requiredFiles = {
    generalOverviewFile
    am1EarlyFile
    am1LateFile
    am2File
};

missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error( ...
        'Required Figure S8A input files are missing:\n\n%s', ...
        strjoin(missingFiles,newline) ...
    );
end

%% Load animal overview

T = readtable( ...
    generalOverviewFile, ...
    'Sheet',9, ...
    'ReadVariableNames',true, ...
    'VariableNamingRule','modify' ...
);

%% Load and rank the three pre-scan hierarchy windows

tmp = load(am1EarlyFile,'DS_info');
AM1_early = prepareHierarchy(tmp.DS_info);

tmp = load(am1LateFile,'DS_info');
AM1_late = prepareHierarchy(tmp.DS_info);

tmp = load(am2File,'DS_info');
AM2 = prepareHierarchy(tmp.DS_info);

%% Assign one social-rank value to each MRI animal

animalID = strings(0,1);
animalNumber = [];
noSeMaze = [];
scanDayGroup = [];
rankValue = [];

for rowIndex = 1:height(T)

    currentNoSeMaze = getNumericScalar( ...
        T.Autonomouse(rowIndex) ...
    );

    % Conditioning MRI cohorts only.
    if ~ismember(currentNoSeMaze,[1,2])
        continue;
    end

    currentID = normalizeAnimalID( ...
        getTableValue(T.AnimalIDCombined,rowIndex) ...
    );

    currentAnimalNumber = getNumericScalar( ...
        T.AnimalNumber(rowIndex) ...
    );

    if currentNoSeMaze == 1

        daysValue = normalizeText( ...
            getTableValue(T.DaysToConsider,rowIndex) ...
        );

        if contains(daysValue,'16')

            hierarchy = AM1_early;
            currentScanDayGroup = 1;

        elseif contains(daysValue,'21')

            hierarchy = AM1_late;
            currentScanDayGroup = 2;

        else

            error( ...
                'Could not assign hierarchy window for AM1 animal %s.', ...
                currentID ...
            );
        end

    else

        hierarchy = AM2;
        currentScanDayGroup = 3;
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
    animalNumber(end+1,1) = currentAnimalNumber; %#ok<SAGROW>
    noSeMaze(end+1,1) = currentNoSeMaze; %#ok<SAGROW>
    scanDayGroup(end+1,1) = currentScanDayGroup; %#ok<SAGROW>
    rankValue(end+1,1) = hierarchy.Rank(hierarchyIndex); %#ok<SAGROW>
end

%% Sort by social rank for display
%
% Rank 1 = highest social rank. Sorting ascending therefore orders animals
% from highest to lowest rank, matching the original Figure S8A layout.
% AnimalNumber is used only as a deterministic tie-breaker.

[~,sortIndex] = sortrows( ...
    [rankValue, animalNumber], ...
    [1,2] ...
);

animalID = animalID(sortIndex);
animalNumber = animalNumber(sortIndex);
noSeMaze = noSeMaze(sortIndex);
scanDayGroup = scanDayGroup(sortIndex);
rankValue = rankValue(sortIndex);

nAnimals = numel(rankValue);

fprintf('\nSupplementary Figure S8A\n');
fprintf('Animals: %d\n',nAnimals);
fprintf('Rank range: %g-%g\n\n', ...
    min(rankValue),max(rankValue));

%% Plot

fig = figure( ...
    'Name','Supplementary Figure S8A: social rank', ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,1350,520] ...
);

ax = axes(fig);
hold(ax,'on');

x = 1:nAnimals;

% Original S8A-like styling:
% dark connecting line with red filled rank markers.
plot( ...
    ax, ...
    x, ...
    rankValue, ...
    '-', ...
    'Color',[0.20,0.20,0.20], ...
    'LineWidth',2.0, ...
    'HandleVisibility','off' ...
);

scatter( ...
    ax, ...
    x, ...
    rankValue, ...
    90, ...
    'filled', ...
    'MarkerFaceColor',[0.93,0.12,0.15], ...
    'MarkerEdgeColor','none' ...
);

box(ax,'off');

ax.XLim = [0.5,nAnimals+0.5];
ax.XTick = x;
ax.XTickLabel = cellstr(animalID);
xtickangle(ax,60);

ax.YLim = [0.5,12.5];
ax.YTick = 1:12;

% Rank 1 is highest, so it is displayed at the top.
ax.YDir = 'reverse';

xlabel(ax,'Animal ID');
ylabel(ax,'Social rank');

ax.FontSize = 10;
ax.LineWidth = 1.2;
ax.TickDir = 'out';

% Keep the panel visually minimal, as in the manuscript figure.
title(ax,'');

hold(ax,'off');

%% Source data

sourceData = table( ...
    animalID, ...
    animalNumber, ...
    noSeMaze, ...
    scanDayGroup, ...
    rankValue, ...
    'VariableNames', {
        'AnimalID'
        'AnimalNumber'
        'NoSeMaze'
        'ScanDayGroup'
        'SocialRank'
    } ...
);

writetable( ...
    sourceData, ...
    fullfile( ...
        outputDir, ...
        'SourceData_Figure_S8A_SocialRank.csv' ...
    ) ...
);

%% Save result

result = struct;

result.AnimalID = animalID;
result.AnimalNumber = animalNumber;
result.NoSeMaze = noSeMaze;
result.ScanDayGroup = scanDayGroup;
result.SocialRank = rankValue;

result.files.generalOverview = ...
    makeRepoRelative(generalOverviewFile,repoRoot);

result.files.AM1_early = ...
    makeRepoRelative(am1EarlyFile,repoRoot);

result.files.AM1_late = ...
    makeRepoRelative(am1LateFile,repoRoot);

result.files.AM2 = ...
    makeRepoRelative(am2File,repoRoot);

result.sourceData = sourceData;

save( ...
    fullfile( ...
        outputDir, ...
        'Results_Figure_S8A_SocialRank.mat' ...
    ), ...
    'result' ...
);

%% Optional provenance

if ~isempty(which('docDataSrc'))

    try

        docDataSrc( ...
            fig, ...
            outputDir, ...
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
        outputDir, ...
        'Figure_S8A_SocialRank.pdf' ...
    ), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S8A_SocialRank.png' ...
    ), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

savefig( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S8A_SocialRank.fig' ...
    ) ...
);

fprintf('Figure S8A completed.\n');
fprintf('Results saved to:\n%s\n',outputDir);


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
