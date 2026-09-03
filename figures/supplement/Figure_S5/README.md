# Supplementary Figure S5

Scripts used to reproduce Supplementary Figure S5, which presents the distal conditioned-response (`Odor`) functional-connectivity analyses.

## Panels

| Panel | Analysis | Script(s) |
|---|---|---|
| S5A | Distal-CR FC matrices in conditioning and no-puff control cohorts | `panel_A_conditioning.m`, `panel_A_control.m` |
| S5B | NBS comparison of PRE-to-TEST FC changes between cohorts | `panel_B_Odor_NBS_control_vs_conditioning.m` |
| S5C | Mean FC using positive edges only | `panel_C_meanFC_Odor.m` |

Outputs are written to:

```text
results/supplement/Figure_S5/
├── Figure_S5A/
│   ├── conditioning/
│   └── control/
├── Figure_S5B/
└── Figure_S5C/
```

## Common analysis definition

All panels use the distal CR / odor-onset beta-series connectivity estimate:

```text
Odor
```

with:

```text
PRE  = trials 11–40
TEST = trials 81–120
```

The conditioning cohort uses BASCO version `v11`; the no-puff control cohort uses `v6`.

Processed connectivity matrices are reused from:

```text
data/processed/fMRI/Figure_3/
├── conditioning/
│   ├── cormat_v11_Odor11to40.mat
│   ├── cormat_v11_Odor81to120.mat
│   └── roidata*.mat
└── control/
    ├── cormat_v6_Odor11to40.mat
    ├── cormat_v6_Odor81to120.mat
    └── roidata*.mat
```

Each cormat MAT file must contain:

```text
cormat
```

as a cell array with one ROI × ROI matrix per mouse.

## MATLAB dependencies

Repository MATLAB code is loaded recursively from:

```text
src/matlab/
```

Depending on the panel, required helpers include:

```text
lei_pairedtt.m
lei_ttest2.m
schemaball.m
acl_NBS_intercept.m
notBoxPlot_modified.m
permutation_test_paired.m
permutation_test_unpaired.m
sigstar.m
```

Optional:

```text
docDataSrc.m
```

Custom colormaps are stored under:

```text
src/matlab/helpers/colormaps/
├── myColormap_magentablue.mat
└── myColormap_darkredgreen.mat
```

NBS support files are stored under:

```text
src/matlab/helpers/NBS1.2/input_files/
├── UI.mat
└── COG.txt
```

The Statistics and Machine Learning Toolbox is required for the statistical analyses.

---

## Figure S5A — distal-CR FC matrices

Run:

```matlab
run('figures/supplement/Figure_S5/panel_A_conditioning.m')
run('figures/supplement/Figure_S5/panel_A_control.m')
```

Each script produces:

1. mean PRE connectivity matrix;
2. mean TEST connectivity matrix;
3. paired edge-wise TEST > PRE T-statistic matrix;
4. FDR-thresholded schemaball.

The paired comparison uses:

```matlab
lei_pairedtt(cormatTest,cormatPre,0.05)
```

The logical FDR mask is symmetrized before plotting and before constructing the schemaball:

```matlab
fdrDisplay = logical(fdrMatrix | fdrMatrix');
```

This avoids double weighting when the helper already returns a symmetric FDR matrix.

When multiple ROI-label files are present, the scripts preferentially select the cohort-specific BASCO version:

```text
conditioning: v11
control:      v6
```

---

## Figure S5B — NBS comparison between cohorts

Run:

```matlab
run('figures/supplement/Figure_S5/panel_B_Odor_NBS_control_vs_conditioning.m')
```

For each mouse, the script first calculates:

```text
TEST - PRE
```

and then compares these connectivity-change matrices between control and conditioning cohorts.

The original design is retained:

```text
[1 -1]   control > conditioning
[-1 1]   conditioning > control
[1 1]
```

The primary threshold is generated from:

```text
thresholdProbability = 0.975
```

using the original `acl_NBS_intercept` workflow.

The displayed NBS component preferentially uses `CON_MAT2`, corresponding to:

```text
conditioning > control
```

and falls back to `CON_MAT1` if required.

The NBS component is converted to a **logical symmetric mask**:

```matlab
NBSmat = logical((component + component') ~= 0);
```

The schemaball then uses:

```matlab
Cdata = double(NBSmat) .* T;
```

rather than re-adding the transpose. This prevents duplicated edge weights.

The Supplementary Figure S5 caption reports that no edges survived NBS correction; therefore, the script validly skips the schemaball when no NBS component is returned.

---

## Figure S5C — positive-edge mean FC

Run:

```matlab
run('figures/supplement/Figure_S5/panel_C_meanFC_Odor.m')
```

Only positive off-diagonal edges are included.

The three comparisons are:

```text
1. conditioning TEST vs PRE
2. control TEST vs PRE
3. TEST-PRE change: conditioning vs control
```

Permutation testing uses:

```text
10,000 permutations
seed = 1234
```

with:

```text
permutation_test_paired
permutation_test_unpaired
```

The figure annotations use the permutation p-values.

Parametric paired/unpaired t-tests are also exported as numerical supplementary output but are not the primary figure annotation.

## Notes

- S5 is the distal-CR counterpart of the proximal-CR connectivity analyses shown in main Figure 3.
- All paths are repository-relative.
- Helper functions may be located anywhere under `src/matlab/`.
- The custom colormaps and NBS support files are explicitly referenced from their current `helpers/` subfolders.
