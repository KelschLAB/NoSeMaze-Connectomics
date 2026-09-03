# Reproducibility status: reappraisal BASCO FC

## Confirmed primary specification

The historical BASCO configuration has now been recovered sufficiently to
fix the primary subject-level FC analysis:

```text
BASCO version       v11
EPI                 wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_
EPI suffix          _c1_c2t_wds
smoothing           none
trial model         v19
HRF                 HRFlongTC_withoutOnset_from2sHRF-GLM
nuisance file       rp_regressors_despiked_motcsf_der_v11.txt
nuisance content    identical to voxelwise-GLM v1 (14 columns)
atlas labels        AllenBrain_2021_v2_inPax_merged_jr.txt
atlas NIfTI         AllenBrain_2021_v2_inPax_merged.nii
ROI count           52
L/R handling        homologous labels combined into one anatomical ROI
BASCO mode          voxel analysis
BASCO ROI analysis  false
TR                  1.2 s
fmri_t              22
fmri_t0             1
HRF derivatives     [0 0]
global mean reg     false
```

## v19 trial-wise model

```text
Lavender
    120 odor onsets

TP Puff
    28 actual puff time points

TP NoPuff
    92 puff-like no-puff time points
    = 40 pre + 12 pairing-no-puff + 40 post
```

All events have duration 0. Odor onsets are shifted by 0.7 s.

## Analysis chain

```text
processed event timing
        ↓
v19 trial-wise regressor generation
        +
unsmoothed normalized/wavelet-despiked EPI
        +
14-column motion/CSF nuisance model
        +
study-specific mouse HRF
        ↓
BASCO voxelwise trial-wise GLM
        ↓
trial beta images
        ↓
10 manuscript beta-series sets
        ↓
52 merged anatomical ROI beta series
        ↓
10 Pearson FC matrices per animal
```

## What is now code-complete

The repository contains:

```text
v19 regressor generation
portable subject manifest
BASCO input preparation
path-independent anadef_reappraisal.m
beta-series subset construction
merged-ROI extraction
Pearson correlation-matrix creation
output validation
```

## Remaining runtime/data requirements

To execute the pipeline on another machine, the following data/dependencies
must physically exist:

```text
processed event-timing files
unsmoothed processed EPI files
regressors_despiked_motcsf_der.txt per subject
mask_template_6_polished.nii
AllenBrain_2021_v2_inPax_merged_jr.txt
AllenBrain_2021_v2_inPax_merged.nii
SPM12
BASCO
MarsBaR if required by the installed BASCO version
selected spm12_animal HRF directory
```

The BASCO toolbox stage itself may still involve its standard model-
estimation GUI depending on the installed BASCO version. All analysis inputs
and `AnaDef` parameters are now defined by repository code.

NBS and graph-theoretical inference remain separate downstream modules.
