# Reappraisal graph analysis

## Primary entry point

```text
main_graph_analysis_reappraisal.m
```

## Input

The graph-analysis module starts from the BASCO v11 correlation matrices.
It does not require raw or preprocessed 4-D fMRI data.

## Historical primary settings

Recovered from `master_GA_reappraisal_jr.m`:

```text
cormat version       v11
atlas                 merged left/right, 52 nodes
edge handling         positive weights only
diagonal              removed
density thresholds    0.10:0.01:0.50
normalization         max
graph metrics         manuscript only
manuscript mean       0.45-0.50 (after calculating 0.10-0.50)
```

The historical variable `binarization_method = 'max'` is renamed
`normalizationMethod`, because `max` is passed as the normalization argument
to `rb_graph_thresh_flex`.

The cleaned pipeline computes graph structures for all 10 primary BASCO
matrix sets rather than selecting files by fragile `dir()` row numbers.

Processing:

```text
cormat
   ↓
set diagonal to 0
   ↓
retain weights > 0
   ↓
rb_graph_thresh_flex(..., 0.10:0.01:0.50, 'max', {'manuscript'})
   ↓
gstruc
   ↓
rb_gstruc_2_auc(gstruc, 1, 41)
   ↓
auc_struc
```

No Fisher-z transformation is used in this primary graph pipeline.

## Output

```text
data/processed/fMRI/graph_analysis/reappraisal/v11/max_connected/
├── positive_cormats/
├── gstruc/
├── auc/
└── manifests/
```

## Graph helpers

The cleaned repository now includes:

```text
src/matlab/analysis/fmri/graph_analysis/common/functions/
├── rb_graph_thresh_flex.m
└── rb_gstruc_2_auc.m
```


### Important historical "AUC" detail

`rb_gstruc_2_auc.m` does **not** calculate a trapezoidal numerical integral.
It calculates the arithmetic mean of each graph metric across the selected
thresholds.

For the primary equally spaced threshold range `0.10:0.01:0.50`, this value
is proportional to a conventional AUC by a constant scaling factor. The
public code preserves the historical mean-based calculation exactly rather
than silently changing the manuscript results.

## Primary graph-metric implementation

The public pipeline intentionally computes only the metrics used in the
manuscript:

```text
global:
    SWP
    delta_C
    delta_L

local:
    strength
    clustering coefficient
```

The canonical public graph function intentionally omits modularity, efficiency, betweenness, resilience, and null-normalized metrics because they are not used by this manuscript.

Included executable dependencies:

```text
rb_graph_thresh_flex.m
rb_graph_individual_flex.m
rb_gstruc_2_auc.m
diacut.m
small_world_propensity.m
Brain Connectivity Toolbox
```


See `GRAPH_METRIC_DEFINITIONS.md`.
