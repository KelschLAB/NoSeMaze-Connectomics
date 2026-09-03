function pulses = detect_binary_pulses(trace,freq)
% DETECT_BINARY_PULSES Detect high-state TTL pulses in one digital channel.

x = double(trace(:));

if isempty(x) || all(~isfinite(x))
    pulses = empty_pulses();
    return;
end

lo = min(x,[],'omitnan');
hi = max(x,[],'omitnan');
if hi==lo
    pulses = empty_pulses();
    return;
end

b = x > (lo + (hi-lo)/2);

% If high is the resting state, invert so pulses are the minority state.
if mean(b,'omitnan') > 0.5
    b = ~b;
end

edge = diff([false; b; false]);
startIdx = find(edge==1);
stopIdx  = find(edge==-1)-1;

n = min(numel(startIdx),numel(stopIdx));
startIdx = startIdx(1:n);
stopIdx = stopIdx(1:n);

pulses = struct();
pulses.onSec = (startIdx-1)./freq;
pulses.offSec = stopIdx./freq;
pulses.durationSec = pulses.offSec-pulses.onSec;
pulses.count = n;
end

function P = empty_pulses()
P = struct('onSec',[],'offSec',[],'durationSec',[],'count',0);
end
