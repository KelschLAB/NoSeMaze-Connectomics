
# Eyelid-response preprocessing

This module reproduces the video-based eyelid analysis used for the
manuscript.

The public preprocessing code contains **one eyelid geometry estimator
only**: the final quadratic-polynomial eye-opening-area calculation.

## Inputs

For each recording:

```text
processed synchronized protocol MAT
raw DeepLabCut CSV
WMV video, unless the synchronization frame is already stored in manifest
```

Only the eight eyelid landmarks are read from the DeepLabCut CSV:

```text
LidN
LidNE
LidE
LidSE
LidS
LidSW
LidW
LidNW
```

## Final eye-opening-area calculation

For every frame:

```text
8 eyelid landmarks
    ↓
likelihood threshold
    ↓
short-gap/spike correction
    ↓
rotate E-W corner axis horizontally
    ↓
upper lid: W, NW, N, NE, E
lower lid: W, SE, S, SW, E
    ↓
degree-2 polyfit for upper and lower lid
    ↓
evaluate at 0.1-pixel spacing
    ↓
back-rotate fitted contours
    ↓
trapz area between contours
```

There are no alternative ellipse, contour-interpolation, polygon-area, or
eyelid-distance estimators in the active repository code.

## Video/RHD synchronization

The first 60 seconds of the video are searched for the largest negative
red-channel brightness transition. This marks the OFF transition of the
video synchronization light.

The same event is recorded in the Intan data. Historical digital channels:

```text
1  air puff
2  odor/final valve
7  video synchronization light
```

Odor times are expressed relative to the first synchronization-light OFF
transition and mapped to the 10-Hz video time grid.

## Trial data used by the figures

The source-data generating MATLAB workflow used:

```text
video rate       10 Hz
trial window     -1.9 to +9.9 s
baseline         19 frames immediately before odor onset
normalization    eye-opening area / trial baseline
distal CR        0.1–1.1 s
proximal CR      2.5–3.5 s
```

The baseline-normalized trial matrix is passed through the same historical
short-spike/NaN correction before figure/statistical analysis.

For tonic eyelid adaptation, use the non-normalized `eye_opening_area`
trial matrix.

## Likelihood-threshold provenance

The source-data-generating MATLAB master used an eyelid likelihood
threshold of **0.80**. The current manuscript text states **0.95**.

The active repository code keeps 0.80 to reproduce the historical source
data. This should be reconciled in the manuscript or by intentionally
regenerating the source data before repository freeze.
