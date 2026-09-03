# Supplementary Figure S4

Scripts used to reproduce the detailed functional-connectivity and local graph-metric analyses shown in Supplementary Figure S4.

Supplementary Figure S4 expands the proximal conditioned-response (`TPnoPuff`) network analyses shown in the main Figures 3 and 4. Functional connectivity was estimated with BASCO using 52 bilateral ROIs, and regional graph analyses were performed on positive weighted networks evaluated over the 45–50% density range. The manuscript specifies FDR correction for regional node-level local graph analyses.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| S4A | Conditioning cohort: paired FC matrix, TEST vs PRE | `panel_A_conditioning_TMatrix.m` |
| S4B | No-puff control cohort: paired FC matrix, TEST vs PRE | `panel_B_control_TMatrix.m` |
| S4C | Conditioning cohort: regional strength and local clustering changes | `panel_C_local_graph_metrics_conditioning.m` |
| S4D | No-puff control cohort: regional strength and local clustering changes | `panel_D_local_graph_metrics_control.m` |

Generated outputs are written under:

```text
results/supplement/Figure_S4/
├── Figure_S4A/
├── Figure_S4B/
├── Figure_S4C/
└── Figure_S4D/
```

## Common analysis definition

All four panels use the proximal conditioned-response time point:

```text
TPnoPuff
```

with:

```text
PRE  = trials 11–40
TEST = trials 81–120
```

The canonical anatomical ROI ordering is kept identical across panels.

## MATLAB dependencies

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

Required helper functions:

```text
lei_pairedtt.m          # S4A/S4B
FDR.m                   # S4C/S4D
vals2colormap_jr.m      # S4C/S4D
```

Optional:

```text
docDataSrc.m
```

The custom MATLAB colormap is stored under:

```text
src/matlab/helpers/colormaps/
└── myColormap_magentablue.mat
```

The Statistics and Machine Learning Toolbox is required for S4C/S4D (`ttest`, `tinv`).

---

## Figure S4A — conditioning FC TEST vs PRE

### Input

```text
data/processed/fMRI/Figure_3/conditioning/
├── cormat_v11_TPnoPuff11to40.mat
├── cormat_v11_TPnoPuff81to120.mat
└── roidata*.mat
```

Each correlation-matrix MAT file must contain:

```text
cormat
```

as a cell array with one ROI × ROI matrix per mouse.

### Statistics

The script calls:

```matlab
lei_pairedtt(cormatTest, cormatPre, 0.05)
```

to perform the paired edge-wise TEST-vs-PRE comparison and FDR correction.

The displayed matrix is the lower triangle of the T-statistic matrix. The logical FDR mask is symmetrized before display, so significant edges are marked correctly regardless of which triangle the helper populates.

### Running

```matlab
run('figures/supplement/Figure_S4/panel_A_conditioning_TMatrix.m')
```

---

## Figure S4B — control FC TEST vs PRE

### Input

```text
data/processed/fMRI/Figure_3/control/
├── cormat_v6_TPnoPuff11to40.mat
├── cormat_v6_TPnoPuff81to120.mat
└── roidata*.mat
```

The analysis and display logic are identical to S4A, but use the no-puff control cohort and BASCO version `v6`.

### Running

```matlab
run('figures/supplement/Figure_S4/panel_B_control_TMatrix.m')
```

---

## Figure S4C — conditioning regional graph metrics

### Input

```text
data/processed/fMRI/Figure_4/Figure_4B/conditioning/
└── res_auc_struc_local.mat
```

ROI labels are loaded from:

```text
data/processed/fMRI/Figure_3/conditioning/
└── roidata*.mat
```

The script preferentially selects a `v11` ROI-label file when multiple files are present.

The input MAT file must contain:

```text
res_auc_struc
```

with:

```text
l_strength.TPnoPuff11to40
l_strength.TPnoPuff81to120

l_cc.TPnoPuff11to40
l_cc.TPnoPuff81to120
```

for all ROIs.

### Statistics

For each metric and ROI:

```matlab
ttest(TEST, PRE)
```

is performed across mice.

Thus:

```text
positive T = TEST > PRE
negative T = PRE > TEST
```

FDR correction is then applied **across ROIs separately for `l_strength` and `l_cc`**.

The figure preserves the historical reversed x-axis orientation. Asterisks mark nominal `p < .05`; the section sign marks ROIs surviving FDR correction.

### Running

```matlab
run('figures/supplement/Figure_S4/panel_C_local_graph_metrics_conditioning.m')
```

---

## Figure S4D — control regional graph metrics

### Input

```text
data/processed/fMRI/Figure_4/Figure_4B/control/
└── res_auc_struc_local.mat
```

ROI labels are loaded from:

```text
data/processed/fMRI/Figure_3/control/
└── roidata*.mat
```

The control script preferentially selects a **`v6`** ROI-label file when multiple files are present.

This is intentionally different from S4C, which uses `v11` for the conditioning cohort.

### Statistics

The analysis is otherwise identical to S4C:

```text
paired TEST vs PRE t-test for every ROI
FDR across ROIs separately for strength and clustering coefficient
```

### Running

```matlab
run('figures/supplement/Figure_S4/panel_D_local_graph_metrics_control.m')
```

## Notes

- S4A/B reuse the processed BASCO correlation matrices from the Figure 3 workflow.
- S4C/D reuse the processed local graph-metric AUC structures from the Figure 4 workflow.
- The manuscript describes BASCO FC over 52 bilateral ROIs and specifies FDR correction for regional node-level local graph analyses.
- All paths are repository-relative.
- Helpers may be reorganized within `src/matlab/`; recursive path loading keeps the scripts independent of their exact helper subfolder.
