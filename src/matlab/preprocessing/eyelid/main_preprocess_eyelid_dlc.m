
%% main_preprocess_eyelid_dlc.m
%
% DLC eyelid landmarks -> polynomial eye-opening area -> synchronized trials.
%
% This active script contains only the final estimator used for the
% manuscript analysis: degree-2 polynomial fits through five points on the
% upper lid and five points on the lower lid.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
if isempty(scriptFile)
    error('Run the saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);

% .../src/matlab/preprocessing/eyelid -> repo root
repoRoot = fileparts(fileparts(fileparts(fileparts(scriptDir))));

addpath(genpath(fullfile(scriptDir,'functions')));

cfg = eyelid_config(repoRoot);

assert(isfile(cfg.manifestFile), ...
    ['Session manifest not found:\n%s\n' ...
     'Copy eyelid_sessions_template.csv to eyelid_sessions.csv and fill it.'], ...
    cfg.manifestFile);

if ~isfolder(cfg.outputDir)
    mkdir(cfg.outputDir);
end

T = readtable(cfg.manifestFile,'TextType','string');

required = [ ...
    "subject_id","session_id","condition","expected_trials", ...
    "protocol_file","dlc_csv","video_file", ...
    "video_start_frame","include" ...
];

missing = setdiff(required,string(T.Properties.VariableNames));

assert(isempty(missing), ...
    'Manifest missing column(s): %s',strjoin(missing,', '));

T = T(T.include~=0,:);

eyelid_summary = repmat(struct(),height(T),1);

for i = 1:height(T)

    protocolFile = resolve_manifest_path( ...
        T.protocol_file(i),cfg.processedProtocolRoot);

    dlcFile = resolve_manifest_path( ...
        T.dlc_csv(i),cfg.dlcRoot);

    videoFile = resolve_manifest_path( ...
        T.video_file(i),cfg.videoRoot);

    P = load_processed_eyelid_protocol(protocolFile);

    assert(numel(P.events)==T.expected_trials(i), ...
        'Session %s: expected %d trials, found %d.', ...
        T.session_id(i),T.expected_trials(i),numel(P.events));

    landmarks = read_dlc_eyelid_landmarks(dlcFile,cfg);

    fitResult = compute_eyelid_area_polyfit( ...
        landmarks,cfg);

    if isfinite(T.video_start_frame(i))

        syncVideo = struct();
        syncVideo.frame_begin = T.video_start_frame(i);
        syncVideo.time_begin_sec = ...
            (T.video_start_frame(i)-1)/cfg.frameRateHz;

    else

        assert(isfile(videoFile), ...
            ['Video required when video_start_frame is not specified:\n%s'], ...
            videoFile);

        syncVideo = find_video_start_frame(videoFile,cfg);
    end

    trials = align_eyelid_trials( ...
        fitResult.area, ...
        P.events, ...
        P.sync.video_led_off, ...
        syncVideo.frame_begin, ...
        cfg);

    S = struct();

    S.subject_id = char(T.subject_id(i));
    S.session_id = char(T.session_id(i));
    S.condition = char(T.condition(i));
    S.expected_trials = T.expected_trials(i);

    S.frame_rate_hz = cfg.frameRateHz;
    S.likelihood_threshold = cfg.likelihoodThreshold;
    S.bodyparts = cfg.bodyparts;

    S.eye_opening_area = fitResult.area;
    S.eye_rotation_deg = fitResult.rotation_angle_deg;
    S.valid_area_frame = fitResult.valid_frame;
    S.removed_coordinate_spikes = ...
        fitResult.removed_coordinate_spikes;

    S.video_sync = syncVideo;
    S.trials = trials;

    S.provenance = struct( ...
        'protocol_file',protocolFile, ...
        'dlc_csv',dlcFile, ...
        'video_file',videoFile);

    eyelid_summary(i) = S;
end

save(cfg.outputFile,'eyelid_summary','cfg','-v7.3');

fprintf('\nSaved eyelid preprocessing output:\n%s\n',cfg.outputFile);
