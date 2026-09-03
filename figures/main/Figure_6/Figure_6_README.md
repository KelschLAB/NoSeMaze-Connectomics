# Figure 6

Scripts used to reproduce the regional BOLD, social-hierarchy, network-adaptation, and mediation analyses shown in Figure 6.

Figure 6 combines thresholded whole-brain statistical-map visualization with extracted vHC BOLD values and the corresponding behavioral/network predictors.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| 6A | MRIcroGL visualization of the rank-related vHC deactivation map | `panel_A_mricrogl.py` |
| 6B | Social rank vs BOLD extracted from the rank-related vHC cluster | `panel_B_rank_vHC_BOLD.m` |
| 6C | MRIcroGL visualization of the fraction-of-losses-related activation map | `panel_C_mricrogl.py` |
| 6D | Fraction of tube-test losses vs BOLD extracted from the Figure 6C cluster | `panel_D_fraction_losses_BOLD.m` |
| 6E | MRIcroGL visualization of the ΔL-related deactivation map | `panel_E_mricrogl.py` |
| 6F | ΔL adaptation vs BOLD extracted from the Figure 6E cluster | `panel_F_deltaL_BOLD.m` |
| 6G | Mediation: social rank → ΔL adaptation → vHC BOLD response | `panel_G_H.R` |
| 6H | Conditional indirect effect / moderated mediation by social rank | `panel_G_H.R` |

Generated outputs are written under:

```text
results/main/Figure_6/
├── Figure_6A/
├── Figure_6B/
├── Figure_6C/
├── Figure_6D/
├── Figure_6E/
├── Figure_6F/
└── Figure_6G_H/
```

## Required software

### MATLAB

Panels 6B, 6D, and 6F require MATLAB.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

This includes helper functions stored under:

```text
src/matlab/helpers/
```

and its subfolders.

The Statistics and Machine Learning Toolbox is required for the correlation and parametric statistical functions used by the MATLAB analyses.

### MRIcroGL

Panels 6A, 6C, and 6E require MRIcroGL.

The following custom MRIcroGL resources must be available in the MRIcroGL installation:

```text
color maps:
    1LilaJR
    1RedJR
    1BrownJR

shader:
    MatcapMix_JR
```

These are MRIcroGL resources and are distinct from MATLAB colormap files stored under `src/matlab/helpers/colormaps/`.

Because MRIcroGL's internal Python environment does not reliably expose the script location, edit the `repo_root` line near the beginning of each MRIcroGL script before running it:

```python
repo_root = r"path\to\NoSeMaze-Connectomics"
```

### R

Panels 6G and 6H require R and the packages:

```r
install.packages(c(
  "readxl",
  "dplyr",
  "ggplot2",
  "mediation",
  "patchwork"
))
```

The reviewer-facing version of `panel_G_H.R` should determine the repository root from its own script location so that it can be sourced from any working directory.

## Common anatomical template

The MRIcroGL panels use:

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii.gz
```

The anatomical template is displayed with the original high-resolution settings and mosaic coordinates retained in the scripts.

---

## Figure 6A

### Required data

```text
data/processed/fMRI/Figure_6/Figure_6A/
└── deactivation*T01.nii
```

### Running

Open `panel_A_mricrogl.py` in MRIcroGL, edit `repo_root`, and run the script.

The visualization uses:

```text
overlay type: deactivation
threshold range: 2–5
color map: 1LilaJR
shader: MatcapMix_JR
```

Outputs are written to:

```text
results/main/Figure_6/Figure_6A/
```

---

## Figure 6B

Figure 6B relates social rank to mean BOLD values extracted from the rank-related vHC cluster shown in Figure 6A.

### NoSeMaze input

```text
data/processed/NoSeMaze/
├── 01_General_Overview.xlsx
├── AnimalNumb_to_ID.mat
└── tubetest/
    ├── NoSeMaze_1/
    │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
    │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
    └── NoSeMaze_2/
        └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
```

The General Overview determines which hierarchy window applies to each animal at the time of fMRI scanning.

Rank is derived from David's score, with rank 1 corresponding to the highest-ranked animal.

### Extracted BOLD input

```text
data/processed/fMRI/Figure_6/Figure_6B/
└── mask_positiveCorrRank_T01.mat
```

The MAT file must contain:

```text
res.mean_betaNeg
res.mean_betaPos
```

The current analysis interprets these as:

```text
PRE  = res.mean_betaNeg
TEST = res.mean_betaPos
```

and calculates:

```text
BOLD change = TEST - PRE
```

### MATLAB dependencies

Required helpers:

```text
notBoxPlot_modified.m
permutest.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

### Running

```matlab
run('figures/main/Figure_6/panel_B_rank_vHC_BOLD.m')
```

The script:

- reconstructs social rank using the hierarchy window relevant at scanning;
- aligns hierarchy information to MRI animal order using `AnimalNumb_to_ID.mat`;
- loads PRE and TEST vHC BOLD values;
- calculates TEST-minus-PRE BOLD change;
- reports Pearson and Spearman correlations for rank vs PRE, TEST, and BOLD change;
- retains the paired PRE-vs-TEST t-test and 10,000-permutation test;
- exports source data, statistics, metadata, MATLAB results, and figure files.

---

## Figure 6C

### Required data

```text
data/processed/fMRI/Figure_6/Figure_6C/
└── activation*T01.nii
```

