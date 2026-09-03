
function cfg = hrf_protocol_config(repoRoot)
% HRF_PROTOCOL_CONFIG Paths/settings for HRF-cohort protocol preprocessing.

arguments
    repoRoot (1,:) char
end

cfg = struct();

% Point this to the historical:
%   ICON_HRF/02-raw-data/01-MRI
cfg.rawRoot = getenv('NOSEMAZE_HRF_PROTOCOL_RAW_ROOT');

if isempty(cfg.rawRoot)
    cfg.protocolDir = '';
    cfg.rhdDir = '';
else
    cfg.protocolDir = fullfile(cfg.rawRoot,'03-protocol_files');
    cfg.rhdDir = fullfile(cfg.rawRoot,'04-rhd_files');
end

cfg.processedProtocolDir = fullfile( ...
    repoRoot,'data','interim','fMRI','hrf','processed_protocol_files');

cfg.expectedVolumes = 8200;

end
