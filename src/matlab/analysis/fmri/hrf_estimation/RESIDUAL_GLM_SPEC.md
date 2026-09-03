# HRF residual-GLM specification

The HRF time-course extraction uses a nuisance-only first-level GLM with no
task regressors.

Canonical entry point:

```text
main_residual_glm_hrf.m
```

Implementation:

```text
functions/run_residual_glm_hrf.m
```

Primary HRF-cohort settings:

```text
n sessions             11
TR                     0.265 s
microtime              6 / 1
nuisance regressors    14
conditions             none
high-pass filter       128 s
serial correlations    AR(1)
residual output        explicitly enabled
```

The 14 nuisance regressors are the same motion/CSF nuisance model used by the
HRF mask GLM. `run_residual_glm_hrf.m` explicitly requests residual images
from SPM rather than relying on a modified historical SPM installation.

Residual images are concatenated by `merge_residuals_hrf.m` and then used for
ROI time-course extraction.
