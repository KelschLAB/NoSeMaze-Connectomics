# Supplementary Figure S8

Scripts used to reproduce Supplementary Figure S8.

The revised supplementary caption defines the panels as:

```text
S8A   social rank assignments used for the fMRI analyses
S8B   week-to-week stability of z-scored David's score
S8C   week-to-week stability of linear social rank
S8D   fraction of wins versus ΔC
S8E   fraction of wins versus ΔL
```

## Scripts

| Panel | Analysis | Script |
|---|---|---|
| S8A | Social rank across conditioning-fMRI animals | `panel_A_social_rank_by_animal.m` |
| S8B-C | Week-to-week David's-score and rank stability | `panel_B_C_week1_week2_rank_DS.m` |
| S8D-E | Fraction of wins versus proximal-CR ΔC and ΔL | `panel_D_E_fr_winner_globalGA.m` |

Outputs are written under:

```text
results/supplement/Figure_S8/
├── Figure_S8A/
├── Figure_S8B_C/
├── Figure_S8D/
└── Figure_S8E/
```

## MATLAB setup

All scripts determine the repository root from their own location and load repository MATLAB code recursively from:

```text
src/matlab/
```

Optional provenance helper:

```text
docDataSrc.m
```

The Statistics and Machine Learning Toolbox is required for the correlation and graph-metric analyses.

---

## Figure S8A — social-rank assignments

Input:

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

Hierarchy windows:

```text
NoSeMaze 1, scan-day group 1: days 3–16
NoSeMaze 1, scan-day group 2: days 8–21
NoSeMaze 2:                   days 1–14
```

David's scores are converted to ordinal ranks:

```text
rank 1  = highest David's score
rank 12 = lowest David's score
```

The plot is sorted by social rank for display while retaining the corresponding animal IDs.

Run:

```matlab
run('figures/supplement/Figure_S8/panel_A_social_rank_by_animal.m')
```

---

## Figure S8B-C — week-to-week hierarchy stability

Input:

```text
data/processed/NoSeMaze/tubetest/
├── NoSeMaze_1/
│   ├── DS_info_AM1_day3to9_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
│   └── DS_info_AM1_day10to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
└── NoSeMaze_2/
    ├── DS_info_AM2_day1to7_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
    └── DS_info_AM2_day8to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat
```

The revised panel order is:

```text
S8B = z-scored David's score
S8C = linear social rank
```

Statistics:

```text
S8B: Pearson correlation
S8C: Spearman correlation
```

David's scores are z-scored separately within each NoSeMaze cohort and week before the two cohorts are pooled.

The supplied script already reproduces the reported n=24 week-to-week correlations. The repository cleanup mainly corrects the panel naming/order and output filenames so the script matches the revised caption.

Run:

```matlab
run('figures/supplement/Figure_S8/panel_B_C_week1_week2_rank_DS.m')
```

---

## Figure S8D-E — fraction of wins and graph adaptability

Behavioral inputs:

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

Graph inputs:

```text
data/processed/fMRI/Figure_4/Figure_4C_E/conditioning/
├── auc_struc_TPnoPuff11to40_45to50_p.mat
└── auc_struc_TPnoPuff81to120_45to50_p.mat
```

Panel mapping:

```text
S8D = fraction wins vs g_delta_C
S8E = fraction wins vs g_delta_L
```

The graph analysis uses the proximal CR:

```text
PRE  = TPnoPuff trials 11–40
TEST = TPnoPuff trials 81–120
density AUC = 45–50%
```

Fraction of wins is calculated within the relevant pre-scan hierarchy:

```matlab
winCounts = sum(DS_info.match_matrix,2);
fr_winner = winCounts ./ sum(winCounts);
```

For each metric, the script retains:

```text
PRE vs TEST network metric
fraction wins vs PRE
fraction wins vs TEST
fraction wins vs TEST-PRE change
```

Pearson correlation is used for the primary linear associations. A Spearman correlation for the TEST-PRE association is retained as an additional robustness statistic.

Required helpers:

```text
notBoxPlot_modified.m
permutest.m
sigstar.m
```

Run:

```matlab
run('figures/supplement/Figure_S8/panel_D_E_fr_winner_globalGA.m')
```

## Correction made

The supplied week-to-week script was labeled only as Figure S8B and plotted rank first. The revised Supplementary Figure S8 caption specifies:

```text
S8B = z-scored David's score
S8C = linear social rank
```

The corrected script is therefore named:

```text
panel_B_C_week1_week2_rank_DS.m
```

and plots David's score first and social rank second.
