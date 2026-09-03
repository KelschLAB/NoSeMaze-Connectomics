# Supplementary Figure S7

Scripts used to reproduce Supplementary Figure S7, which presents graph-analysis results at the distal conditioned response (odor onset).

## Panels

| Panel | Analysis | Script |
|---|---|---|
| S7A | Regional TEST–PRE changes in strength and local clustering: conditioning vs control | `panel_A_localGA_odor_task_vs_control.m` |
| S7B | Global ΔC: conditioning PRE vs TEST and TEST–PRE change vs control | `panel_B_C_global_graph_metrics_odor.m` |
| S7C | Global ΔL: conditioning PRE vs TEST and TEST–PRE change vs control | `panel_B_C_global_graph_metrics_odor.m` |

Outputs:

```text
results/supplement/Figure_S7/
├── Figure_S7A/
├── Figure_S7B/
└── Figure_S7C/
```

## Common definition

```text
PRE  = Odor trials 11–40
TEST = Odor trials 81–120
```

These are the distal-CR / odor-onset graph analyses.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

Required helpers:

```text
FDR.m
vals2colormap_jr.m
notBoxPlot_modified.m
permutation_test_paired.m
permutation_test_unpaired.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

The Statistics and Machine Learning Toolbox is required.

---

## Figure S7A — regional graph metrics

Input:

```text
data/processed/fMRI/Figure_S7/Figure_S7A/
├── conditioning/
│   └── res_auc_struc_local.mat
└── control/
    └── res_auc_struc_local.mat
```

Metrics:

```text
l_strength
l_cc
```

For each ROI:

```text
conditioning change = TEST - PRE
control change      = TEST - PRE
```

followed by an unpaired `ttest2`.

FDR correction is applied across ROIs separately for each local metric.

The historical plotting convention is retained:

```text
plotted T = -raw T
```

Both raw and plotted values are exported.

Run:

```matlab
run('figures/supplement/Figure_S7/panel_A_localGA_odor_task_vs_control.m')
```

---

## Figure S7B-C — global graph metrics

Input:

```text
data/processed/fMRI/Figure_S7/Figure_S7B_C/
├── conditioning/
│   ├── auc_struc_Odor11to40_45to50_p.mat
│   └── auc_struc_Odor81to120_45to50_p.mat
└── control/
    ├── auc_struc_Odor11to40_45to50_p.mat
    └── auc_struc_Odor81to120_45to50_p.mat
```

Required global fields:

```text
g_delta_C
g_delta_L
g_swp
```

Displayed panels:

```text
S7B = g_delta_C
S7C = g_delta_L
```

`g_swp` is calculated only for multiple-testing correction and is not plotted.

### Statistics

For each predefined global metric:

```text
1. conditioning PRE vs TEST:
   paired permutation test

2. TEST-PRE change, conditioning vs control:
   unpaired permutation test
```

with:

```text
10,000 permutations
seed = 1234
```

Benjamini-Hochberg FDR is applied separately to the two inferential families across:

```text
ΔC
ΔL
SWP
```

This is important: the corrected script explicitly includes `g_swp` as the third `metricInfo` entry with:

```matlab
metricInfo(3).plotPanel = false;
```

so SWP contributes to FDR without creating an additional panel.

Raw permutation p-values are displayed; a dagger marks results surviving the three-metric FDR correction.

Run:

```matlab
run('figures/supplement/Figure_S7/panel_B_C_global_graph_metrics_odor.m')
```

## Notes

- S7A showed only limited regional distal-CR changes, with none surviving FDR correction.
- S7B/C showed no significant distal-CR ΔC or ΔL effects in the conditioning cohort and no significant differences from control.
- All paths are repository-relative.
