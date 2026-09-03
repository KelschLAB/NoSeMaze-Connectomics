# Supplementary Figure S2

Scripts used to reproduce Supplementary Figure S2.

Figure S2 characterizes the no-puff control cohort at the proximal conditioned-response (`TPnoPuff`) time point and shows the corresponding olfactory-region BOLD time courses.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| S2A | Whole-brain activation and deactivation maps for the no-puff control cohort during PRE | `panel_A_mricrogl.py` |
| S2B | PRE vs TEST BOLD time courses in the olfactory bulb (OB) and anterior olfactory nucleus (AON) | `panel_B_OB_AON_timecourses_control.m` |

Generated outputs are written under:

```text
results/supplement/Figure_S2/
├── Figure_S2A/
    └── conditioning/
└── Figure_S2B/
    └── control/
```

## Required software

### MRIcroGL

Figure S2A requires MRIcroGL.

The rendering script uses the standard MRIcroGL color maps:

```text
8redyell
6bluegrn
```

and the custom shader:

```text
MatcapMix_JR
```

Because MRIcroGL's internal Python environment does not reliably expose the script location, edit the `repo_root` line near the beginning of `panel_A_mricrogl.py` before running it:

```python
repo_root = r"path\to\NoSeMaze-Connectomics"
```

### MATLAB

Figure S2B requires MATLAB.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

No custom analysis helper is required for the time-course calculation itself.

Optional provenance helper:

```text
docDataSrc.m
```

---

## Figure S2A — no-puff control activation/deactivation maps

### Anatomical template

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii.gz
```

### Statistical-map input

```text
data/processed/fMRI/Figure_S2/Figure_S2A/
├── activation*.nii
└── deactivation*.nii
```

For every file matching:

```text
activation*.nii
```

the script expects the matching deactivation map to be named by prefixing `de` to the activation filename.

Example:

```text
activation_example.nii
deactivation_example.nii
```

### Rendering

The script:

- loads the high-resolution Paxinos-space anatomical template;
- applies the historical extraction and intensity settings;
- reproduces the original Figure S2A mosaic;
- loads activation and deactivation maps as separate overlays;
- uses the display range `3–15` for both maps;
- renders activation with `8redyell`;
- renders deactivation with `6bluegrn`;
- clears overlays before processing the next map pair.

### Running

Open `panel_A_mricrogl.py` in MRIcroGL, edit `repo_root`, and run the script.

Outputs are written to:

```text
results/supplement/Figure_S2/Figure_S2A/
```

---

## Figure S2B — OB and AON BOLD time courses

Figure S2B shows BOLD time courses from the no-puff conditioning and control cohort for:

```text
OB  = olfactory bulb
AON = anterior olfactory nucleus
```

### Required data

```text
data/processed/fMRI/Figure_S2/Figure_S2B/conditioning/
├── OB/
│   └── tc_matrsess_all_BINS6_TRsbefore2.mat
└── AON/
    └── tc_matrsess_all_BINS6_TRsbefore2.mat
```
```text
data/processed/fMRI/Figure_S2/Figure_S2B/control/
├── OB/
│   └── tc_matrsess_all_BINS6_TRsbefore2.mat
└── AON/
    └── tc_matrsess_all_BINS6_TRsbefore2.mat
```

Each MAT file must contain:

```text
tc_matrsess_all_highres_lin
tc_matrsess_info.highres
```

`tc_matrsess_all_highres_lin` is expected in:

```text
subject × trial × time
```

format.

### Blocks

Only PRE and TEST are shown:

```text
PRE  = trials 11–40
TEST = trials 81–120
```

The intermediate no-puff/non-pairing block is not required for this panel.

### Analysis

For each ROI and mouse, the script first averages the high-resolution time courses across trials within PRE and TEST.

It then calculates:

```text
group mean across mice
SEM across mice
```

at each high-resolution time point.

Thus, the plotted uncertainty reflects between-mouse variability rather than pooled trial variability.

The original peri-stimulus timing convention is retained:

```text
TR = 1.2 s
displayed window = approximately -2.4 to 8.4 s
odor duration = 2.4 s
```

### Running

```matlab
run('figures/supplement/Figure_S2/panel_B_OB_AON_timecourses_control.m')
```

### Outputs

Outputs are written to:

```text
results/supplement/Figure_S2/Figure_S2B/conditioning/
```
```text
results/supplement/Figure_S2/Figure_S2B/control/
```

For each ROI, the script exports:

- group mean/SEM time-course source data;
- subject-level PRE time courses;
- subject-level TEST time courses.

It additionally exports:

- the combined OB/AON figure;
- analysis metadata;
- a complete MATLAB result structure.

## Notes

- Figure S2 contains no separate inferential-statistics script in the supplied reproduction workflow; S2B is a descriptive group mean ± SEM time-course visualization.
- The MATLAB script determines the repository root from its own location.
- The MRIcroGL script requires manual `repo_root` editing because it runs inside MRIcroGL's embedded Python environment.
- MATLAB helpers may be organized under `src/matlab/helpers/`; `addpath(genpath(srcDir))` loads them recursively.

