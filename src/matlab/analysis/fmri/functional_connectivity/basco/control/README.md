# Control BASCO functional connectivity

Primary control FC configuration:

```text
BASCO / cormat     v6
trial model        v16
EPI                unsmoothed
variant            normal wavelet-despiked variant (no DVARS-scrub variant)
prefix             wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_
suffix             _c2t_wds
HRF                HRFlongTC_withoutOnset_from2sHRF-GLM
TR                 1.2 s
conditions         Lavender, TP_noPuff
atlas              merged / combined hemispheres
network            52 anatomical ROIs
```

The control cohort therefore uses the same combined-hemisphere 52-node
network definition as the conditioning cohort.

The public manuscript pipeline generates the derived cormats required by
the downstream FC/NBS/graph analyses from the **normal v6** branch, not the
DVARS-based v7 branch.
