# HRF-cohort fMRI preprocessing

Primary entry point:

```text
main_preprocessing_fmri_hrf.m
```

## Processing sequence

```text
ParaVision conversion
        ↓
file-list construction
        ↓
field-map position correction
        ↓
remove 25 initial volumes
        ↓
field-map scaling / preparation
        ↓
voxel-displacement-map creation
        ↓
realignment + unwarping
        ↓
slice-time correction
        ↓
anatomical bias correction / brain extraction
        ↓
template alignment + segmentation
        ↓
DARTEL
        ↓
reslicing
        ↓
0.5 mm FWHM smoothing (s5)
        ↓
masking
        ↓
msk_s5_rwrst_a1_u_del25_*_c2t.nii
```

## Acquisition settings

```text
TR          0.265 s
TE          0.018 s
slices      6
volumes     8200
dummies     25
voxel size  0.25 × 0.25 × 0.60 mm
```

The original MRI acquisitions are private. The module therefore requires
access to the external acquisition tree as configured in
`hrf_preprocessing_config.m`.

Shared fMRI preprocessing helpers are reused from the reappraisal module;
HRF-specific field-map and slice-timing helpers are stored locally.

The common `do_smooth_lw` helper generates the historical `s5_` prefix from
the 0.5-mm kernel rather than assuming the reappraisal `s6_` branch.
