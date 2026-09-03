
function process_protocol_eyelid(pairs,cfg)
% PROCESS_PROTOCOL_EYELID Synchronize odor, air-puff and video TTL signals.
%
% Exact historical channel mapping:
%   dchannels(:,1) = air puff
%   dchannels(:,2) = odor/final valve
%   dchannels(:,7) = video synchronization light
%
% Output terminology is cleaned to eyelid/video semantics.

for i = 1:numel(pairs)

    S = load(pairs(i).protocolFile);

    assert(isfield(S,'session') && isfield(S.session,'trialmatrix'), ...
        'Protocol lacks session.trialmatrix: %s',pairs(i).protocolFile);

    events = S.session.trialmatrix;
    nTrials = numel(events);

    rhdFiles = pairs(i).rhdFiles;

    rhdDirs = unique(cellfun(@fileparts,rhdFiles,'UniformOutput',false));
    assert(numel(rhdDirs)==1, ...
        'All RHD segments for one session must share one directory.');

    intanPath = [rhdDirs{1} filesep];
    intanFiles = cell(size(rhdFiles));

    for r = 1:numel(rhdFiles)
        [~,name,ext] = fileparts(rhdFiles{r});
        intanFiles{r} = [name ext];
    end

    workDir = fullfile(cfg.workDir,pairs(i).key);
    if ~isfolder(workDir)
        mkdir(workDir);
    end

    [~,recordingParams] = RhdToMat_lw( ...
        intanPath,intanFiles,workDir);

    freq = ...
        recordingParams.frequency_parameters.amplifier_sample_rate;

    digitalFiles = list_files_recursive(workDir,'*digital.mat');

    assert(numel(digitalFiles)==1, ...
        'Expected one generated digital.mat for %s.',pairs(i).key);

    D = load(digitalFiles{1},'dchannels');
    dchannels = D.dchannels;

    assert(size(dchannels,2)>=cfg.channel.videoSync, ...
        'Digital data contain fewer than seven channels.');

    odor = detect_pulses( ...
        dchannels(:,cfg.channel.odor),freq);

    airPuff = detect_pulses( ...
        dchannels(:,cfg.channel.airPuff),freq);

    videoSync = detect_pulses( ...
        dchannels(:,cfg.channel.videoSync),freq);

    odorKeep = ...
        odor.duration>=cfg.odorDurationRangeSec(1) & ...
        odor.duration<=cfg.odorDurationRangeSec(2);

    odor = keep_pulses(odor,odorKeep);

    assert(numel(odor.on)==nTrials, ...
        'Detected %d odor TTLs; protocol contains %d trials.', ...
        numel(odor.on),nTrials);

    puffKeep = ...
        airPuff.duration>=cfg.airPuffDurationRangeSec(1) & ...
        airPuff.duration<=cfg.airPuffDurationRangeSec(2);

    airPuff = keep_pulses(airPuff,puffKeep);

    for t = 1:nTrials

        events(t).odor_on = odor.on(t);
        events(t).odor_off = odor.off(t);
        events(t).odor_duration = odor.duration(t);

        if t<nTrials
            upper = odor.on(t+1);
        elseif isfield(events(t),'ITI')
            upper = odor.on(t)+events(t).ITI+2;
        else
            upper = inf;
        end

        hit = find( ...
            airPuff.on>odor.on(t) & ...
            airPuff.on<upper);

        if isempty(hit)

            events(t).has_air_puff = false;

            % Historical expected puff time for non-puff trials.
            events(t).air_puff_on = odor.on(t)+3.2;
            events(t).air_puff_off = NaN;

        else

            assert(numel(hit)==1, ...
                'Multiple air-puff TTLs detected within trial %d.',t);

            events(t).has_air_puff = true;
            events(t).air_puff_on = airPuff.on(hit);
            events(t).air_puff_off = airPuff.off(hit);
        end
    end

    assert(~isempty(videoSync.on), ...
        'No video synchronization-light pulse detected.');

    sync = struct();

    sync.video_led_start_on = videoSync.on(1);
    sync.video_led_start_off = videoSync.off(1);
    sync.video_led_off = sync.video_led_start_off;

    if numel(videoSync.on)>=2
        sync.video_led_end_on = videoSync.on(2);
        sync.video_led_end_off = videoSync.off(2);
    else
        sync.video_led_end_on = NaN;
        sync.video_led_end_off = NaN;
    end

    provenance = struct();
    provenance.protocol_file = pairs(i).protocolFile;
    provenance.rhd_files = rhdFiles;
    provenance.sample_rate_hz = freq;
    provenance.channel_air_puff = cfg.channel.airPuff;
    provenance.channel_odor = cfg.channel.odor;
    provenance.channel_video_sync = cfg.channel.videoSync;

    session = S.session; %#ok<NASGU>

    outputFile = fullfile( ...
        cfg.outputDir,[pairs(i).key '_eyelid_protocol.mat']);

    save(outputFile, ...
        'events','session','sync','freq','provenance');
end

end

function p = detect_pulses(trace,freq)

d = diff(trace);

on = find(d==1)/freq;
off = find(d==-1)/freq;

if numel(off)>numel(on)
    off(1) = [];
end

n = min(numel(on),numel(off));

p = struct();
p.on = on(1:n);
p.off = off(1:n);
p.duration = p.off-p.on;

end

function p = keep_pulses(p,keep)

p.on = p.on(keep);
p.off = p.off(keep);
p.duration = p.duration(keep);

end
