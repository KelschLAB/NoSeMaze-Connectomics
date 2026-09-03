function syncOffFrame = detect_video_sync_led(videoFile,cfg)
% DETECT_VIDEO_SYNC_LED Estimate the first frame after the 1-s red sync LED.
%
% If automatic detection is unreliable for a video, store the manually
% verified frame in data/reference/eyelid/eyelid_sessions.csv instead.

assert(isfile(videoFile),'Video file not found:\n%s',videoFile);

vr = VideoReader(videoFile);
maxFrames = max(1,ceil(min(cfg.videoSyncSearchSeconds,vr.Duration)*vr.FrameRate));
score = nan(maxFrames,1);

k = 0;
while hasFrame(vr) && k<maxFrames
    frame = readFrame(vr);
    k = k+1;

    if size(frame,3)<3
        g = double(frame(:,:,1));
        score(k) = max(g,[],'all');
    else
        R = double(frame(:,:,1));
        G = double(frame(:,:,2));
        B = double(frame(:,:,3));
        redExcess = R - 0.5*(G+B);
        redExcess(redExcess<0) = 0;

        vals = sort(redExcess(:),'descend');
        nTop = max(1,round(numel(vals)*0.001));
        score(k) = mean(vals(1:nTop),'omitnan');
    end
end
score = score(1:k);

med = median(score,'omitnan');
mad0 = median(abs(score-med),'omitnan');
if mad0==0
    threshold = med + 0.1*(max(score)-med);
else
    threshold = med + 5*mad0;
end

bright = score>threshold;
edge = diff([false; bright; false]);
starts = find(edge==1);
stops = find(edge==-1)-1;

durations = (stops-starts+1)./vr.FrameRate;
valid = durations>=cfg.videoSyncExpectedDurationSec(1) & ...
        durations<=cfg.videoSyncExpectedDurationSec(2);

assert(any(valid), ...
    ['Automatic one-second video-sync LED detection failed. ' ...
     'Enter video_sync_off_frame manually in the eyelid session manifest.']);

starts = starts(valid);
stops = stops(valid);
segmentScore = arrayfun(@(a,b) mean(score(a:b),'omitnan'),starts,stops);
[~,best] = max(segmentScore);

% First frame after the LED has switched off.
syncOffFrame = stops(best)+1;
end
