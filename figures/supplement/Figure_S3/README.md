# Supplementary Figure S3

Scripts used to reproduce Supplementary Figure S3.

Supplementary Figure S3 documents the study-specific hemodynamic response function (HRF) used for the mouse fMRI analyses. The HRF was estimated in a separate cohort of 11 male mice using ultrafast fMRI (TR = 265 ms) during an odor-only task. The resulting mouse-specific HRF peaked at approximately 2 s after odor onset and was used to convolve task regressors in the main analyses.

## Panels

| Panel | Analysis | Script |
|---|---|---|
| S3A | Odor-evoked activation map from the HRF-estimation cohort | `panel_A_mricrogl.py` |
| S3B | Comparison of the final study-specific mouse HRF with the canonical human SPM HRF | `panel_B_HRF_comparison.m` |

Generated outputs are written under:

```text
results/supplement/Figure_S3/
├── Figure_S3A/
└── Figure_S3B/
```

## Required software

### MRIcroGL

Figure S3A requires MRIcroGL.

The rendering script uses:

```text
color map: 8redyell
shader:    MatcapMix_JR
```

Because MRIcroGL's embedded Python environment does not reliably expose the script location, edit the `repo_root` line near the beginning of `panel_A_mricrogl.py` before running it.

### MATLAB

Figure S3B requires MATLAB.

The HRF implementations are stored separately to avoid function-name conflicts:

```text
src/matlab/helpers/hrf/
├── mouse/
│   └── spm_hrf.m
├── human/
│   └── spm_hrf.m
└── common/
    └── spm_Gpdf.m
```

General repository helpers may be stored under:

```text
src/matlab/helpers/
```

Optional:

```text
docDataSrc.m
```

The Figure S3B script intentionally does **not** recursively add all of `src/matlab/`, because doing so would place both mouse and human `spm_hrf.m` implementations on the MATLAB path simultaneously.

---

## Figure S3A — odor-evoked activation map

### Anatomical template

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii.gz
```

### Statistical-map input

```text
data/processed/fMRI/Figure_S3/Figure_S3A/
└── activation_OdorCombined_T001.nii
```

The `T001` suffix is retained from the original statistical-map naming convention.

### Rendering

The script:

- loads the high-resolution Paxinos-space anatomical template;
- retains the historical extraction and intensity settings;
- reproduces the original S3A mosaic;
- displays the odor-combined activation map with a statistical display range of `3–12`;
- uses the standard MRIcroGL `8redyell` color map;
- uses the custom `MatcapMix_JR` shader.

### Running

Open `panel_A_mricrogl.py` in MRIcroGL, edit `repo_root`, and run the script.

Outputs are written to:

```text
results/supplement/Figure_S3/Figure_S3A/
```

---

## Figure S3B — mouse versus human HRF

Figure S3B compares:

```text
mouse HRF:
    final study-specific HRF implementation used for the mouse task analyses

human HRF:
    canonical SPM12 HRF
```

Both are evaluated with:

```text
sampling interval dt = 0.1 s
computed interval     = 0–32 s
displayed interval    = 0–15 s
```

### Required files

```text
src/matlab/hrf/
├── mouse/
│   └── spm_hrf.m
├── human/
│   └── spm_hrf.m
└── common/
    └── spm_Gpdf.m
```

Each `spm_hrf.m` is evaluated separately with the shared `spm_Gpdf.m` temporarily placed at the front of the MATLAB path. The original MATLAB path is restored immediately after each evaluation.

This prevents the mouse and human implementations from shadowing one another.

### Running

```matlab
run('figures/supplement/Figure_S3/panel_B_HRF_comparison.m')
```

The script exports:

- the mouse and human HRF curves;
- peak time and peak value for each HRF;
- analysis metadata;
- complete MATLAB results;
- PDF, PNG, and MATLAB figure files.

Outputs are written to:

```text
results/supplement/Figure_S3/Figure_S3B/
```

## Scope of the reproduction scripts

The scripts in this folder reproduce the **displayed Supplementary Figure S3 panels**.

The upstream study-specific HRF estimation itself was performed in the separate n=11 ultrafast-fMRI cohort by fitting mean olfactory-region BOLD time courses with SPM HRFs using parameter sweeps and `fminsearch` optimization. That fitting pipeline is not rerun by `panel_B_HRF_comparison.m`; instead, the script evaluates and displays the final custom mouse `spm_hrf.m` implementation resulting from that analysis alongside the canonical human SPM HRF.

If the full HRF-estimation pipeline is included in the repository, it should therefore live under `src/matlab/` as preprocessing/analysis machinery rather than inside this figure folder.

