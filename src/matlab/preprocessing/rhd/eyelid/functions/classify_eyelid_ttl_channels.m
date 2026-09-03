function channels = classify_eyelid_ttl_channels(dchannels,freq,nTrials,expectedPuffs,cfg)
% CLASSIFY_EYELID_TTL_CHANNELS Identify odor, puff, and video-sync TTLs.
%
% Explicit channel overrides in cfg take precedence. Otherwise channels are
% inferred from pulse count and duration, which avoids carrying historical
% channel labels into the active code.

nCh = size(dchannels,2);
pulseInfo = cell(nCh,1);
for c = 1:nCh
    pulseInfo{c} = detect_binary_pulses(dchannels(:,c),freq);
end

channels = struct();
channels.pulseInfo = pulseInfo;

% Odor: one approximately 2.4-s TTL per trial.
if ~isempty(cfg.odorChannel)
    odor = cfg.odorChannel;
else
    score = inf(nCh,1);
    for c = 1:nCh
        P = pulseInfo{c};
        if P.count==nTrials && ~isempty(P.durationSec)
            medDur = median(P.durationSec,'omitnan');
            if medDur>=cfg.odorDurationSec(1) && medDur<=cfg.odorDurationSec(2)
                score(c) = abs(medDur-2.4);
            end
        end
    end
    [best,odor] = min(score);
    assert(isfinite(best), ...
        'Could not infer odor TTL channel (%d expected trials).',nTrials);
end
channels.odor = odor;

% Video LED: one ~1-s pulse, preferably before the first odor.
if ~isempty(cfg.videoLedChannel)
    led = cfg.videoLedChannel;
else
    firstOdor = pulseInfo{odor}.onSec(1);
    score = inf(nCh,1);
    for c = 1:nCh
        if c==odor; continue; end
        P = pulseInfo{c};
        if P.count==1 && ~isempty(P.durationSec)
            d = P.durationSec(1);
            if d>=cfg.videoLedDurationSec(1) && d<=cfg.videoLedDurationSec(2)
                penalty = 0;
                if P.onSec(1)>firstOdor; penalty = 10; end
                score(c) = abs(d-1.0)+penalty;
            end
        end
    end
    [best,led] = min(score);
    assert(isfinite(best), ...
        ['Could not infer the one-second video synchronization TTL. ' ...
         'Set cfg.videoLedChannel explicitly.']);
end
channels.videoLed = led;

% Air-puff TTL: optional and short. Prefer exact protocol count if known.
if ~isempty(cfg.airPuffChannel)
    puff = cfg.airPuffChannel;
elseif isfinite(expectedPuffs) && expectedPuffs==0
    puff = [];
else
    score = inf(nCh,1);
    for c = 1:nCh
        if any(c==[odor led]); continue; end
        P = pulseInfo{c};
        if P.count==0; continue; end
        medDur = median(P.durationSec,'omitnan');
        if medDur > cfg.shortPulseMaxSec; continue; end
        if isfinite(expectedPuffs)
            score(c) = abs(P.count-expectedPuffs) + medDur;
        else
            score(c) = medDur;
        end
    end
    [best,puff] = min(score);
    if ~isfinite(best)
        puff = [];
    end
end
channels.airPuff = puff;

end
