# Voxelwise fMRI GLM analyses

The voxelwise analysis is separated into shared SPM machinery and
cohort-specific model definitions.

```text
glm/
├── common/        # shared SPM first-/second-level utilities
├── reappraisal/   # conditioning cohort
├── control/       # no-puff control cohort
└── hrf/           # odor-mask GLM for HRF estimation cohort
```

## Primary conditioning/reappraisal model

```text
regressors        v22
covariates        v1 / 14 nuisance regressors
EPI               0.6-mm smoothed wavelet-despiked EPI
TR                1.2 s
```

The reappraisal module also provides second-level covariate analyses for:

```text
SocialRank
DavidScore
FractionActiveChases
FractionBeingChased
DeltaL_change
```

Behavioral hierarchy variables and the graph-derived ΔL variable use separate
entry points so their provenance remains explicit.

## No-puff control model

```text
regressors        v22
covariates        v1 / 14 nuisance regressors
EPI               0.6-mm smoothed wavelet-despiked EPI
TR                1.2 s
Block 3           trials 81-120 as one block
```

## HRF mask GLM

The separate HRF-cohort GLM under `hrf/` generates individual odor-responsive
masks used by the study-specific HRF derivation. It is not part of the
conditioning/control voxelwise group inference.

The raw and large preprocessed MRI data are not distributed. GLM execution
therefore requires the corresponding processed EPI and processed event-timing
inputs, either in the repository data tree or configured external storage.
