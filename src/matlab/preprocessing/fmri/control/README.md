# Reappraisal-control fMRI preprocessing

This module documents preprocessing of the separate no-puff control cohort.

## Workflow

```text
private Bruker/ParaVision MRI
        ↓
conversion + reorientation
        ↓
remove first 5 volumes
        ↓
AFNI 3dDespike
        ↓
field-map preparation
        ↓
realignment / unwarping
        ↓
slice-time correction
        ↓
EPI → anatomical coregistration where required
        ↓
anatomical brain extraction
        ↓
template alignment
        ↓
bias correction + segmentation
        ↓
DARTEL normalization
        ↓
resliced normalized EPI
        ↓
masking / intensity normalization
        ↓
wavelet despiking
```

## Entry point

```text
main_preprocessing_fmri_control.m
```

The public file is a workflow/provenance master: it documents the exact
processing order and checks dependencies, while raw-data stage execution is
disabled because the original acquisitions and complete historical execution
environment are not distributed.

Raw MRI can be supplied through:

```text
NOSEMAZE_CONTROL_FMRI_RAW_ROOT
```

Control-specific historical exceptions (e.g. selective coregistration and
field-map handling) are documented in the master and `DEPENDENCIES.md` rather
than generalized silently.

Shared preprocessing functions currently live under the reappraisal
`functions/` tree; control-specific wrappers live in this module's
`functions/` folder.
