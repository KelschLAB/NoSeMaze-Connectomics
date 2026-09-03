# Supplementary Figure S9

Scripts used to reproduce Supplementary Figure S9, which tests the robustness of the association between social hierarchy and global graph-network organization.

## Script

```text
figure_S9_rank_graphmetrics_threshold_robustness.m
```

The script reproduces all four S9 panels.

## Panels

| Panel | Predictor | Graph-density AUC |
|---|---|---:|
| S9A | Linear social rank | 45–50% |
| S9B | Linear social rank | 10–50% |
| S9C | Linear social rank | 40–50% |
| S9D | z-scored David's score (`DSz`) | 45–50% |

Each panel contains the same three global graph metrics:

```text
g_delta_C
g_delta_L
g_swp
```

and uses the proximal conditioned-response analysis:

```text
PRE  = TPnoPuff trials 11–40
TEST = TPnoPuff trials 81–120
```

Outputs are written to:

```text
results/supplement/Figure_S9/
├── Figure_S9A/
├── Figure_S9B/
├── Figure_S9C/
└── Figure_S9D/
```

## Required data

### Social-hierarchy data

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

The hierarchy windows correspond to the same pre-scan periods used elsewhere in the repository:

```text
NoSeMaze 1 / scan group 1: days 3–16
NoSeMaze 1 / scan group 2: days 8–21
NoSeMaze 2:                days 1–14
```

Linear social rank is reconstructed from David's score:

```text
rank 1  = highest David's score
rank 12 = lowest David's score
```

For S9D, David's score is z-scored within each relevant hierarchy before animals are combined.

### Graph-metric data

```text
data/processed/fMRI/Figure_S9/conditioning/
├── auc_struc_TPnoPuff11to40_45to50_p.mat
├── auc_struc_TPnoPuff81to120_45to50_p.mat
├── auc_struc_TPnoPuff11to40_10to50_p.mat
├── auc_struc_TPnoPuff81to120_10to50_p.mat
├── auc_struc_TPnoPuff11to40_40to50_p.mat
└── auc_struc_TPnoPuff81to120_40to50_p.mat
```

Each MAT file must contain:

```text
auc_struc
```

with the fields:

```text
g_delta_C
g_delta_L
g_swp
```

The corrected script verifies that PRE and TEST sample sizes are identical across every metric and threshold range and match the hierarchy predictor vectors.

## Analysis

For each panel and each graph metric, Pearson correlations are calculated for:

```text
predictor vs PRE
predictor vs TEST
predictor vs TEST-PRE
```

Thus each S9 panel is arranged as:

```text
                 ΔC        ΔL        SWP
PRE + TEST       ...       ...       ...
TEST - PRE       ...       ...       ...
```

Raw Pearson p-values are displayed in the figure.

### Multiple-testing correction

Benjamini-Hochberg FDR correction is performed across the three predefined global metrics:

```text
ΔC
ΔL
SWP
```

separately for each inferential family:

```text
PRE correlations
TEST correlations
TEST-PRE correlations
```

Therefore each panel contains three independent three-test FDR families.

The script exports both:

```text
RawP
FDR_Q_across_3_metrics
```

A dagger in the figure marks a correlation surviving the corresponding FDR correction.

## MATLAB requirements

The script determines the repository root from its own location and loads MATLAB code recursively from:

```text
src/matlab/
```

Optional:

```text
docDataSrc.m
```

The Statistics and Machine Learning Toolbox is required for:

```text
corr
zscore
```

## Running

From MATLAB:

```matlab
run('figures/supplement/Figure_S9/figure_S9_rank_graphmetrics_threshold_robustness.m')
```

## Outputs

Each panel directory contains:

```text
SourceData_Figure_S9?.csv
Statistics_Figure_S9?.csv
AnalysisMetadata_Figure_S9?.csv
Results_Figure_S9?.mat
Figure_S9?.pdf
Figure_S9?.png
Figure_S9?.fig
```

## Repository check

The supplied S9 script was already internally consistent in its central analysis:

- S9A uses rank at 45–50%;
- S9B repeats rank over the broader 10–50% range;
- S9C repeats rank over 40–50%;
- S9D substitutes z-scored David's score for rank at 45–50%;
- FDR is genuinely calculated across all three global metrics separately for PRE, TEST, and TEST-PRE.

The cleanup therefore does **not** change the statistical analysis. It only adds stricter repository/source-directory and sample-size checks plus an explicit metadata export.
