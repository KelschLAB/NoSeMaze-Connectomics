
# Legacy HRF-estimation scripts

These are the exact supplied historical snapshots.

They are retained because they document the original development history,
but two active settings in the snapshots are not used as the public final
configuration:

1. `master_HRF_estimation_jr_legacy.m` currently has `hrf_new = 0`, whereas
   the final packaged manuscript HRF is the `from2sHRF-GLM` branch.

2. `master_TC_analysis_HRF_jr_legacy.m` contains later reappraisal-derived
   masks in its active `Pmsk_all` list.

The cleaned scripts outside `legacy/` resolve these provenance issues
explicitly rather than silently following whichever switch happened to be
active in a historical working file.
