# Eyelid session manifest

Copy `eyelid_sessions_template.csv` to:

```text
eyelid_sessions.csv
```

and fill one row per recorded session.

Required columns:

- `subject_id`
- `session_id`
- `condition`
- `expected_trials`
- `protocol_file`
- `dlc_csv`
- `video_file`
- `video_sync_off_frame`
- `include`

`protocol_file`, `dlc_csv`, and `video_file` may be absolute paths or paths
relative to the external roots configured through environment variables.

`video_sync_off_frame` is optional. If supplied, it should be the first video
frame after the one-second synchronization LED has switched off. Providing it
makes reprocessing independent of automated LED detection and therefore
removes the need to distribute the raw video.

The three historical within-animal sessions can be represented as:

```text
ses1  conditioning  160 trials
ses2  post_1h        80 trials
ses3  post_24h       80 trials
```

The manuscript no-puff control recording can be added as a separate row with
`condition=no_puff_control` and its own 160-trial protocol/DLC/video files.
