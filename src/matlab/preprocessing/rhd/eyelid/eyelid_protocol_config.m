
function cfg = eyelid_protocol_config(repoRoot)
% EYELID_PROTOCOL_CONFIG RHD/protocol settings for eyelid-video sessions.

arguments
    repoRoot (1,:) char
end

cfg = struct();

cfg.rawRoot = getenv('NOSEMAZE_EYELID_RAW_ROOT');

if isempty(cfg.rawRoot)
    cfg.protocolDir = '';
    cfg.rhdDir = '';
else
    cfg.protocolDir = fullfile(cfg.rawRoot,'01-protocol_files');
    cfg.rhdDir = fullfile(cfg.rawRoot,'02-rhd_files');
end

cfg.workDir = fullfile( ...
    repoRoot,'data','interim','eyelid','rhd_work');

cfg.outputDir = fullfile( ...
    repoRoot,'data','interim','eyelid','processed_protocol_files');

% Exact digital channels from the historical parser.
cfg.channel.airPuff = 1;
cfg.channel.odor = 2;
cfg.channel.videoSync = 7;

cfg.odorDurationRangeSec = [2.35 2.45];
cfg.airPuffDurationRangeSec = [0.05 0.15];

end
