# fMRI functional-connectivity analyses

This directory contains the subject-level task-related functional-connectivity
pipeline.

```text
unsmoothed preprocessed EPI
        ↓
trial-wise BASCO GLM
        ↓
trial beta series
        ↓
52 × 52 Pearson correlation matrices
        ├──→ figure-specific NBS inference
        └──→ graph analysis
```

## BASCO

The executable subject-level FC code is under:

```text
src/matlab/analysis/fmri/functional_connectivity/basco/
├── common/
├── reappraisal/
└── control/
```

The primary manuscript FC analyses use **unsmoothed normalized EPI data**.
Smoothed EPI branches belong to the voxelwise BOLD analyses and are not the
primary FC/graph inputs.

## Network-Based Statistics

NBS is **not treated as a separate standalone preprocessing/analysis stage**
in this repository. The NBS models are panel-specific and are implemented
in the corresponding manuscript figure scripts together with the exact
contrast and visualization used for that panel.

The directory:

```text
src/matlab/analysis/fmri/functional_connectivity/nbs/
```

is therefore retained only as a pointer explaining where NBS belongs; it is
not an incomplete analysis module.

## Graph analysis

Graph-theoretical analyses are downstream of the BASCO correlation matrices
and live separately under:

```text
src/matlab/analysis/fmri/graph_analysis/
```
