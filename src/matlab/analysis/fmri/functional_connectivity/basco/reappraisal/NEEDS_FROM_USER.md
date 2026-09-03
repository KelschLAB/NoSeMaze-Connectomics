# Remaining files/data to place in the repository

The historical BASCO analysis code/settings are now sufficiently specified.
The remaining items are primarily data/reference files rather than missing
analysis logic.

## Required reference files

Copy, if redistribution is permitted:

```text
data/reference/atlases/AllenBrain_2021_v2/
├── AllenBrain_2021_v2_inPax_merged_jr.txt
└── AllenBrain_2021_v2_inPax_merged.nii
```

Also make the historical BASCO specification mask available at:

```text
data/processed/fMRI/preprocessing/reappraisal/reference/
└── mask_template_6_polished.nii
```

or set:

```text
NOSEMAZE_REAPPRAISAL_DARTEL_MASK
```

## Required processed subject inputs

For each subject:

```text
unsmoothed processed task EPI
processed protocol/event file
regressors_despiked_motcsf_der.txt
```

## External/runtime dependencies

```text
SPM12
BASCO
MarsBaR if required by BASCO
spm12_animal/longTC/hrf_withoutOnset_from2sHRF-GLM
```

## Downstream analyses still separate

To complete the *group-level FC inference* rather than merely FC matrix
generation, the historical NBS scripts/settings still need to be integrated.

Graph-metric scripts should be handled separately under:

```text
src/matlab/analysis/fmri/graph_analysis/
```
