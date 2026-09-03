%% compute_hierarchy_NoSeMaze_1.m
% Compute NoSeMaze 1 tube-test and single-chasing hierarchies.
%
% Multiple/double chasing is intentionally excluded.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
preprocessingRoot = fileparts(fileparts(scriptDir));

addpath(scriptDir);
addpath(fullfile(scriptDir,'functions'));
addpath(fullfile(preprocessingRoot,'helpers'));

repoRoot = find_repo_root(scriptFile);

dataDir = fullfile(repoRoot,'data','processed','NoSeMaze','tubetest','NoSeMaze_1');
inputFile = fullfile(dataDir,'full_hierarchy_jr.mat');

loaded = load(inputFile,'full_hierarchy');
full_hierarchy = loaded.full_hierarchy;

ops.threshold_lag_at_detector = 1.5;
ops.threshold_lag_through_tube = 2;

full_hierarchy = extract_chasing_from_full_hierarchy(full_hierarchy,ops);

save(fullfile(dataDir,'full_hierarchy_withChasing_jr.mat'), ...
    'full_hierarchy','-v7.3');

% Manuscript-relevant NoSeMaze 1 prescan windows.
windows(1).label = 'day3to16';
windows(1).days = 3:16;

windows(2).label = 'day8to21';
windows(2).days = 8:21;

excludeIDs = {'0007CB090F','0007CB0F95'};

for windowIndex = 1:numel(windows)

    [DS_info,DS_info_chasing] = compute_hierarchy_window( ...
        full_hierarchy,windows(windowIndex).days,excludeIDs);

    DS_info.cohort = 'NoSeMaze_1';
    DS_info.day_range = windows(windowIndex).days;
    DS_info.exclude_IDs = excludeIDs;

    DS_info_chasing.cohort = 'NoSeMaze_1';
    DS_info_chasing.day_range = windows(windowIndex).days;
    DS_info_chasing.exclude_IDs = excludeIDs;

    outputFile = fullfile(dataDir,sprintf( ...
        'DS_info_NoSeMaze_1_%s_%dmice_withChasing_td15tt2s.mat', ...
        windows(windowIndex).label,numel(DS_info.ID)));

    save(outputFile,'DS_info','DS_info_chasing');
    fprintf('Saved: %s\n',outputFile);
end