### Running

Open `panel_C_mricrogl.py` in MRIcroGL, edit `repo_root`, and run the script.

The visualization uses:

```text
overlay type: activation
threshold range: 2–5
color map: 1RedJR
shader: MatcapMix_JR
```

Outputs are written to:

```text
results/main/Figure_6/Figure_6C/
```

---

## Figure 6D

Figure 6D relates the fraction of tube-test losses to BOLD extracted from the Figure 6C cluster.

### Required hierarchy data

The same NoSeMaze hierarchy files and animal mapping used for Figure 6B are required.

### Extracted BOLD input

```text
data/processed/fMRI/Figure_6/Figure_6D/
└── beta_fraction_losses_vHC_T01.mat
```

The MAT file must contain:

```text
res.mean_betaNeg
res.mean_betaPos
```

The script calculates the fraction of losses from the corresponding hierarchy match matrix:

```matlab
nLosses = sum(match_matrix, 1)';
frLosses = nLosses ./ sum(nLosses);
```

### MATLAB dependencies

Required helpers:

```text
notBoxPlot_modified.m
permutest.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

### Running

```matlab
run('figures/main/Figure_6/panel_D_fraction_losses_BOLD.m')
```

The script reports predictor associations with PRE, TEST, and TEST-minus-PRE BOLD values and retains the paired PRE-vs-TEST parametric/permutation analysis.

---

## Figure 6E

### Required data

```text
data/processed/fMRI/Figure_6/Figure_6E/
└── deactivation*T01.nii
```

### Running

Open `panel_E_mricrogl.py` in MRIcroGL, edit `repo_root`, and run the script.

The visualization uses:

```text
overlay type: deactivation
threshold range: 2–5
color map: 1BrownJR
shader: MatcapMix_JR
```

Outputs are written to:

```text
results/main/Figure_6/Figure_6E/
```

---

## Figure 6F

Figure 6F relates ΔL network adaptation to BOLD extracted from the ΔL-sensitive vHC cluster shown in Figure 6E.

### Graph-analysis input

The conditioning-cohort global graph data are reused from Figure 4:

```text
data/processed/fMRI/Figure_4/Figure_4C_E/conditioning/
├── auc_struc_TPnoPuff11to40_45to50_p.mat
└── auc_struc_TPnoPuff81to120_45to50_p.mat
```

The predictor is:

```text
ΔL adaptation =
g_delta_L(TEST) - g_delta_L(PRE)
```

### Extracted BOLD input

```text
data/processed/fMRI/Figure_6/Figure_6F/
└── mask_vHC_T01_corrdeltaL.mat
```

The MAT file must contain:

```text
res.mean_betaNeg
res.mean_betaPos
```

### MATLAB dependencies

Required helpers:

```text
notBoxPlot_modified.m
permutest.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

### Running

```matlab
run('figures/main/Figure_6/panel_F_deltaL_BOLD.m')
```

The script:

- loads PRE and TEST ΔL values;
- calculates subject-level ΔL TEST-minus-PRE change;
- loads PRE and TEST BOLD values;
- calculates BOLD TEST-minus-PRE change;
- reports Pearson and Spearman associations with the ΔL predictor;
- retains the paired PRE-vs-TEST BOLD t-test and 10,000-permutation analysis;
- exports source data, statistical results, MATLAB results, and figures.

---

## Figures 6G and 6H

Panels 6G and 6H use a combined processed dataset:

```text
data/processed/combined/
└── MediatorMediationData.xlsx
```

The spreadsheet must contain:

```text
social_rank
deltaL_change
vHC_BOLD_social_rank_T001
```

Rows with missing values in any of these variables are excluded.

All three analysis variables are standardized before model fitting.

### Figure 6G: mediation

The mediation model is:

```text
social rank → ΔL adaptation → vHC BOLD response
```

The path models are:

```r
DV  ~ IV
MED ~ IV
DV  ~ IV + MED
```

The analysis uses the `mediation` package with:

```text
bootstrap simulations = 1000
random seed = 123
BCa confidence interval for the mediation model
```

The script exports:

- path coefficients;
- ACME (indirect effect);
- ADE (direct effect);
- proportion mediated;
- source data;
- full mediation output;
- panel figure.

### Figure 6H: conditional indirect effect

The moderated outcome model is:

```r
DV ~ IV * MED
```

Because a smaller numeric social-rank value denotes higher rank:

```text
IV = -1 SD → high social rank
IV = +1 SD → low social rank
```

Conditional ACME estimates and bootstrap confidence intervals are calculated for these two rank levels.

### Running

After the repository-root handling in `panel_G_H.R` has been made script-relative:

```r
source("figures/main/Figure_6/panel_G_H.R")
```

Outputs are written to:

```text
results/main/Figure_6/Figure_6G_H/
```

including separate panel figures, a combined G/H figure, source data, statistics, full model summaries, and R session information.

## Notes on reproducibility

- MATLAB scripts determine the repository root from their own location.
- MRIcroGL scripts require manual editing of `repo_root` because of MRIcroGL's embedded Python environment.
- The R mediation script should determine the repository root from its own script location and should not depend on the active RStudio project or current working directory.
- MRIcroGL panels 6C and 6E should clear overlays before loading each new statistical map, matching the behavior already implemented in panel 6A.

