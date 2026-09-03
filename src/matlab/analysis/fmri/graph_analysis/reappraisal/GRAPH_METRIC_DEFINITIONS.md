# Primary manuscript graph metrics

The public graph-analysis pipeline now computes only the network quantities
used in the manuscript.

## Global metrics

```text
g_swp
g_delta_C
g_delta_L
```

These are the **direct outputs** from:

```matlab
[SWP, delta_C, delta_L] = small_world_propensity(M_thr);
```

The former custom fields:

```text
g_swp_JR
g_delta_C_JR
g_delta_L_JR
```

are not calculated and should not be used.

## Local metrics

```text
l_strength
l_cc
```

`l_strength` is the weighted node strength after thresholding and
maximum-weight normalization.

`l_cc` is the weighted undirected clustering coefficient from the Brain
Connectivity Toolbox (`clustering_coef_wu`).

## Network preparation

For each subject and density:

```text
positive Pearson FC matrix
        ↓
diacut(M, density)
        ↓
connected thresholded network
        ↓
weight_conversion(..., 'normalize')
        ↓
manuscript graph metrics
```

Density range:

```text
0.10:0.01:0.50
```

## Historical "AUC"

The downstream `rb_gstruc_2_auc.m` calculates the arithmetic mean across the
41 thresholds for every `g_*` and `l_*` field.

Therefore the final `auc_struc` contains only:

```text
g_swp
g_delta_C
g_delta_L
l_strength
l_cc
o_thr_range
```

This substantially reduces the public dependency chain while reproducing
the graph quantities actually used in the manuscript.

## Stochasticity

`small_world_propensity.m` constructs regular/random comparison matrices
using `randi` and `randperm`. The historical analysis did not set an RNG
seed. Thus recomputing SWP/delta_C/delta_L from scratch can show small
run-to-run variation.

The repository preserves this historical behavior rather than introducing
a new seed that would not reproduce the original execution.
