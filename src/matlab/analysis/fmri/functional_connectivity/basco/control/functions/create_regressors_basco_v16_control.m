function create_regressors_basco_v16_control(cfg)
% CREATE_REGRESSORS_BASCO_V16_CONTROL Trial-wise control BASCO model.
%
% v16:
%   Lavender   = 120 odor onsets + 1.3 s historical odor delay
%   TP_noPuff  = 120 puff-like anticipated time points
%                fv_off + 0.1 + 1.3 s

if ~isfolder(cfg.regressorsDir); mkdir(cfg.regressorsDir); end

T = readtable(cfg.scanlist,'VariableNamingRule','preserve');
[subjectIDs,ia] = unique(string(T.Subject),'stable');
scannerIDs = T.ID(ia);

for i = 1:numel(subjectIDs)

    subjectID = char(subjectIDs(i));
    scannerID = scannerIDs(i);

    dateToken = erase(subjectID,'ZI_M');
    dateToken = dateToken(1:6);
    stem = sprintf('%d_%s',scannerID,dateToken);

    matches = dir(fullfile(cfg.protocolDir,'**',[stem '*']));
    matches = matches(~[matches.isdir]);

    assert(numel(matches)==1, ...
        'Expected one protocol file for %s (%s); found %d.', ...
        subjectID,stem,numel(matches));

    S = load(fullfile(matches(1).folder,matches(1).name),'events');
    events = S.events;

    regressors = repmat( ...
        struct('name','','onset',[],'duration',0,'pm',[]),1,2);

    regressors(1).name = 'Lavender';
    regressors(1).onset = [events(1:120).fv_on_del5] + ...
        cfg.regressors.odorDelay;

    regressors(2).name = 'TP_noPuff';
    regressors(2).onset = [events(1:120).fv_off_del5] + ...
        0.1 + cfg.regressors.odorDelay;

    assert(numel(regressors(1).onset)==120);
    assert(numel(regressors(2).onset)==120);

    save(fullfile(cfg.regressorsDir, ...
        sprintf('%s_v16.mat',subjectID)), 'regressors');
end
end
