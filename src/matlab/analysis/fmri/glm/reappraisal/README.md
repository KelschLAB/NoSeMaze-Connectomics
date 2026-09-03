# Reappraisal / conditioning voxelwise GLM

## Primary manuscript configuration

The primary voxelwise GLM uses:

```text
regressor model       v22
smoothing             0.6 mm FWHM (s6)
nuisance model        v1
nuisance regressors   14
TR                     1.2 s
microtime resolution  22
microtime onset       1
high-pass filter       128 s
serial correlations   AR(1)
global normalization  None
estimation             Classical
```

The 14 nuisance covariates are:

```text
6 realignment parameters
6 first temporal derivatives of the realignment parameters
CSF time course
first temporal derivative of the CSF time course
```

Framewise displacement is not included in the primary v1 nuisance model.

## Primary EPI branch

The configured input pattern is:

```text
wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_*_c1_c2t_wds.nii
```

The s4 / 0.4-mm branch is a robustness analysis and is intentionally not the
primary configuration.

## Primary regressor model: v22

The primary model is now fully specified and generated directly from the
processed event-timing files.

It contains 10 event-related regressors:

```text
Odor onset:
1. Lavender_Bl1_1to10
2. Lavender_Bl1_11to40
3. Lavender_Bl2_NoPuff
4. Lavender_Bl2_Puff
5. Lavender_Bl3

Nominal puff time:
6. TP_Puff_Bl1_1to10
7. TP_Puff_Bl1_11to40
8. TP_Puff_Bl2_NoPuff
9. TP_Puff_Bl2_Puff
10. TP_Puff_Bl3
```

All durations are 0 and no parametric modulators are used.

Odor-onset regressors are shifted by 0.7 s to account for odor travel time
estimated with the mini-PID.

Block 3 is modeled as one regressor in v22. The early/late split used in the
historical v26 model is not part of the primary v22 analysis.

The generator is:

```text
functions/create_regressors_reappraisal_v22.m
```

and writes:

```text
data/processed/fMRI/glm/reappraisal/regressors/
├── ZI_M01_v22.mat
├── ...
└── ZI_M24_v22.mat
```

plus `regressor_manifest_v22.csv`.

## Running

Edit the stage switches in:

```text
main_glm_reappraisal.m
```

Recommended order:

```text
1. createRegressors
2. createCovariates
3. firstLevel
4. secondLevel
5. main_secondlevel_social_hierarchy_reappraisal.m
6. main_secondlevel_graph_covariates_reappraisal.m
```

## Shared SPM functions

Generic first-/second-level machinery is in:

```text
src/matlab/analysis/fmri/glm/common/functions/
```

This same machinery should be reused for the control cohort.

## Social-hierarchy second level

The reappraisal-specific behavioral second-level models remain local because
they do not apply to the control cohort.

Current reduced explanatory-variable set:

```text
SocialRank
DavidScore
FractionActiveChases
FractionBeingChased
```

Graph-derived ΔL is handled separately by:

```text
main_secondlevel_graph_covariates_reappraisal.m
```

It loads the proximal-CR 45-50% graph summary, computes `g_delta_L(TEST) - g_delta_L(PRE)`, verifies subject IDs, and invokes the same generic second-level SPM regression helper.
