# Reproducibility status: reappraisal graph analysis

## Primary manuscript workflow

```text
BASCO v11 52x52 cormats
        ↓
remove diagonal / positive edges only
        ↓
diacut connected thresholding
        ↓
densities 0.10:0.01:0.50
        ↓
maximum-weight normalization
        ↓
per-threshold manuscript metrics:
    g_swp
    g_delta_C
    g_delta_L
    l_strength
    l_cc
        ↓
mean across thresholds ("AUC")
```

## Included code

```text
rb_graph_thresh_flex.m
rb_graph_individual_flex.m
rb_gstruc_2_auc.m
diacut.m
small_world_propensity.m
```

The Brain Connectivity Toolbox supplies `weight_conversion`,
`clustering_coef_wu`, and the standard graph utilities required by the
primary code.

## Deliberately excluded from primary calculation

The public primary pipeline does not calculate manuscript-unused metrics:

```text
degree
betweenness
efficiency
modularity
participation
null-normalized SWI/CPL/etc.
resilience
```

The historical full implementation is retained under `legacy/` for
provenance.

## Important correction

The `_JR` SWP outputs are not part of the manuscript analysis and have been
removed from the executable graph code:

```text
g_swp_JR
g_delta_C_JR
g_delta_L_JR
```

The primary analysis uses the direct outputs of `small_world_propensity.m`:

```text
g_swp
g_delta_C
g_delta_L
```

## Remaining external requirements

```text
derived cormat_v11_*.mat files
Brain Connectivity Toolbox
MATLAB Bioinformatics Toolbox for graphallshortestpaths
```

`small_world_propensity.m` is stochastic and the historical analysis did
not set an RNG seed; this is documented rather than altered.
