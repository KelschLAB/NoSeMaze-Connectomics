# Control voxelwise GLM

Primary control model:

```text
regressors        v22
covariates        v1 (14 columns)
EPI               wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_
suffix            _c2t_wds
smoothing         s6 / 0.6 mm
HRF               HRFlongTC_withoutOnset_from2sHRF-GLM
TR                1.2 s
fmri_t/fmri_t0    22 / 1
DerDisp           [0 0]
orth              1
```

## v22 control task model

Block 3 is **not** split into early and late portions.

```text
distal / odor:
    Lavender_Bl1_1to10
    Lavender_Bl1_11to40
    Lavender_Bl2
    Lavender_Bl3

proximal / expected puff time:
    TP_Puff_Bl1_1to10
    TP_Puff_Bl1_11to40
    TP_Puff_Bl2
    TP_Puff_Bl3
```

The control cohort had no actual puffs; the proximal regressors represent the
corresponding anticipated puff-time positions.

The historical control version notes associate GLM v22 with an odor delay of
0.425 s. This is distinct from the FC v16/cormat-v6 timing model.

The public module retains the final model specification without bundling duplicate historical working scripts.
