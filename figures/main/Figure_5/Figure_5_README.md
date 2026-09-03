# Figure 5

Scripts used to reproduce the social-rank analyses shown in Figure 5.

Figure 5 relates social hierarchy measures from the NoSeMaze to conditioning-related changes in global brain-network topology at the proximal conditioned-response time point (`TPnoPuff`).

- **PRE:** trials 11–40
- **TEST:** trials 81–120
- **Graph threshold range:** 45–50%

## Panels

| Panel | Analysis | Script |
|---|---|---|
| 5A | Social rank vs ΔC before conditioning, after conditioning, and for TEST−PRE change | `panel_A_B_D_globalGA_social_hierarchy.m` |
| 5B | Social rank vs ΔL before conditioning, after conditioning, and for TEST−PRE change | `panel_A_B_D_globalGA_social_hierarchy.m` |
| 5C | Social rank vs fraction of tube-test wins and losses | `panel_C_rank_win_loss_fractions.m` |
| 5D | Fraction of losses vs TEST−PRE changes in ΔC and ΔL | `panel_A_B_D_globalGA_social_hierarchy.m` |

Generated outputs are written to:

```text
results/main/Figure_5/
├── Figure_5A/
├── Figure_5B/
├── Figure_5C/
└── Figure_5D/
```

## Required software

### MATLAB

All Figure 5 analyses require MATLAB.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

Helper functions may therefore be stored under:

```text
src/matlab/helpers/
```

and its subfolders.

The Statistics and Machine Learning Toolbox is required for correlation and regression-line functions used in the Figure 5 analyses.

## Figure 5A, 5B, and 5D

### Graph-analysis input

The analyses reuse the conditioning-cohort global graph-metric AUC data generated for Figure 4C–E:

```text
data/processed/fMRI/Figure_4/Figure_4C_E/conditioning/
├── auc_struc_TPnoPuff11to40_45to50_p.mat
└── auc_struc_TPnoPuff81to120_45to50_p.mat
```

Each file must contain:

```text
auc_struc
```

The graph metrics relevant to Figure 5 are:

```text
g_delta_C
g_delta_L
g_swp
```

ΔC and ΔL are displayed in the main Figure 5. SWP is additionally included in the multiple-comparison family because manuscript inference is FDR-corrected across the three predefined global graph metrics ΔC, ΔL, and SWP.

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

The General Overview determines which hierarchy window applies to each animal at the time of fMRI scanning:

```text
NoSeMaze 1:
    days 3–16 or days 8–21,
    depending on DaysToConsider

NoSeMaze 2:
    days 1–14
```

Social rank is derived from David's score, with:

```text
rank 1  = highest social rank
rank 12 = lowest social rank
```

The fraction of losses is calculated from the hierarchy match matrix as the individual number of losses divided by the total number of losses/contests in the corresponding hierarchy window.

### Statistics

For each relevant graph metric:

```text
Δ = TEST - PRE
```

Pearson correlations are calculated between the behavioral variable and:

1. the PRE graph metric;
2. the TEST graph metric;
3. the TEST−PRE graph-metric change.

The main panel mapping is:

```text
Figure 5A: Rank vs ΔC
Figure 5B: Rank vs ΔL
Figure 5D: Fraction of losses vs ΔC and ΔL
```

For global graph metrics, multiple-comparison correction is performed using the Benjamini–Hochberg FDR procedure across the three predefined metrics:

```text
ΔC
ΔL
SWP
```

within each respective correlation family.

Raw Pearson correlation p-values are reported in the figures. A dagger (`†`) indicates that the corresponding effect survives FDR correction across the three global metrics.

## Figure 5C

Figure 5C decomposes social hierarchy into complementary dominance and subordination measures by plotting social rank against:

- fraction of wins;
- fraction of losses.

### Required data

```text
data/processed/NoSeMaze/
├── 01_General_Overview.xlsx
└── tubetest/
    ├── NoSeMaze_1/
    │   ├── DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
    │   └── DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
    └── NoSeMaze_2/
        └── DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
```

No fMRI or graph-analysis files are required for Figure 5C.

### Win/loss fractions

For each hierarchy window:

```matlab
nWins   = sum(match_matrix, 2);
nLosses = sum(match_matrix, 1)';

frWins   = nWins   ./ sum(nWins);
frLosses = nLosses ./ sum(nLosses);
```

Rank is derived from David's score, with rank 1 corresponding to the highest-ranked animal.

Figure 5C uses Pearson correlations between social rank and the fraction of wins/losses.

## MATLAB dependencies

### Figure 5A, 5B, and 5D

The final reviewer-facing script should require only the helpers needed for the displayed Figure 5 analyses. Repository helpers are loaded recursively from:

```text
src/matlab/
```

Optional provenance helper:

```text
docDataSrc.m
```

If FDR correction is implemented through a repository helper rather than a local function, that helper must also be available under `src/matlab/`.

### Figure 5C

No custom analysis helper is required.

Optional:

```text
docDataSrc.m
```

The Statistics and Machine Learning Toolbox is required for `corr` and `lsline`.

## Running

The scripts determine the repository root from their own location and can therefore be run without changing the MATLAB working directory.

### Figure 5A, 5B, and 5D

```matlab
run('figures/main/Figure_5/panel_A_B_D_globalGA_social_hierarchy.m')
```

The script:

- reconstructs the hierarchy measure appropriate for each animal's pre-scan time window;
- aligns behavioral data to MRI animal order using `AnimalNumb_to_ID.mat`;
- loads subject-level global graph AUC values for PRE and TEST;
- calculates TEST−PRE changes;
- calculates Pearson correlations with social rank or fraction of losses;
- evaluates FDR across ΔC, ΔL, and SWP within the corresponding analysis family;
- exports panel-specific source data, correlation statistics, metadata, MATLAB results, and figures.

### Figure 5C

```matlab
run('figures/main/Figure_5/panel_C_rank_win_loss_fractions.m')
```

The script:

- reconstructs social rank from David's score;
- calculates the individual fractions of wins and losses from the tube-test match matrix;
- uses the hierarchy window relevant at the time of fMRI scanning;
- calculates Pearson correlations with rank;
- exports source data, statistics, MATLAB results, and figure files.

## Outputs

Results are written under:

```text
results/main/Figure_5/
```

Each panel directory contains the corresponding figure files together with source-data CSV files, statistical output, metadata, and MATLAB result files.
