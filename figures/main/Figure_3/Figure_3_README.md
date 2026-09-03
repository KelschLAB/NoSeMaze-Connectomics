# Figure 3

Scripts used to reproduce the functional-connectivity analyses shown in Figure 3.

The main Figure 3 analyses focus on functional connectivity at the **proximal conditioned-response time point** (`TPnoPuff`), comparing the pre block (trials 11–40) with the test block (trials 81–120). Corresponding odor-onset analyses are provided separately with the supplementary figures.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| 3A | Mean functional-connectivity matrices for pre and test, and paired test-vs-pre edge-wise comparisons, shown separately for conditioning and control cohorts | `panel_A_conditioning.m`, `panel_A_control.m` |
| 3B | Network-based statistic (NBS) comparing pre-to-test connectivity changes between conditioning and control cohorts | `panel_B_control_vs_conditioning.m` |
| 3C | Mean functional connectivity using positive edges only, including pre-vs-test and between-cohort change-score comparisons | `panel_C_meanFC.m` |

Generated outputs are written to:

```text
results/main/Figure_3/
├── Figure_3A/
│   ├── conditioning/
│   └── control/
├── Figure_3B/
└── Figure_3C/
```

## Required software

### MATLAB

All Figure 3 panels require MATLAB.

Repository MATLAB helpers are loaded recursively from:

```text
src/matlab/
```

The Statistics and Machine Learning Toolbox is required for the statistical functions used in the Figure 3 analyses.

## Required data

Processed BASCO correlation matrices are expected under:

```text
data/processed/fMRI/Figure_3/
├── conditioning/
│   ├── cormat_v11_TPnoPuff11to40.mat
│   ├── cormat_v11_TPnoPuff81to120.mat
│   └── roidata*.mat
└── control/
    ├── cormat_v6_TPnoPuff11to40.mat
    ├── cormat_v6_TPnoPuff81to120.mat
    └── roidata*.mat
```

Each `cormat` file must contain the variable:

```text
cormat
```

as a cell array of subject-level square correlation matrices.

The `roidata*.mat` files provide the anatomical ROI labels used for matrix and schemaball visualization.

## MATLAB dependencies

### Panel 3A

Required repository helpers:

```text
src/matlab/
├── lei_pairedtt.m
├── schemaball.m
└── colormaps/
    └── myColormap_magentablue.mat
```

### Panel 3B

Required repository helpers and NBS support files:

```text
src/matlab/
├── acl_NBS_intercept.m
├── lei_ttest2.m
├── schemaball.m
├── colormaps/
│   └── myColormap_darkredgreen.mat
└── NBS1.2/
    └── input_files/
        ├── UI.mat
        └── COG.txt
```

`UI.mat` contains the NBS configuration used by the analysis.

### Panel 3C

Required repository helpers:

```text
src/matlab/
├── notBoxPlot_modified.m
├── permutation_test_paired.m
├── permutation_test_unpaired.m
└── sigstar.m
```

## Running

The scripts determine the repository root from their own location and can therefore be run without changing the MATLAB working directory.

### Panel 3A — conditioning cohort

```matlab
run('figures/main/Figure_3/panel_A_conditioning.m')
```

### Panel 3A — control cohort

```matlab
run('figures/main/Figure_3/panel_A_control.m')
```

For each cohort, the scripts:

- load the `TPnoPuff` correlation matrices for pre (trials 11–40) and test (trials 81–120);
- reorder the 52 ROIs using the manuscript ordering;
- calculate and export the mean pre and test connectivity matrices;
- perform paired edge-wise test-vs-pre comparisons using `lei_pairedtt`;
- apply an FDR threshold of 0.05;
- export the T-statistic, p-value, FDR, and source-data matrices;
- generate an FDR-thresholded schemaball.

### Panel 3B — NBS comparison between cohorts

```matlab
run('figures/main/Figure_3/panel_B_control_vs_conditioning.m')
```

The script:

- calculates a test-minus-pre connectivity-change matrix for each animal;
- combines the conditioning and control cohorts into the NBS input matrix;
- creates the two-group GLM design matrix;
- calculates the primary t and F thresholds;
- runs the original NBS procedure using `acl_NBS_intercept`;
- preferentially displays the `[-1 1]` contrast (conditioning > control) when a significant component is returned;
- exports the NBS mask, edge-wise statistics, design matrix, source data, and schemaball.

### Panel 3C — mean functional connectivity

```matlab
run('figures/main/Figure_3/panel_C_meanFC.m')
```

The main analysis includes **positive edges only**, matching the manuscript figure.

Three comparisons are performed:

1. conditioning cohort: test vs pre — paired;
2. control cohort: test vs pre — paired;
3. test-minus-pre change: conditioning vs control — unpaired.

Permutation inference uses:

```text
10,000 permutations
random seed = 1234
```

The corresponding parametric t-tests are also retained and exported for reference.

## Supplementary odor-onset analyses

The main Figure 3 scripts use `TPnoPuff`, corresponding to the proximal conditioned-response time point.

The analogous odor-onset analyses are reproduced separately with the supplementary figure scripts rather than as part of the main Figure 3 reproduction workflow.
