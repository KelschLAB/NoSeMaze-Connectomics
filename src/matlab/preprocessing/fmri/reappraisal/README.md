# Reappraisal fMRI preprocessing

This module documents the conditioning/reappraisal fMRI preprocessing used
for the manuscript.

## Canonical workflow

```text
private Bruker/ParaVision raw MRI
        ↓
conversion + x10 SPM scaling + reorientation
        ↓
remove first 5 EPI volumes
        ↓
AFNI 3dDespike
        ↓
field-map correction + realignment/unwarping
        ↓
slice-time correction
        ↓
functional-to-anatomical coregistration
        ↓
anatomical brain extraction
        ↓
alignment to Paxinos-space mouse template
        ↓
bias correction + segmentation
        ↓
DARTEL group-template normalization
        ↓
normalized task EPI
        ├── unsmoothed → FC / graph branch
        ├── 0.6 mm FWHM → primary voxelwise BOLD branch
        └── 0.4 mm FWHM → robustness BOLD branch
        ↓
masking / intensity normalization
        ↓
wavelet despiking
```

The distinction between smoothed voxelwise BOLD inputs and unsmoothed
FC/graph inputs is intentional.

## Entry point

```text
main_preprocessing_fmri_reappraisal.m
```

This is a workflow/provenance master for the private raw MRI data. It performs
path, scan-list, and dependency validation, while raw-data processing-stage
switches remain disabled in the public repository.

## Raw-data configuration

Set:

```text
NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT
```

for access to the private Bruker acquisition tree.

The acquisition list is expected under the repository reference-data tree and
is converted into a subject-by-scan manifest under `data/interim/`.

## MATLAB/runtime dependencies

Project functions are under this module's `functions/` tree. The master adds
only preprocessing-relevant repository toolboxes:

```text
spm12_animal
wavelet_despiking
```

External dependencies:

```text
SPM12
AFNI 3dDespike
```

Analysis packages such as BCT, BASCO, and NBS are added only by their own
analysis modules.

## DARTEL affine TPM

The historical mouse DARTEL normalization requires a project-specific 4-D
mouse TPM. Supply it through `job.tpm` or:

```text
NOSEMAZE_DARTEL_AFFINE_TPM
```

The personal historical absolute path is intentionally not stored in the
public source.

See `INPUT_MANIFEST.md` and `DEPENDENCIES.md` for input and dependency detail.
