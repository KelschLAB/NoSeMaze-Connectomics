
function trials = align_eyelid_trials( ...
    eyeOpeningArea,events,intanSyncOffSec,videoStartFrame,cfg)
% ALIGN_EYELID_TRIALS Align eye-opening area to odor onset and normalize.
%
% Reproduces the source-data generating sequence:
%   - crop at video synchronization-light offset;
%   - subtract Intan synchronization-light offset from odor TTL times;
%   - round odor timing to the 10-Hz video grid;
%   - extract -1.9 to +9.9 s trial windows;
%   - divide each trial by its own 1.9-s prestimulus mean;
%   - apply historical spike/NaN correction to the normalized matrix.

area = eyeOpeningArea(:);

assert(videoStartFrame>=1 && videoStartFrame<=numel(area), ...
    'Invalid video start frame.');

croppedArea = area(videoStartFrame:end);

nTrials = numel(events);
timeSec = cfg.timeSec(:)';
frameDur = 1/cfg.frameRateHz;

raw = nan(nTrials,numel(timeSec));
odorTimeRelative = nan(nTrials,1);
odorFrame = nan(nTrials,1);
hasAirPuff = false(nTrials,1);

for trial = 1:nTrials

    odorOn = get_event_value(events(trial),{'odor_on','fv_on'});

    odorTimeRelative(trial) = odorOn-intanSyncOffSec;

    roundedTime = round(odorTimeRelative(trial)/frameDur)*frameDur;
    odorFrame(trial) = roundedTime/frameDur;

    framePre = odorFrame(trial) - cfg.preSec*cfg.frameRateHz;
    idx = framePre:(framePre+numel(timeSec)-1);
    idx = round(idx);

    valid = idx>=1 & idx<=numel(croppedArea);
    raw(trial,valid) = croppedArea(idx(valid));

    hasAirPuff(trial) = logical( ...
        get_event_value(events(trial), ...
        {'has_air_puff','puff_or_not'},0));
end

% Historical baseline comprises the 19 frames immediately before odor
% onset, excluding the odor-onset frame itself.
nBaselineFrames = round(cfg.baselineSec*cfg.frameRateHz);
odorColumn = round(cfg.preSec*cfg.frameRateHz)+1;
baselineColumns = (odorColumn-nBaselineFrames):(odorColumn-1);

baseline = mean(raw(:,baselineColumns),2,'omitnan');
baseline(~isfinite(baseline) | baseline==0) = NaN;

ratio = raw./baseline;

% Historical final source data used the corrected normalized matrix.
M = nan(1,size(ratio,2),size(ratio,1));
M(1,:,:) = ratio';

[Mcorrected,removedTrialSpikes] = ...
    remove_spikes_and_interpolate( ...
        M, ...
        cfg.trialSpikeStdThreshold, ...
        cfg.trialMaxGap, ...
        nan);

ratioCorrected = squeeze(Mcorrected)';

distal = ...
    timeSec>=cfg.distalWindowSec(1) & ...
    timeSec<=cfg.distalWindowSec(2);

proximal = ...
    timeSec>=cfg.proximalWindowSec(1) & ...
    timeSec<=cfg.proximalWindowSec(2);

trials = struct();
trials.time_sec = timeSec;
trials.eye_opening_area = raw;
trials.baseline_area = baseline;
trials.eye_opening_ratio = ratio;
trials.eye_opening_ratio_corrected = ratioCorrected;
trials.distal_ratio = mean(ratioCorrected(:,distal),2,'omitnan');
trials.proximal_ratio = mean(ratioCorrected(:,proximal),2,'omitnan');
trials.odor_time_relative_to_sync_sec = odorTimeRelative;
trials.odor_frame_relative_to_cropped_video = odorFrame;
trials.has_air_puff = hasAirPuff;
trials.removed_trial_spikes = removedTrialSpikes;

end

function value = get_event_value(event,names,defaultValue)

if nargin<3
    defaultValue = [];
end

for i = 1:numel(names)
    if isfield(event,names{i})
        value = event.(names{i});
        return
    end
end

if isempty(defaultValue)
    error('Required event field not found.');
end

value = defaultValue;

end
