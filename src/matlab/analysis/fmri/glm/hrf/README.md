
# HRF-cohort odor-mask GLM

This module contains the first-level GLM used to define the individual
odor-responsive masks that feed the study-specific HRF estimation.

```text
main_glm_hrf_mask.m
glm_hrf_config.m
functions/
```

## Final mask-generating model represented here

```text
n                    11
TR                   0.265 s
microtime            6 / 1
EPI                  msk_s5_rwrst_a1_u_del25_*_c2t.nii
regressors           v1
odor delay           +0.7 s
conditions           500 / 1000 / 2400 ms odor
durations            0.5 / 1.0 / 2.4 s
nuisance             v1, 14 columns
orthogonalization    1
derivatives          [0 0]
combined contrast    Odors_combined
```

The historical covariate model is:

```text
rp1..rp6
rp1_deriv..rp6_deriv
csf
csf_deriv
```

The historical batch layout yields `Odors_combined` as `con_0011`, but the
clean mask creator resolves the contrast by **name** rather than relying on
that fragile index.

## Initial 2-s HRF

The later individual-mask TC script explicitly uses:

```text
*_odormask_2sHRF.nii
```

The historical GLM master referred to this custom-HRF branch as `hrf_new`.
That exact folder was not supplied. The public config currently points to
the packaged earlier 2-s mouse HRF (`hrf_philipplebhardt`) as the candidate
implementation. If the exact historical `hrf_new/spm_hrf.m` becomes
available, replace only that configured path.

## Important 1% versus 5% discrepancy

The historical mask script says:

```text
5% maximum values
```

but actually executes:

```matlab
threshold = img_vec_sorted(end-round(length(img_vec_sorted)/100));
```

which is approximately the highest **1%**, not 5%.

The public pipeline defaults to **0.01** to reproduce the executed code and
records the discrepancy explicitly. Do not change this to 5% without first
deciding which value represents the manuscript analysis.
