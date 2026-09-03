# Historical eyelid preprocessing provenance

The original working pipeline was embedded in scripts whose filenames,
variables, directories, and output MAT files also referred to pupil and
recording modalities that are not part of the manuscript eyelid analysis.
Those labels are intentionally not carried into the active pipeline.

Important historical behavior visible in the supplied master:

- video frame rate = 10 Hz;
- raw/unfiltered DLC CSVs were selected;
- active eyelid likelihood threshold = 0.80;
- video/task alignment used the off transition of a session-start trigger;
- trial window = -1.9 to 9.9 s in 0.1-s steps;
- baseline = the 1.9 s immediately preceding odor onset;
- a custom `RemovePikes_NaN_jr` stage was applied to the ratio-normalized
  trial matrix.

The final Supplement instead describes >95% likelihood for all eyelid markers
and a -2-to-0-s baseline. The cleaned parent pipeline makes this distinction
explicit through selectable profiles.

Two original helper implementations were not supplied and therefore cannot
be claimed as byte-identical historical code:

```text
pupil_load_and_fit_ellipse_ephys_2022.m
Find_StartFrame.m
```

Their manuscript-relevant roles are replaced explicitly by
`compute_eye_opening_area.m` and `detect_video_sync_led.m`.
