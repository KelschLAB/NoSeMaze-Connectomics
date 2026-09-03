
function sync = find_video_start_frame(videoFile,cfg)
% FIND_VIDEO_START_FRAME Detect the synchronization-light OFF transition.
%
% Historical procedure:
%   - read first 60 s of the video;
%   - mean red-channel intensity per frame;
%   - calculate first difference;
%   - find negative peaks with MinPeakDistance=10;
%   - largest negative transition = synchronization-light offset.

assert(isfile(videoFile),'Video not found:\n%s',videoFile);

v = VideoReader(char(videoFile));

brightness = [];
frameCounter = 1;

while hasFrame(v) && v.CurrentTime < cfg.videoSyncSearchSec
    frame = readFrame(v);
    brightness(frameCounter,1) = mean(frame(:,:,1),'all'); %#ok<AGROW>
    frameCounter = frameCounter+1;
end

dBrightness = diff(brightness);

[peakHeight,peakLocation] = findpeaks( ...
    -dBrightness,'MinPeakDistance',10);

assert(~isempty(peakHeight), ...
    'No synchronization-light transition detected.');

[~,idx] = max(peakHeight);
frameBegin = peakLocation(idx);

timeIndex = 0:1/cfg.frameRateHz:100;
timeBegin = timeIndex(frameBegin);

sync = struct();
sync.frame_begin = frameBegin;
sync.time_begin_sec = timeBegin;
sync.red_mean = brightness;
sync.red_diff = dBrightness;

end
