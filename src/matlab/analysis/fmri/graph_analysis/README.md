# fMRI graph-theoretical analyses

Graph analysis is downstream of BASCO functional-connectivity estimation.

```text
BASCO 52 × 52 correlation matrices
        ↓
remove diagonal
        ↓
retain positive weights
        ↓
connected density thresholding with diacut
        ↓
maximum-weight normalization
        ↓
manuscript graph metrics
        ↓
mean across selected density thresholds
        ↓
figure/statistical analyses
```

## Primary manuscript metrics

The streamlined public graph pipeline calculates only:

```text
global:
    delta_C
    delta_L
    SWP

local:
    node strength
    clustering coefficient
```

The threshold-dependent metrics are calculated over:

```text
0.10:0.01:0.50
```

The manuscript summary uses the mean over:

```text
0.45:0.01:0.50
```

Historical code and filenames use the term `AUC`, but
`rb_gstruc_2_auc.m` calculates an **arithmetic mean across the selected
thresholds**, not a trapezoidal numerical integral. The historical
calculation is preserved for numerical reproducibility.

NBS is not part of this graph-analysis module; panel-specific NBS is kept
with the corresponding figure scripts.
