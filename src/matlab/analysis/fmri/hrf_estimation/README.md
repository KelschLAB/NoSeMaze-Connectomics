
# HRF cohort: study-specific mouse HRF estimation

The public pipeline now contains the complete analysis chain from the
individual odor-mask GLM through the fitted HRF.

```text
HRF mask GLM
    src/matlab/analysis/fmri/glm/hrf/
        ↓
individual odor mask
        ↓
main_residual_glm_hrf.m
        ↓
4-D nuisance-only residual image
        ↓
main_extract_hrf_timecourses.m
        ↓
mean residual time course in individual odor mask
        ↓
main_hrf_estimation.m
        ↓
multi-start fminsearch
        ↓
final study-specific HRF
```

## Fitting algorithm

The actual historical objective is now included:

```text
functions/estimate_GLM_model_highres.m
```

and the multi-start optimizer is:

```text
functions/fit_hrf_multistart.m
```

Therefore the `fminsearch` HRF fit no longer has a missing scientific
dependency.

## Residual/time-course helpers

The supplied historical utilities have been adapted into:

```text
functions/merge_residuals_hrf.m
functions/extract_roi_timecourse.m
```

They avoid GUI directory selection and automatic deletion while preserving
the underlying concatenation and ROI extraction logic.

## Final fitting configuration

```text
sessions             11
TR                   0.265 s
T / T0               6 / 1
mask                 individual 2sHRF odor mask
onset parameter      disabled
response delay grid  1:0.5:4
undershoot grid      4:3:10
dispersion grid      0.5:0.5:1.5
ratio grid           3:1.75:10
optimizer            fminsearch
MaxFunEvals          100000
```

The final fitted HRF consumed by the conditioning/control analyses remains
under:

```text
src/matlab/preprocessing/toolboxes/spm12_animal/
    longTC/hrf_withoutOnset_from2sHRF-GLM/spm_hrf.m
```
