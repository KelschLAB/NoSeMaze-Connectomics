# Supplementary Figure S11

Scripts used to reproduce Supplementary Figure S11, which relates social rank to ventral hippocampal (vHC) BOLD responses during aversive recall.

## Panels

| Panel | vHC cluster definition | Script |
|---|---|---|
| S11A | rank-related vHC cluster at `pCDT < 0.01` (`T01`) | `panel_A_rank_vHC_BOLD.m` |
| S11B | more stringent vHC cluster at `pCDT < 0.001` (`T001`) | `panel_B_rank_vHC_BOLD.m` |

Both panels use the same behavioral and BOLD analysis; only the vHC cluster-defining threshold differs.

Outputs are written to:

```text
results/supplement/Figure_S11/
├── Figure_S11A/
└── Figure_S11B/
```

## Common analysis definition

Both panels use:

```text
conditioning cohort only
behavior = linear social rank
ROI      = ventral hippocampus (vHC)
PRE      = TPnoPuff trials 11–40
TEST     = TPnoPuff trials 81–120
preprocessing = no scrubbing
```

The Supplementary Figure S11 caption describes S11A as the vHC cluster defined at `pCDT < 0.01` and S11B as the analogous analysis using the more stringent `pCDT < 0.001` cluster.

## Required hierarchy data

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

The relevant pre-scan hierarchy is selected for each mouse and David's scores are converted to linear social rank:

```text
rank 1  = highest David's score
rank 12 = lowest David's score
```

Animal IDs are then mapped to MRI animal numbers with:

```text
AnimalNumb_to_ID.mat
```

and sorted to match the BOLD extraction order.

---

## Figure S11A — vHC cluster at pCDT < 0.01

Input:

```text
data/processed/fMRI/Figure_S11/Figure_S11A/
└── mask_positiveCorrRank_T01.mat
```

Expected MAT structure:

```text
res.mean_betaNeg   -> PRE
res.mean_betaPos   -> TEST
```

Run:

```matlab
run('figures/supplement/Figure_S11/panel_A_rank_vHC_BOLD.m')
```

---

## Figure S11B — stringent vHC cluster at pCDT < 0.001

Input:

```text
data/processed/fMRI/Figure_S11/Figure_S11B/
└── mask_positiveCorrRank_T001.mat
```

Expected MAT structure:

```text
res.mean_betaNeg   -> PRE
res.mean_betaPos   -> TEST
```

Run:

```matlab
run('figures/supplement/Figure_S11/panel_B_rank_vHC_BOLD.m')
```

## Statistics

Each panel retains three displayed components:

```text
1. PRE versus TEST mean vHC BOLD
2. Rank versus PRE and TEST mean vHC BOLD
3. Rank versus TEST-PRE BOLD change
```

### PRE versus TEST

Both scripts calculate:

```text
paired t-test
paired permutation test
```

with:

```text
10,000 permutations
seed = 1234
```

The permutation p-value is used for the displayed PRE-versus-TEST annotation.

### Rank correlations

For PRE, TEST and TEST-PRE BOLD change, both scripts report:

```text
Pearson correlation
Spearman correlation
```

The linear regression lines shown by `lsline` correspond to the Pearson association.

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

## Corrections made

The supplied analyses themselves were already consistent. The cleanup only fixes panel/file labeling:

1. The S11A header incorrectly listed `mask_positiveCorrRank_T001.mat`; the executable code correctly used `mask_positiveCorrRank_T01.mat`. The header now matches the analysis.
2. The S11B script correctly used the `T001` mask and `Figure_S11B` input/output directories, but many titles, CSV/MAT filenames and completion messages still said `S11A`. These are now consistently labeled `S11B`.

No statistical analysis was changed.
