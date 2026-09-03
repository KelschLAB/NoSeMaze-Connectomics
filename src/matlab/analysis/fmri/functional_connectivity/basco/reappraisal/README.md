# Reappraisal task-related functional connectivity: BASCO v11

## Primary entry point

```text
main_fc_basco_reappraisal.m
```

## Confirmed primary pipeline

```text
createRegressorsV19
        ↓
buildManifest
        ↓
prepareInput
        ↓
runBasco
        ↓
createBetaSeries
        ↓
createCorrelationMatrices
        ↓
validateOutputs
```

All stages are disabled by default.

## Primary inputs/settings

```text
EPI prefix
wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_

EPI suffix
_c1_c2t_wds

BASCO
v11

trial-wise regressors
v19

HRF
HRFlongTC_withoutOnset_from2sHRF-GLM

nuisance
rp_regressors_despiked_motcsf_der_v11.txt
= identical content to the primary voxelwise-GLM v1 nuisance model

atlas
AllenBrain_2021_v2_inPax_merged_jr.txt
AllenBrain_2021_v2_inPax_merged.nii

network nodes
52 merged anatomical ROIs
```

Smoothed EPI data are not part of the primary FC/graph pipeline.

## Important distinction from the voxelwise GLM

```text
voxelwise BOLD analysis
    v22
    block/condition regressors
    0.6-mm smoothing

BASCO FC analysis
    v19
    trial-wise regressors
    unsmoothed EPI
```

Do not reuse the v22 task model inside BASCO.

## Left/right combination

See:

```text
ATLAS_COMBINATION.md
```

The merged atlas text file can assign multiple integer labels to one ROI.
Those labels are combined before spatial averaging, so homologous left and
right regions form one anatomical node.

## Primary FC output

The analysis produces 10 manuscript FC matrices per subject. See:

```text
PRIMARY_MATRIX_SPEC.md
```

## Downstream modules

```text
BASCO
    → subject-level FC matrices

NBS
    → edge/network-level group inference

graph_analysis
    → network topology / ΔL / ΔC / SWP / local metrics
```

These should remain separate repository modules.


## Data/reference requirements

The analysis expects the merged 52-node Allen atlas definition and the
historical BASCO specification mask in the repository data/reference tree or
configured private processed-data storage. Per-subject execution additionally
requires unsmoothed processed task EPI, processed event timing, and the v1
nuisance-regressor file.

SPM12 and BASCO are runtime dependencies. NBS and graph analysis are separate
downstream modules rather than stages inside the BASCO master.
