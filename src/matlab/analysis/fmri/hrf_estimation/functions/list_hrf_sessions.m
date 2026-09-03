
function sessionIDs = list_hrf_sessions(cfg)
% LIST_HRF_SESSIONS Discover HRF sessions from mask-GLM first-level folders.

assert(isfolder(cfg.maskFirstLevelDir), ...
    'HRF mask-GLM first-level directory missing:\n%s',cfg.maskFirstLevelDir);

D = dir(fullfile(cfg.maskFirstLevelDir,'ZI_M*'));
D = D([D.isdir]);

sessionIDs = sort(string({D.name})');

assert(numel(sessionIDs)==cfg.nSessions, ...
    'Expected %d HRF sessions, found %d.', ...
    cfg.nSessions,numel(sessionIDs));

end
