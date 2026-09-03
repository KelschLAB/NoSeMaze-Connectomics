# Supplementary Figure S10

Scripts used to reproduce Supplementary Figure S10, which tests whether the social-rank dependence of global graph adaptation is also present at the distal conditioned response (odor onset).

## Script

```text
panel_A_B_rank_globalGA_distalCR.m
```

## Panels

| Panel | Analysis |
|---|---|
| S10A | Social rank versus distal-CR ΔC |
| S10B | Social rank versus distal-CR ΔL |

The plotted panels are restricted to the conditioning cohort and use linear social rank.

Outputs are written under:

```text
results/supplement/Figure_S10/
├── Figure_S10A/
└── Figure_S10B/
```

A combined rank-correlation FDR summary is additionally written to:

```text
results/supplement/Figure_S10/
└── Figure_S10_Rank_GlobalMetrics_FDR_Summary.csv
```

## Distal-CR definition

Figure S10 deliberately uses the distal CR / odor-onset graph-analysis outputs:

```text
PRE  = Odor trials 11–40
TEST = Odor trials 81–120
```

These files must not be replaced by the proximal `TPnoPuff` inputs used for the main graph figures.

The graph density AUC is:

```text
45–50%
```

corresponding to historical threshold indices:

```text
36:41
```

## Required data

### Social hierarchy

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

The hierarchy window is selected according to each animal's scan period, and David's scores are converted to ordinal rank:

```text
rank 1  = highest David's score
rank 12 = lowest David's score
```

Animal IDs are mapped to MRI animal numbers with:

```text
AnimalNumb_to_ID.mat
```

before sorting to match graph-data order.

### Distal graph metrics

```text
data/processed/fMRI/Figure_S10/
├── auc_struc_Odor11to40_45to50_p.mat
└── auc_struc_Odor81to120_45to50_p.mat
```

Each file must contain:

```text
auc_struc
```

with:

```text
g_delta_C
g_delta_L
g_swp
```

Only ΔC and ΔL receive displayed panels. SWP is retained internally for multiple-testing correction.

## Analyses

For S10A and S10B, each panel retains the three-part layout:

```text
1. PRE vs TEST graph metric
2. Rank vs PRE and TEST
3. Rank vs TEST-PRE graph change
```

### PRE versus TEST

The script exports:

```text
paired t-test
paired permutation test
```

with:

```text
10,000 permutations
seed = 1234
```

### Rank associations

Pearson correlations are calculated for:

```text
Rank vs PRE
Rank vs TEST
Rank vs TEST-PRE
```

A Spearman correlation for `Rank vs TEST-PRE` is retained as an additional robustness statistic.

## Global-metric FDR correction

The manuscript defines the global graph metrics as one predefined multiple-testing family:

```text
ΔC
ΔL
SWP
```

Therefore the corrected Figure S10 script calculates the otherwise unplotted SWP rank associations and performs Benjamini-Hochberg FDR separately for:

```text
Rank vs PRE
Rank vs TEST
Rank vs TEST-PRE
```

across the three metrics.

Thus:

```text
S10A = ΔC displayed
S10B = ΔL displayed
SWP  = internal FDR metric only
```

Raw Pearson p-values remain the displayed values. A dagger is added only if the corresponding rank association survives the three-metric FDR correction.

The Spearman robustness statistic and the descriptive PRE-vs-TEST comparison are not included in these rank-correlation FDR families.

## MATLAB dependencies

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

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

The Statistics and Machine Learning Toolbox is required for:

```text
corr
ttest
lsline
```

## Running

```matlab
run('figures/supplement/Figure_S10/panel_A_B_rank_globalGA_distalCR.m')
```

## Repository check

The supplied script already had the correct distal-CR inputs, panel mapping, density range, animal-rank reconstruction, and graph-data alignment checks.

The substantive correction is that the original script only loaded `g_delta_C` and `g_delta_L`, even though the manuscript specifies FDR correction across the predefined global metric family ΔC/ΔL/SWP. The corrected script therefore loads `g_swp` internally and uses it for rank-correlation FDR without adding an S10C panel.
