# Common voxelwise GLM functions

This directory contains SPM functions shared by the conditioning/reappraisal
and control cohorts.

```text
common/functions/
├── find_repo_root_analysis.m
├── find_preprocessed_epi.m
├── find_unique_subject_file.m
├── collect_firstlevel_contrasts.m
├── do_firstlevel_jr.m
├── do_secondlevel_jr.m
├── job_firstlevel_covariates_jr.m
├── job_firstlevel_no_covariates_jr.m
└── job_secondlevel_jr.m
```

Cohort-specific event definitions, filenames, covariates, configuration and
second-level behavioral regressions belong in the cohort folders rather than
here.
