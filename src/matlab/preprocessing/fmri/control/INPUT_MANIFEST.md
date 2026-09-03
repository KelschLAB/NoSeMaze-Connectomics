# Control fMRI preprocessing input manifest

## Non-public raw MRI

The original Bruker/ParaVision control MRI acquisitions are not distributed.

The cleaned configuration expects their root through:

```text
NOSEMAZE_CONTROL_FMRI_RAW_ROOT
```

## Scan list

Historical source:

```text
ScanList_reappraisal_control_2023.csv
```

Recommended repository destination:

```text
data/reference/fMRI/control/ScanList_reappraisal_control_2023.csv
```

The historical master identifies:

```text
EPI_FID_1.1_22Slc
TurboRARE3D
Fieldmap_1
Fieldmap_2
```

from this file.

The old absolute-path `filelist_ICON_reappraisal_control_2023_jr.mat`
should not be committed as the canonical public input. It should be
regenerated from the scan list and converted MRI workspace.

## Shared anatomical reference data

Expected under:

```text
data/reference/templates/fMRI/
├── DLtemplate_brain_rs1x1x1.nii
├── DLtemplate_brainmask_rs1x1x1_polish.nii
└── TPM/
    ├── sGM_template_markus_inPax_msk.nii
    ├── sWM_template_markus_inPax_msk.nii
    ├── sCSF_template_markus_inPax_msk.nii
    └── sBackground_template_markus_msk.nii
```

Verify redistribution rights before committing third-party/reference NIfTI
resources publicly.

## Study-derived control DARTEL products

If permitted and useful for downstream provenance, retain the final control
study template / mask under:

```text
data/processed/fMRI/preprocessing/control/reference/
```

rather than inside machine-specific preprocessing directories.
