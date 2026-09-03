
# fMRI analyses

The fMRI source code is organized by analysis stage:

```text
src/matlab/analysis/fmri/
├── hrf_estimation/
├── glm/
├── functional_connectivity/
└── graph_analysis/
```

Dependency chain:

```text
separate ultrafast HRF cohort
        ↓
study-specific mouse HRF
        ↓
conditioning/control voxelwise GLM + BASCO
        ↓
52 × 52 FC matrices
        ↓
NBS / graph analyses
```

The HRF cohort is therefore part of the methodological provenance of the
main fMRI analyses rather than an unrelated side analysis.
