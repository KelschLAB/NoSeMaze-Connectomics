# Supplementary Figure S1

Scripts used to reproduce the eyelid-response analyses shown in Supplementary Figure S1.

Supplementary Figure S1 characterizes the acquisition and within-session evolution of conditioned eyelid responses in the separate eyelid-recording cohort and compares these responses with no-puff control sessions.

## Panels

| Panel | Analysis | Script(s) |
|---|---|---|
| S1A | Example eyelid video frames with DeepLabCut landmarks and fitted upper/lower lid curves | No computational reproduction script in this folder |
| S1B | Phasic distal and proximal conditioned responses across the extended test period | `panel_B_lid_timecourses.m`, `panel_B_tp1_lid_stats.R`, `panel_B_tp2_lid_stats.R` |
| S1C | Tonic eyelid opening across PRE, PAIRING, TEST, and ADDITIONAL TEST | `panel_C_lid_boxplot.m`, `panel_C_lid_stats.R` |
| S1D | No-puff control: tonic response and phasic distal/proximal responses | `panel_D_lid_boxplot.m`, `panel_D_lid_stats.R`, `panel_D_lid_timecourses_control.m`, `panel_D_tp1_lid_stats.R`, `panel_D_tp2_lid_stats.R` |

Generated outputs are written under:

```text
results/supplement/Figure_S1/
├── Figure_S1B/
├── Figure_S1C/
└── Figure_S1D/
```

## Eyelid-response definitions

Phasic conditioned responses are quantified in two predefined time windows:

```text
TP1 / distal CR:
    0.1–1.1 s after odor onset

TP2 / proximal CR:
    2.5–3.5 s after odor onset
    (expected air-puff time)
```

For the conditioning/reappraisal cohort, the odor-only test period was extended to 80 trials and divided into four consecutive 20-trial sub-blocks:

```text
TEST 1: trials 81–100
TEST 2: trials 101–120
TEST 3: trials 121–140
TEST 4: trials 141–160
```

The first two sub-blocks correspond to the 40-trial test block used in the fMRI experiment.

## Required software

### MATLAB

The plotting scripts require MATLAB.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

This includes helper functions stored under `src/matlab/helpers/` and its subfolders.

Required plotting helpers are:

```text
shadedErrorBar.m
SEM_calc.m
notBoxPlot_modified_pupilANDlid.m
```

Optional:

```text
docDataSrc.m
```

### R

The statistical scripts require the following packages:

```r
install.packages(c(
  "readxl",
  "lmerTest",
  "predictmeans"
))
```

All R scripts determine the repository root from their own location. They can therefore be sourced from any R working directory or RStudio project.

---

## Figure S1B — phasic conditioned responses

Figure S1B shows baseline-normalized phasic eyelid responses in the conditioning/reappraisal cohort.

### Required plotting data

```text
data/processed/eyelid/reappraisal/
└── pupil_summary_all.mat
```

The MAT file must contain:

```text
summary_all
```

with:

```text
LidBaseDiameterMatrix_Corrected
```

The MATLAB script selects the conditioning/reappraisal sessions from the historical `summary_all` ordering using:

```matlab
summary_all(1:3:end)
```

### Displayed periods

```text
PRE:              trials 11–40
TEST 1:           trials 81–100
TEST 2:           trials 101–120
TEST 3:           trials 121–140
TEST 4:           trials 141–160
```

The pairing block (trials 41–80) is deliberately excluded from the reviewer-facing S1B time-course plot and inferential comparison.

### Statistical inputs

```text
data/processed/eyelid/reappraisal/
├── Mean_LidData_R_6blocks_TP1.xlsx
└── Mean_LidData_R_6blocks_TP2.xlsx
```

Required columns are:

```text
animal_ID
block
lid_TP1    # distal CR
```

or:

```text
animal_ID
block
lid_TP2    # proximal CR
```

The historical six-block processed tables use:

```text
block 1 = PRE, trials 11–40
block 2 = pairing, trials 41–80
block 3 = TEST, trials 81–100
block 4 = TEST, trials 101–120
block 5 = TEST, trials 121–140
block 6 = TEST, trials 141–160
```

For Supplementary Figure S1B, the R scripts explicitly retain block codes:

```text
1, 3, 4, 5, 6
```

and exclude the pairing block (`block 2`).

### Statistics

Separate models are fitted for TP1 and TP2:

```text
lid_TP1 ~ test period + (1 | animal_ID)
lid_TP2 ~ test period + (1 | animal_ID)
```

The period factor contains PRE plus the four extended-test sub-blocks.

The scripts save the standard linear mixed-effects model output and perform permutation inference using:

```text
predictmeans::permmodels()
10,000 permutations
random seed = 1234
```

### Running

MATLAB:

```matlab
run('figures/supplement/Figure_S1/panel_B_lid_timecourses.m')
```

R:

