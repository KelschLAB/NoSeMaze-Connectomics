# Figure 4

Scripts used to reproduce the graph-theoretical analyses shown in Figure 4.

Unless otherwise indicated, the analyses use the `TPnoPuff` period corresponding to the proximal conditioned-response time point:

- **PRE:** trials 11–40
- **TEST:** trials 81–120

Graph measures are evaluated over the predefined **45–50% graph-threshold range**.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| 4A | Distributions of local node strength and clustering coefficient in conditioning and control cohorts | `panel_A_localGA_histograms.m` |
| 4B | Regional pre-to-test changes in node strength and clustering coefficient: conditioning vs control | `panel_B_localGA_task_vs_control.m` |
| 4C | Global network segregation metric ΔC | `panel_C_E_global_graph_metrics.m` |
| 4D | Global network integration metric ΔL | `panel_C_E_global_graph_metrics.m` |
| 4E | Small-world propensity (SWP) | `panel_C_E_global_graph_metrics.m` |

Generated outputs are written to:

```text
results/main/Figure_4/
├── Figure_4A/
├── Figure_4B/
├── Figure_4C/
├── Figure_4D/
└── Figure_4E/
```

## Required software

### MATLAB

All Figure 4 analyses require MATLAB.

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

This includes helper functions stored under `src/matlab/helpers/` and its subfolders.

The Statistics and Machine Learning Toolbox is required for Figures 4B–E because these scripts use functions including `ttest`, `ttest2`, and `tinv`.

## Required data

### Figure 4A

Graph-analysis structures:

```text
data/processed/fMRI/Figure_4/
├── conditioning/
│   ├── gstruc_TPnoPuff11to40_p.mat
│   └── gstruc_TPnoPuff81to120_p.mat
└── control/
    ├── gstruc_TPnoPuff11to40_p.mat
    └── gstruc_TPnoPuff81to120_p.mat
```

Each file must contain the variable:

```text
gstruc
```

Figure 4A analyzes the local metrics:

```text
l_strength
l_cc
```

using threshold indices `36:41`, corresponding to the displayed graph-threshold range **45–50%**.

### Figure 4B

Precomputed regional AUC structures:

```text
data/processed/fMRI/Figure_4/Figure_4B/
├── conditioning/
│   └── res_auc_struc_local.mat
└── control/
    └── res_auc_struc_local.mat
```

Each file must contain:

```text
res_auc_struc
```

Only the following regional metrics are analyzed:

```text
l_strength
l_cc
```

For each ROI:

```text
conditioning Δ = TEST - PRE
control Δ      = TEST - PRE
```

The two change scores are compared between cohorts using an independent-samples t-test.

FDR correction is applied across ROIs separately for each local metric.

### Figures 4C–E

Subject-level global AUC structures:

```text
data/processed/fMRI/Figure_4/Figure_4C_E/
├── conditioning/
│   ├── auc_struc_TPnoPuff11to40_45to50_p.mat
│   └── auc_struc_TPnoPuff81to120_45to50_p.mat
└── control/
    ├── auc_struc_TPnoPuff11to40_45to50_p.mat
    └── auc_struc_TPnoPuff81to120_45to50_p.mat
```

Each file must contain:

```text
auc_struc
```

The three predefined global metrics are:

```text
Figure 4C: g_delta_C
Figure 4D: g_delta_L
Figure 4E: g_swp
```

For each metric, two inferential comparisons are performed:

1. conditioning cohort: PRE vs TEST;
2. TEST-minus-PRE change: conditioning vs control.

The control PRE and TEST values are used to calculate the control change score but are not tested as a separate within-control comparison in this script.

## MATLAB dependencies

The scripts load repository helpers recursively from:

```text
src/matlab/
```

### Figure 4A

Required helper:

```text
permutationTest.m
```

Optional:

```text
docDataSrc.m
```

The permutation tests use:

```text
10,000 permutations
random seed = 1234
```

### Figure 4B

Required helpers:

```text
FDR.m
vals2colormap_jr.m
```

Optional:

```text
docDataSrc.m
```

The script also requires the Statistics and Machine Learning Toolbox.

### Figures 4C–E

Required helpers:

```text
notBoxPlot_modified.m
permutation_test_paired.m
permutation_test_unpaired.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

The scripts also require the Statistics and Machine Learning Toolbox.

Permutation inference uses:

```text
10,000 permutations
random seed = 1234
```

Benjamini–Hochberg FDR correction is performed across ΔC, ΔL, and SWP separately for two inferential families:

1. conditioning PRE vs TEST;
2. conditioning-vs-control TEST-minus-PRE change.

Raw permutation p-values are displayed in the figure. A dagger indicates that the corresponding permutation result survives FDR correction across the three global metrics.

## Running

The scripts determine the repository root from their own location and can therefore be run without changing the MATLAB working directory.

### Figure 4A

```matlab
run('figures/main/Figure_4/panel_A_localGA_histograms.m')
```

For each local metric, the script:

- extracts values across graph thresholds 45–50%;
- plots conditioning PRE vs TEST;
- plots control PRE vs TEST;
- plots TEST-minus-PRE changes for conditioning vs control;
- runs the original permutation analysis on the flattened metric distributions;
- exports source data, statistics, metadata, and figure files.

Outputs are written under:

```text
results/main/Figure_4/Figure_4A/thresholds_45to50/
```

### Figure 4B

```matlab
run('figures/main/Figure_4/panel_B_localGA_task_vs_control.m')
```

For each ROI and each local metric, the script:

- calculates TEST-minus-PRE change separately for conditioning and control animals;
- compares the two cohorts using `ttest2`;
- applies FDR correction across ROIs;
- retains the original plotting convention in which the displayed t statistic is the negative of the raw conditioning-vs-control t statistic;
- exports raw and displayed t statistics, p-values, FDR results, sample sizes, mean change scores, metadata, and figure files.

Outputs are written to:

```text
results/main/Figure_4/Figure_4B/
```

### Figures 4C–E

```matlab
run('figures/main/Figure_4/panel_C_E_global_graph_metrics.m')
```

The script analyzes all three global metrics in one run.

For each metric it:

- performs a paired conditioning PRE-vs-TEST comparison;
- calculates TEST-minus-PRE change for both cohorts;
- compares these change scores between conditioning and control animals;
- retains the corresponding parametric t-tests;
- performs permutation inference;
- applies FDR correction across ΔC, ΔL, and SWP;
- exports panel-specific source data, statistics, metadata, complete MATLAB results, and figures.

Outputs are written to:

```text
results/main/Figure_4/Figure_4C/
results/main/Figure_4/Figure_4D/
results/main/Figure_4/Figure_4E/
```

A combined FDR summary is additionally written to:

```text
results/main/Figure_4/Figure_4C_E_GlobalMetrics_FDR_Summary.csv
```
