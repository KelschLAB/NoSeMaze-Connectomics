# Control graph analysis

Primary control graph analysis uses the **same normal cormat v6 branch** as
the functional-connectivity analysis.

```text
cormat version       v6
hemisphere mode      combined
network size         52 ROIs
FC input             normal unsmoothed wavelet-despiked variant
DVARS variant        not used
positive edges       yes
connected threshold  diacut
normalization        max
thresholds           0.10:0.01:0.50
manuscript summary   0.45-0.50
```

The public pipeline calculates only the graph quantities used in the
manuscript:

```text
g_delta_C
g_delta_L
g_swp
l_strength
l_cc
```

The old DVARS-based v7 branch is deliberately excluded from the primary
pipeline.
