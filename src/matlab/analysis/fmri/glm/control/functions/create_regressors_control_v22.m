function create_regressors_control_v22(cfg)
% CREATE_REGRESSORS_CONTROL_V22 Primary control first-level task model.
%
% Control v22 uses the same three task blocks as the paradigm and does NOT
% split Block 3 into early/late portions.
%
% Regressors:
%   1  Lavender_Bl1_1to10
%   2  Lavender_Bl1_11to40
%   3  Lavender_Bl2
%   4  Lavender_Bl3
%   5  TP_Puff_Bl1_1to10
%   6  TP_Puff_Bl1_11to40
%   7  TP_Puff_Bl2
%   8  TP_Puff_Bl3
%
% The control cohort received no air puffs. "TP_Puff" therefore denotes the
% corresponding anticipated puff-time position used for the proximal event.
%
% Historical control version notes associate GLM v22 with an odor delay of
% 0.425 s. This is kept separate from the FC v16/cormat-v6 timing model.

if ~isfolder(cfg.regressorsDir)
    mkdir(cfg.regressorsDir);
end

manifest = build_control_subject_manifest(cfg);

for i = 1:height(manifest)

    subjectID = char(manifest.Subject_ID(i));
    scannerID = manifest.Scanner_ID(i);

    protocolFile = find_control_protocol_file( ...
        cfg, subjectID, scannerID);

    assert(~isempty(protocolFile) && isfile(protocolFile), ...
        'Processed protocol file not found for %s.', subjectID);

    S = load(protocolFile, 'events');

    assert(isfield(S,'events') && numel(S.events) >= 120, ...
        'Invalid events variable for %s.', subjectID);

    events = S.events;

    odor = @(idx) [events(idx).fv_on_del5] + cfg.odorDelay;
    tp   = @(idx) [events(idx).fv_off_del5] + 0.1 + cfg.odorDelay;

    ranges = {1:10, 11:40, 41:80, 81:120};

    odorNames = { ...
        'Lavender_Bl1_1to10', ...
        'Lavender_Bl1_11to40', ...
        'Lavender_Bl2', ...
        'Lavender_Bl3' ...
    };

    tpNames = { ...
        'TP_Puff_Bl1_1to10', ...
        'TP_Puff_Bl1_11to40', ...
        'TP_Puff_Bl2', ...
        'TP_Puff_Bl3' ...
    };

    regressors = repmat( ...
        struct('name','','onset',[],'duration',0,'pm',[]), ...
        1, 8 ...
    );

    for j = 1:4

        regressors(j).name = odorNames{j};
        regressors(j).onset = odor(ranges{j});

        regressors(j+4).name = tpNames{j};
        regressors(j+4).onset = tp(ranges{j});
    end

    save( ...
        fullfile(cfg.regressorsDir, ...
        sprintf('%s_v22.mat',subjectID)), ...
        'regressors' ...
    );
end

end
