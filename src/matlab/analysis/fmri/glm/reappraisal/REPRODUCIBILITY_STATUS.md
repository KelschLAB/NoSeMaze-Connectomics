# Reproducibility status

## Current status

The primary reappraisal voxelwise GLM is now reproducible from the processed
fMRI and processed event-timing inputs.

The complete analysis chain is:

```text
processed protocol/event timing
        ↓
v22 task-regressor generation
        +
primary 0.6-mm / s6 preprocessed EPI
        +
14 nuisance covariates
        ↓
SPM first-level model
        ↓
subject-level contrasts
        ↓
general one-sample second-level models
        ↓
social-hierarchy second-level regressions
```

## Primary model

```text
regressor model       v22
number of task regs   10
smoothing             0.6 mm FWHM (s6)
nuisance model        v1
nuisance regressors   14
TR                     1.2 s
high-pass filter       128 s
serial correlations   AR(1)
estimation             Classical
```

The 0.4-mm / s4 branch is a robustness analysis and is not the primary
configuration.

## Reproducibility boundary

This module is fully reproducible from processed inputs provided that the
following are available:

```text
processed event timing
primary s6 preprocessed EPI
nuisance-source text files
mouse HRF implementation
explicit Allen-brain mask
SPM12
```

Raw MRI acquisitions are not required for reproducing the GLM from processed
fMRI inputs. Raw-to-processed MRI reproducibility is documented separately
under `src/matlab/preprocessing/fmri/`.
