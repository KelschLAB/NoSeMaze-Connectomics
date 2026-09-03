# BASCO refactor: reappraisal connectivity

Recommended repository location:

```
scripts/matlab/brain_network/BASCO/
├── master_BASCO_reappraisal.m
├── config_BASCO_reappraisal.m
├── create_input_BASCO.m
├── create_betaseries_BASCO.m
├── create_cormat_BASCO.m
└── anadef_reappraisal.m              # still required from legacy analysis
```

Additional legacy code/data required before the full stage can run:

1. `anadef_reappraisal.m` used by BASCO model specification.
2. `wwf_covmat_hres_jr.m` plus any non-standard helper functions it calls.
3. The exact custom animal-HRF implementation used for `longTC/withoutOnset_from2sHRF-GLM`.
4. BASCO, MarsBaR, and SPM12 as external dependencies (prefer documented paths/environment variables rather than committing the toolboxes unless redistribution is appropriate).
5. The 2023 separated-hemisphere Allen atlas label text file and NIfTI.
6. The processed protocol files containing `events.puff_or_not`, required for the `Odor_TPPuff` and `Odor_TPNoPuff` subseries.
7. The reappraisal functional file list or a replacement repo-local subject manifest.

The old file list should not be committed unchanged if it contains absolute paths. Either regenerate it with repo-local paths or replace it with a portable subject manifest.
