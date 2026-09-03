# Supplementary Figure S13

Scripts used to reproduce Supplementary Figure S13.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| S13A | Whole-brain map showing the vHC cluster associated with ΔC adaptation | `panel_A_mricrogl_S13A.py` |
| S13B | ΔC adaptation versus BOLD extracted from that vHC cluster | `panel_B_deltaC_BOLD.m` |

Outputs are written under:

```text
results/supplement/Figure_S13/
├── Figure_S13A/
└── Figure_S13B/
```

---

## Figure S13A — MRIcroGL rendering

Input:

```text
data/processed/fMRI/Figure_S13/Figure_S13A/
└── vHC*corrdeltaC.nii
```

Anatomical template:

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii
```

Custom MRIcroGL resources:

```text
color map = 1BrownJR
shader    = MatcapMix_JR
```

Rendering settings:

```text
template range = 0–1,200,000
overlay range  = 2–5
opacity        = 100%
mosaic         = C -31 S X R 0; A -35
```

The repository root remains a manually editable line because MRIcroGL's embedded Python environment does not reliably expose the script location:

```python
repo_root = r'...\NoSeMaze-Connectomics'
```

The corrected script clears any existing overlay before loading each map:

```python
gl.overlaycloseall()
gl.overlayload(overlay_file)
```

This prevents accumulation when multiple matching overlays are present.

Run from MRIcroGL:

```python
exec(open(r'figures\supplement\Figure_S13\panel_A_mricrogl_S13A.py').read())
```

---

## Figure S13B — ΔC adaptation versus vHC BOLD

Graph inputs are reused from the main graph-analysis workflow:

```text
data/processed/fMRI/Figure_4/Figure_4C_E/conditioning/
├── auc_struc_TPnoPuff11to40_45to50_p.mat
└── auc_struc_TPnoPuff81to120_45to50_p.mat
```

The predictor is:

```text
ΔC adaptation = g_delta_C(TEST) - g_delta_C(PRE)
```

The vHC BOLD extraction input is:

```text
data/processed/fMRI/Figure_S13/Figure_S13B/
└── mask_vHC_T01_corrdeltaC.mat
```

Expected structure:

```text
res.mean_betaNeg   -> PRE
res.mean_betaPos   -> TEST
```

The script defines:

```text
BOLD change = TEST - PRE
```

and verifies that graph and BOLD vectors have matching sample sizes.

### Statistics

The figure retains:

```text
1. PRE versus TEST BOLD
2. ΔC adaptation versus PRE and TEST BOLD
3. ΔC adaptation versus TEST-PRE BOLD change
```

Correlations:

```text
Pearson
Spearman
```

PRE-versus-TEST inference:

```text
paired t-test
paired permutation test
```

with:

```text
10,000 permutations
seed = 1234
```

The displayed PRE-versus-TEST annotation uses the permutation p-value.

Run:

```matlab
run('figures/supplement/Figure_S13/panel_B_deltaC_BOLD.m')
```

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

## Repository check

The supplied S13 analysis was already internally consistent:

- S13A searches for the expected `vHC*corrdeltaC.nii` map;
- S13B reuses the 45–50% proximal-CR graph AUC files;
- the S13B predictor is explicitly `g_delta_C(TEST) - g_delta_C(PRE)`;
- BOLD extraction follows the same `mean_betaNeg = PRE`, `mean_betaPos = TEST` convention used elsewhere in the repository.

No statistical analysis was changed. The only code-level cleanup is the MRIcroGL overlay reset in S13A and an explicit `src/matlab/` existence check in S13B.
