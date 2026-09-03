# Supplementary Figure S19

Script used to reproduce Supplementary Figure S19, which shows threshold-dependent whole-brain functional-connectivity differences.

The revised caption defines three rows at five network densities:

```text
row 1   conditioning TEST vs PRE
row 2   control TEST vs PRE
row 3   conditioning TEST-PRE change vs control TEST-PRE change
```

at:

```text
10%, 20%, 30%, 40%, 50% network sparsity
```

Only edge-wise t-values significant at uncorrected `p < 0.05` are displayed.

## Script

```text
figure_S19_threshold_matrix_comparison.m
```

Outputs:

```text
results/supplement/Figure_S19/
```

## Inputs

Graph structures are reused from Figure 4:

```text
data/processed/fMRI/Figure_4/
├── conditioning/
│   ├── gstruc_TPnoPuff11to40_p.mat
│   └── gstruc_TPnoPuff81to120_p.mat
└── control/
    ├── gstruc_TPnoPuff11to40_p.mat
    └── gstruc_TPnoPuff81to120_p.mat
```

Each file must contain:

```text
gstruc
```

with thresholded positive-edge connectivity matrices in:

```text
gstruc(thresholdIndex,animal).o_CIJ_thresh
```

No raw BASCO `cormat` files are required.

## Block definition

```text
PRE  = TPnoPuff trials 11–40
TEST = TPnoPuff trials 81–120
```

These are the proximal-CR graph-analysis blocks.

## Density thresholds

Historical threshold indices:

```matlab
thresholdIndices = 1:10:41;
```

map to:

```text
10, 20, 30, 40, 50%
```

via:

```matlab
thresholdLabels = thresholdIndices + 9;
```

## ROI ordering

ROI labels are reused from the Figure 3 conditioning data:

```text
data/processed/fMRI/Figure_3/conditioning/
└── roidata*.mat
```

The script preferentially selects a `v11` Lavender ROI file and applies the repository's canonical 52-region ordering.

## Colormaps

Required resources:

```text
src/matlab/helpers/colormaps/
├── myColormapICON.mat
└── myColormap_graygreen.mat
```

Rows 1-2 use the ICON colormap; row 3 uses the gray-green colormap.

## Statistical comparisons

### Rows 1 and 2: within-cohort TEST versus PRE

These are repeated measurements from the same animals, so the script retains:

```matlab
lei_pairedtt(TEST, PRE, 0.05)
```

for:

```text
conditioning TEST vs PRE
control TEST vs PRE
```

Only:

```matlab
T .* (p < 0.05)
```

is displayed.

### Row 3: conditioning change versus control change

For each animal:

```text
change = TEST - PRE
```

is first calculated within cohort.

Conditioning and control are **independent cohorts**. The corrected script therefore uses the repository's existing unpaired matrix helper:

```matlab
lei_ttest2(conditioning_change, control_change, 0.05)
```

rather than `lei_pairedtt`.

This is preferable to a hand-written `ttest2` loop because the historical NoSeMaze matrix-analysis code explicitly distinguishes `lei_ttest2` as the **unpaired** branch and `lei_pairedtt` as the **paired** branch. It therefore preserves the established matrix-analysis implementation while correcting the cohort design.

The revised caption describes the bottom row as a comparison *between conditioning and control cohorts* and specifies only that uncorrected `p < 0.05` t-values are displayed; it does not imply paired cohorts.

## Multiple-comparison handling

Figure S19 is descriptive/sensitivity analysis. In accordance with the revised caption, edge-wise values are thresholded at:

```text
p < 0.05 uncorrected
```

No NBS or FDR correction is applied in this figure.

## Source-data exports

For every threshold and row, the displayed thresholded t-matrix is exported as CSV with ROI names as both row and column labels.

Examples:

```text
SourceData_conditioning_thresh10_*.csv
SourceData_control_thresh10_*.csv
SourceData_conditioningVScontrol_thresh10_*.csv
```

The corrected script additionally writes:

```text
AnalysisMetadata_Figure_S19.csv
Results_Figure_S19.mat
```

## MATLAB dependencies

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

Required:

```text
lei_pairedtt.m
lei_ttest2.m
```

Optional:

```text
docDataSrc.m
```


## Running

```matlab
run('figures/supplement/Figure_S19/figure_S19_threshold_matrix_comparison.m')
```

## Repository check

Most of the supplied S19 script was already consistent with the revised caption:

- correct PRE/TEST blocks;
- correct 10/20/30/40/50% thresholds;
- correct reuse of Figure 4 graph structures;
- correct 52-ROI ordering;
- correct uncorrected `p < 0.05` display threshold.

The substantive correction is the **bottom-row between-cohort inference**: conditioning and control are independent groups, so their TEST-PRE changes are now compared with `lei_ttest2` (the historical unpaired matrix helper) instead of `lei_pairedtt`.

The cleanup also adds:

1. explicit `src/matlab/` validation;
2. strict PRE/TEST animal-count checks within each cohort;
3. analysis metadata;
4. a compact MATLAB result file.
