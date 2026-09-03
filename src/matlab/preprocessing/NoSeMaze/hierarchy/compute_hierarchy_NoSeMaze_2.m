%% compute_hierarchy_NoSeMaze_2.m
% Compute NoSeMaze 2 tube-test and single-chasing hierarchy.
%
% Multiple/double chasing is intentionally excluded.
%
% Final manuscript prescan hierarchy window: days 1-14.

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

dataDir = fullfile(repoRoot,'data','processed','NoSeMaze','tubetest','NoSeMaze_2');
inputFile = fullfile(dataDir,'full_hierarchy_jr.mat');

loaded = load(inputFile,'full_hierarchy');
full_hierarchy = loaded.full_hierarchy;

ops.threshold_lag_at_detector = 1.5;
ops.threshold_lag_through_tube = 2;

full_hierarchy = extract_chasing_from_full_hierarchy(full_hierarchy,ops);

save(fullfile(dataDir,'full_hierarchy_withChasing_jr.mat'), ...
    'full_hierarchy','-v7.3');

includeDays = 1:14;
excludeIDs = {};

[DS_info,DS_info_chasing] = ...
    compute_hierarchy_window(full_hierarchy,includeDays,excludeIDs);

DS_info.cohort = 'NoSeMaze_2';
DS_info.day_range = includeDays;

DS_info_chasing.cohort = 'NoSeMaze_2';
DS_info_chasing.day_range = includeDays;

outputFile = fullfile(dataDir,sprintf( ...
    'DS_info_NoSeMaze_2_day%dto%d_%dmice_withChasing_td15tt2s.mat', ...
    includeDays(1),includeDays(end),numel(DS_info.ID)));

save(outputFile,'DS_info','DS_info_chasing');
fprintf('Saved: %s\n',outputFile);
