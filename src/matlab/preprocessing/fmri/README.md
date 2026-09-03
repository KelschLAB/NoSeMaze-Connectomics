# fMRI preprocessing

Preprocessing code is organized by cohort:

```text
fmri/
├── reappraisal/   # conditioning cohort
├── control/       # no-puff control cohort
└── hrf/           # ultrafast HRF-estimation cohort
```

The original MRI acquisitions are not distributed publicly. Raw-data roots
are configured through environment variables in the cohort-specific config
files.

The reappraisal/control `main_preprocessing_*` files are public
**workflow/provenance masters**: they define the ordered preprocessing chain,
paths, and dependencies, while their raw-data stage switches remain disabled
because the private acquisition tree and full historical execution
environment are not distributed.

The HRF cohort has a more directly executable preprocessing wrapper but also
requires access to its private acquisition data.
