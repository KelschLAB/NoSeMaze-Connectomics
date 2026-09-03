function socialTable = build_social_hierarchy_covariates(cfg)
% BUILD_SOCIAL_HIERARCHY_COVARIATES
%
% Build the reduced social-hierarchy covariate set used for voxelwise
% second-level regressions:
%
%   DavidScore
%   SocialRank
%   FractionActiveChases
%   FractionBeingChased
%
% Historical exploratory variables (z-scored DS, chasing DS/rank, raw
% counts, Box-Cox win/loss fractions, post-scan hierarchy, etc.) are
% intentionally omitted.
%
% Delta L is NOT generated here because it is an fMRI graph-derived metric,
% not a NoSeMaze social-hierarchy measure. It can later be passed to the
% same second-level GLM helper once the graph-analysis pipeline generates it.

if ~isfile(cfg.generalOverviewFile)
    error('General NoSeMaze overview not found:\n%s', cfg.generalOverviewFile);
end

overview = readtable( ...
    cfg.generalOverviewFile, ...
    'Sheet', ...
    9, ...
    'ReadVariableNames', ...
    true ...
);

requiredColumns = {
    'AnimalIDCombined'
    'Autonomouse'
    'AnimalNumber'
    'DaysToConsider'
};

missingColumns = setdiff( ...
    requiredColumns, ...
    overview.Properties.VariableNames ...
);

if ~isempty(missingColumns)
    error( ...
        'NoSeMaze overview is missing: %s', ...
        strjoin(missingColumns, ', ') ...
    );
end

%% Load the three prescan hierarchy windows

h1a = load_hierarchy_window( ...
    cfg.noSeMaze1Dir, ...
    '*day3to16*withChasing*.mat' ...
);

h1b = load_hierarchy_window( ...
    cfg.noSeMaze1Dir, ...
    '*day8to21*withChasing*.mat' ...
);

h2 = load_hierarchy_window( ...
    cfg.noSeMaze2Dir, ...
    '*day1to14*withChasing*.mat' ...
);

%% Build one row per scanned animal

rows = cell(0, 9);

for rowIndex = 1:height(overview)

    cohort = overview.Autonomouse(rowIndex);

    if ~ismember(cohort, [1 2])
        continue;
    end

    animalNumber = overview.AnimalNumber(rowIndex);

    if isnan(animalNumber)
        continue;
    end

    subjectID = sprintf('ZI_M%02d', animalNumber);
    rfid = char(string(overview.AnimalIDCombined{rowIndex}));

    if cohort == 1

        daysText = char(string(overview.DaysToConsider{rowIndex}));

        if contains(daysText, '16')
            hierarchy = h1a;
            hierarchyWindow = 'day3to16';
        elseif contains(daysText, '21')
            hierarchy = h1b;
            hierarchyWindow = 'day8to21';
        else
            error( ...
                '%s: could not map DaysToConsider "%s" to an NoSeMaze_1 window.', ...
                subjectID, ...
                daysText ...
            );
        end

    else

        hierarchy = h2;
        hierarchyWindow = 'day1to14';
    end

    idIndex = find( ...
        strcmp(string(hierarchy.DS_info.ID), string(rfid)), ...
        1 ...
    );

    chasingIndex = find( ...
        strcmp(string(hierarchy.DS_info_chasing.ID), string(rfid)), ...
        1 ...
    );

    if isempty(idIndex) || isempty(chasingIndex)
        error('%s / %s not found in selected hierarchy.', subjectID, rfid);
    end

    davidScore = hierarchy.DS_info.DS(idIndex);

    rankVector = get_rank_vector(hierarchy.DS_info);
    socialRank = rankVector(idIndex);

    chasingMatrix = hierarchy.DS_info_chasing.match_matrix;

    activeChases = sum(chasingMatrix, 2);
    beingChased = sum(chasingMatrix, 1)';

    totalActive = sum(activeChases);
    totalChased = sum(beingChased);

    if totalActive == 0
        fractionActive = NaN;
    else
        fractionActive = activeChases(chasingIndex) / totalActive;
    end

    if totalChased == 0
        fractionChased = NaN;
    else
        fractionChased = beingChased(chasingIndex) / totalChased;
    end

    rows(end + 1, :) = { ...
        subjectID, ...
        animalNumber, ...
        rfid, ...
        cohort, ...
        hierarchyWindow, ...
        davidScore, ...
        socialRank, ...
        fractionActive ...
    }; %#ok<AGROW>

    rows{end, 9} = fractionChased;
end

socialTable = cell2table( ...
    rows, ...
    'VariableNames', ...
    { ...
        'Subject_ID', ...
        'AnimalNumber', ...
        'RFID', ...
        'NoSeMaze', ...
        'HierarchyWindow', ...
        'DavidScore', ...
        'SocialRank', ...
        'FractionActiveChases', ...
        'FractionBeingChased' ...
    } ...
);

socialTable = sortrows(socialTable, 'AnimalNumber');

if ~isfolder(cfg.groupCovariatesDir)
    mkdir(cfg.groupCovariatesDir);
end

outputFile = fullfile( ...
    cfg.groupCovariatesDir, ...
    'social_hierarchy_covariates.csv' ...
);

writetable(socialTable, outputFile);

fprintf('Saved social-hierarchy covariates:\n%s\n', outputFile);

end


function hierarchy = load_hierarchy_window(folderPath, pattern)

if ~isfolder(folderPath)
    error('Hierarchy directory not found:\n%s', folderPath);
end

files = dir(fullfile(folderPath, pattern));

% Ignore historical files whose names explicitly advertise DoubleChasing.
files = files(~contains(string({files.name}), 'DoubleChasing'));

if numel(files) ~= 1
    error( ...
        'Expected exactly one hierarchy file matching:\n%s\nFound %d.', ...
        fullfile(folderPath, pattern), ...
        numel(files) ...
    );
end

hierarchy = load( ...
    fullfile(files(1).folder, files(1).name), ...
    'DS_info', ...
    'DS_info_chasing' ...
);

if ~isfield(hierarchy, 'DS_info') || ...
        ~isfield(hierarchy, 'DS_info_chasing')
    error('Hierarchy file lacks DS_info and/or DS_info_chasing.');
end

end


function rankVector = get_rank_vector(DS_info)

if isfield(DS_info, 'rank') && numel(DS_info.rank) == numel(DS_info.DS)
    rankVector = DS_info.rank;
    return;
end

[~, sortedIndex] = sort(DS_info.DS, 'descend');
[~, rankVector] = sort(sortedIndex);

end
