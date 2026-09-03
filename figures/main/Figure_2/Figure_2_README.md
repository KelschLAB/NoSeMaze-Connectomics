# Figure 2

Scripts used to reproduce the computational panels and statistical analyses shown in Figure 2.

## Panels

| Panel | Analysis | MATLAB / Python | Statistics |
|---|---|---|---|
| 2B | Eyelid responses in blocks 1 and 3 | `panel_B.m` | `panel_B_statistics.R` |
| 2C | Intrasession eyelid responses across blocks 1–3 | `panel_C.m` | `panel_C_statistics.R` |
| 2D | MRIcroGL visualization of activation and deactivation maps | `panel_D_mricrogl.py` | — |
| 2E | High-resolution BOLD heat maps for trials 11–40 | `panel_E.m` | — |

Generated outputs are written to:

```text
results/main/Figure_2/
```

## Required software

### MATLAB

MATLAB is required for panels 2B, 2C, and 2E.

Repository MATLAB helpers are loaded from:

```text
src/matlab/
```

### R

The statistical analyses for panels 2B and 2C require:

```r
install.packages(c(
  "here",
  "readxl",
  "lme4",
  "predictmeans"
))
```

The repository root is identified using the `.here` file.

### MRIcroGL

Panel 2D requires MRIcroGL and the custom shader:

```text
MatcapMix_JR
```

Because MRIcroGL's internal Python environment does not reliably expose the script location, edit the `repo_root` line at the beginning of `panel_D_mricrogl.py` before running it.

## Required data

### Panels 2B and 2C

```text
data/processed/eyelid/reappraisal/
├── pupil_summary_all.mat
├── Mean_LidData_R_TP1.xlsx
├── Mean_LidData_R_TP2.xlsx
└── Mean_LidData_R_intrasession.xlsx
```

The processed inputs used by `panel_B_statistics.R` were derived from the source-data files exported by `panel_B.m`:

- `Mean_LidData_R_TP1.xlsx`: time bins 22–31 (0.1–1.1 s after odor onset), using both
  - `results/main/Figure_2/SourceData_Figure2B_Block1_ConditioningCohort.csv`
  - `results/main/Figure_2/SourceData_Figure2B_Block3_ConditioningCohort.csv`
- `Mean_LidData_R_TP2.xlsx`: time bins 46–55 (2.5–3.5 s after odor onset), using both
  - `results/main/Figure_2/SourceData_Figure2B_Block1_ConditioningCohort.csv`
  - `results/main/Figure_2/SourceData_Figure2B_Block3_ConditioningCohort.csv`

### Panel 2D

Template:

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii
```

Statistical maps:

```text
data/processed/fMRI/Figure_2D/
├── activation*.nii
└── deactivation*.nii
```

Activation and deactivation files must form matching pairs. The deactivation filename is obtained by adding `de` to the beginning of the corresponding activation filename.

### Panel 2E

```text
data/processed/fMRI/Figure_2E/
├── mask_activation_v22_T001/
│   └── tc_matrsess_all_BINS6_TRsbefore2.mat
└── mask_deactivation_v22_T001/
    └── tc_matrsess_all_BINS6_TRsbefore2.mat
```

## Running

### Panel 2B

MATLAB:

```matlab
run('figures/main/Figure_2/panel_B.m')
```

R statistics:

```r
source("figures/main/Figure_2/panel_B_statistics.R")
```

The statistical model compares blocks 1 and 3 using animal as a random intercept.

### Panel 2C

MATLAB:

```matlab
run('figures/main/Figure_2/panel_C.m')
```

R statistics:

```r
source("figures/main/Figure_2/panel_C_statistics.R")
```

The linear mixed-effects model is:

```text
lid ~ block + (1 | animal)
```

The R script fits the linear mixed-effects model and uses 10,000-permutation inference for the reported p-values. The standard parametric model output is also saved for reference.

### Panel 2D

Open `panel_D_mricrogl.py` in MRIcroGL, edit:

```python
repo_root = r"path\to\NoSeMaze-Connectomics"
```

and run the script.

The visualization uses:

```text
activation:   8redyell
deactivation: 6bluegrn
thresholds:   3–15
shader:       MatcapMix_JR
```

Outputs are written to:

```text
results/main/Figure_2/Figure_2D/
```

### Panel 2E

```matlab
run('figures/main/Figure_2/panel_E.m')
```

The script:

- loads high-resolution trial-wise BOLD data;
- restores the original trial order;
- selects trials 11–40;
- calculates the median across animals;
- applies a 3-trial moving average;
- exports the heat map and source data.

Outputs are written to:

```text
results/main/Figure_2/Figure_2E/
├── mask_activation_v22_T001/
└── mask_deactivation_v22_T001/
```

Missing output directories are created automatically.
