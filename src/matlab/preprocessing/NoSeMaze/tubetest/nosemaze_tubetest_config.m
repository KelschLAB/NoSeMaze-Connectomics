function groups = nosemaze_tubetest_config(repoRoot)
% NOSEMAZE_TUBETEST_CONFIG Cohort-specific paths and constants.

arguments
    repoRoot (1,:) char
end

groups(1).name = 'NoSeMaze_1';
groups(1).rawCsvFile = 'AT1_experiment_live_log_since_2020-07-08_combined.csv';
groups(1).canonicalIDs = sort({
    '0007CA3A35'
    '0007CB357C'
    '0007CB239E'
    '0007CA38FF'
    '0007CB330D'
    '0007CB08A5'
    '0007CB4123'
    '0007CB0D91'
    '0007CB1EC1'
    '0007CB6EA3'
    '0007CB0ABC'
    '0007CB42F2'
    '0007CB0F95'
    '0007CB090F'
});

groups(2).name = 'NoSeMaze_2';
groups(2).rawCsvFile = 'AT2_experiment_live_log_since_2020-07-08_combined.csv';
groups(2).canonicalIDs = {};

for groupIndex = 1:numel(groups)

    rawCohortDir = fullfile( ...
        repoRoot,'data','raw','NoSeMaze',groups(groupIndex).name);

    % Preferred layout:
    % data/raw/NoSeMaze/<group>/<combined CSV>
    directCsv = fullfile(rawCohortDir,groups(groupIndex).rawCsvFile);

    % Historical/local fallback:
    % data/raw/NoSeMaze/<group>/tube/<combined CSV>
    tubeCsv = fullfile(rawCohortDir,'tube',groups(groupIndex).rawCsvFile);

    if isfile(directCsv)
        groups(groupIndex).rawCsvPath = directCsv;
    elseif isfile(tubeCsv)
        groups(groupIndex).rawCsvPath = tubeCsv;
    else
        groups(groupIndex).rawCsvPath = directCsv;
    end

    groups(groupIndex).interimTubeDir = fullfile( ...
        repoRoot,'data','interim','NoSeMaze',groups(groupIndex).name,'tube');

    groups(groupIndex).logDir = fullfile( ...
        groups(groupIndex).interimTubeDir,'LOG-files');

    groups(groupIndex).eventPlotDir = fullfile( ...
        groups(groupIndex).logDir,'plots');

    groups(groupIndex).processedDir = fullfile( ...
        repoRoot,'data','processed','NoSeMaze','tubetest',groups(groupIndex).name);

    groups(groupIndex).fullHierarchyFile = fullfile( ...
        groups(groupIndex).processedDir,'full_hierarchy_jr.mat');
end
end