```r
source("figures/supplement/Figure_S1/panel_B_tp1_lid_stats.R")
source("figures/supplement/Figure_S1/panel_B_tp2_lid_stats.R")
```

Outputs are written to:

```text
results/supplement/Figure_S1/Figure_S1B/
```

---

## Figure S1C — tonic eyelid opening across four periods

Figure S1C analyzes the non-normalized tonic eyelid response in the conditioning/reappraisal cohort across four periods:

```text
PRE:              trials 11–40
PAIRING:          trials 41–80
TEST:             trials 81–120
ADDITIONAL TEST:  trials 121–160
```

Importantly, the TEST block is **not** separated into trials 81–100 and 101–120 for S1C, and the ADDITIONAL TEST block is **not** separated into trials 121–140 and 141–160. Each is analyzed as one 40-trial period.

### Required data

The MATLAB plotting script uses:

```text
data/processed/eyelid/reappraisal/
└── pupil_summary_all.mat
```

The MAT file must contain:

```text
summary_all
```

with the non-normalized eyelid measure:

```text
LidDiameterMatrix
```

The conditioning/reappraisal sessions are selected from the historical session ordering using:

```matlab
summary_all(1:3:end)
```

For every mouse, `panel_C_lid_boxplot.m` averages the non-normalized `LidDiameterMatrix` values across all trials and time samples within each of the four periods.

It then exports the exact long-format table used for statistics:

```text
results/supplement/Figure_S1/Figure_S1C/
└── SourceData_Figure_S1C_tonic_lid_four_periods.csv
```

### Statistics

Run the MATLAB script first. The R script then analyzes the exported four-period source table.

The mixed-effects model is:

```text
lid ~ block_label + (1 | animal_ID)
```

with PRE as the reference period and:

```text
PAIRING
TEST
ADDITIONAL TEST
```

as the remaining factor levels.

The R script saves the standard mixed-effects output and performs permutation inference using:

```text
predictmeans::permmodels()
10,000 permutations
random seed = 1234
```

### Running

MATLAB:

```matlab
run('figures/supplement/Figure_S1/panel_C_lid_boxplot.m')
```

Then R:

```r
source("figures/supplement/Figure_S1/panel_C_lid_stats.R")
```

Outputs are written to:

```text
results/supplement/Figure_S1/Figure_S1C/
```

---

## Figure S1D — no-puff control

Figure S1D tests whether comparable tonic or phasic eyelid responses develop in no-puff control sessions.

### Tonic response

Required input:

```text
data/processed/eyelid/control/
└── Mean_LidData_R_intrasession_control.xlsx
```

Required columns:

```text
animal_ID
block
lid
```

The analysis includes:

```text
block 1 = PRE
block 2 = NON-PAIRING
block 3 = TEST
```

Run:

```matlab
run('figures/supplement/Figure_S1/panel_D_lid_boxplot.m')
```

and:

```r
source("figures/supplement/Figure_S1/panel_D_lid_stats.R")
```

### Phasic responses

Required plotting data:

```text
data/processed/eyelid/control/
└── pupil_summary_all.mat
```

with:

```text
summary_all
└── LidBaseDiameterMatrix_Corrected
```

The historical control-specific exclusion is retained:

```matlab
summary_all(2) = [];
```

The displayed periods are:

```text
PRE:              trials 11–40
NON-PAIRING:      trials 41–80
TEST:             trials 81–120
```

Run:

```matlab
run('figures/supplement/Figure_S1/panel_D_lid_timecourses_control.m')
```

### Phasic statistical inputs

Distal CR / TP1:

```text
data/processed/eyelid/control/
└── Mean_LidData_R_control_block1to3_TP1.xlsx
```

Proximal CR / TP2:

```text
data/processed/eyelid/control/
└── Mean_LidData_R_control_block1to3_TP2.xlsx
```

Required columns are:

```text
animal_ID
block
lid_TP1
```

or:

```text
animal_ID
block
lid_TP2
```

Run:

```r
source("figures/supplement/Figure_S1/panel_D_tp1_lid_stats.R")
source("figures/supplement/Figure_S1/panel_D_tp2_lid_stats.R")
```

The models compare PRE, NON-PAIRING, and TEST using a random intercept for mouse identity and 10,000-permutation inference.

Outputs for both tonic and phasic control analyses are written to:

```text
results/supplement/Figure_S1/Figure_S1D/
```

Tonic and phasic outputs use distinct filenames to prevent one analysis from overwriting the other.

---

## Notes

- Panel S1A is an illustrative panel based on representative eyelid-video frames and DeepLabCut landmarks; no analysis script for this panel is included here.
- MATLAB and R scripts use repository-relative paths.
- No local absolute paths or active-project assumptions are required.
- The MATLAB scripts load repository helpers recursively, so helpers can be organized under `src/matlab/helpers/`.
- The R scripts preserve both standard mixed-effects output and the permutation output used for inferential reporting.
