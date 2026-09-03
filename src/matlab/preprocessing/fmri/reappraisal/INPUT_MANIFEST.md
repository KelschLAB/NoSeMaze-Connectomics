# Reappraisal fMRI preprocessing input manifest

## Do not copy to the public repository

The original Bruker / ParaVision MRI acquisitions:

```text
EPI task data
field maps
high-resolution anatomical MRI
```

remain external/private. The cleaned configuration expects their root via:

```text
NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT
```

## Small project inputs that should be copied if redistribution is allowed

### Scan list

Historical source:

```text
03-processed-data/03-MRI/01-reappraisal/03-filelists/
scanlist_reappraisal_jr.csv
```

Recommended repository destination:

```text
data/reference/fMRI/reappraisal/scanlist_reappraisal_jr.csv
```

This CSV is now included in the preprocessing package. It contains 271
acquisition rows for 24 subjects. The six preprocessing-relevant scan types
(`EPI_RS`, `EPI_reappraisal`, `Fieldmap_1`, `Fieldmap_2`, `Fieldmap_3`,
`TurboRARE3D`) each occur exactly once per subject.

The complete file is retained for provenance; the preprocessing generates a
clean subject-by-scan manifest automatically.

### Anatomical reference template and brain mask

Historical files:

```text
DLtemplate_brain_rs1x1x1.nii
DLtemplate_brainmask_rs1x1x1_polish.nii
```

Recommended destination:

```text
data/reference/templates/fMRI/
```

These are reference resources rather than subject MRI data. Before
committing them publicly, verify that their source/license permits
redistribution.

### Tissue priors

Historical files:

```text
sGM_template_markus_inPax_msk.nii
sWM_template_markus_inPax_msk.nii
sCSF_template_markus_inPax_msk.nii
sBackground_template_markus_msk.nii
```

Recommended destination:

```text
data/reference/templates/fMRI/TPM/
```

Again, verify redistribution rights.

## Derived study-specific files worth retaining

The historical `filelist_ICON_reappraisal_jr.mat` contains machine-specific
paths and should NOT simply be copied to GitHub. It should be regenerated
from the public scan list and the user's private preprocessing workspace.

The following study-derived DARTEL products can be useful for provenance
and downstream reproduction if their distribution is permitted:

```text
Template_6.nii
mask_template_6.nii / mask_template_6_polished.nii
```

A reasonable destination is:

```text
data/processed/fMRI/preprocessing/reappraisal/reference/
```

Whether these should be committed depends on repository size and your data
availability policy.

## RHD / task-timing inputs

Protocol files:

```text
data/raw/RHD/reappraisal/protocol_files/*protocol.mat
```

RHD files:

```text
data/raw/RHD/reappraisal/rhd_files/*.rhd
```

If the RHD recordings are not to be distributed, keep them external and set:

```text
NOSEMAZE_REAPPRAISAL_RHD_ROOT
```

The protocol MAT files can still be included separately if allowed.
