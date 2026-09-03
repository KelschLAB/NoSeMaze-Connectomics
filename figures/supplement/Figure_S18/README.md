# Supplementary Figure S18

Script used to reproduce Supplementary Figure S18, which shows the functional-connectivity values contributed by connections that enter the network as sparsity is relaxed in 5% steps.

The revised supplementary caption describes eight threshold intervals:

```text
10 → 15%
15 → 20%
20 → 25%
25 → 30%
30 → 35%
35 → 40%
40 → 45%
45 → 50%
```

and compares PRE and TEST distributions in both conditioning and no-puff control cohorts.

## Script

```text
figure_S18_added_connections_by_threshold.m
```

Outputs are written to:

```text
results/supplement/Figure_S18/
```

## Input

The script reuses the graph structures used for the graph analyses:

```text
data/processed/fMRI/Figure_4/
├── conditioning/
│   ├── gstruc_TPnoPuff11to40_p.mat
│   └── gstruc_TPnoPuff81to120_p.mat
└── control/
    ├── gstruc_TPnoPuff11to40_p.mat
    └── gstruc_TPnoPuff81to120_p.mat
```

Each file must contain:

```text
gstruc
```

with the thresholded connectivity matrix stored in:

```text
gstruc(thresholdIndex,animal).o_CIJ_thresh
```

No raw BASCO `cormat` files are required.

## Block definition

```text
PRE  = TPnoPuff trials 11–40
TEST = TPnoPuff trials 81–120
```

These are the proximal-CR graph-analysis blocks.

## Density thresholds

Historical graph-threshold indices are:

```matlab
thresholdIndices = 1:5:41;
```

which map to displayed network densities:

```matlab
thresholdLabels = thresholdIndices + 9;
```

therefore:

```text
10, 15, 20, 25, 30, 35, 40, 45, 50%
```

The script checks that every graph structure contains at least the required threshold index 41.

It also verifies that PRE and TEST contain the same number of animals within each cohort.

## Analysis logic

For each cohort/block combination:

```text
conditioning PRE
conditioning TEST
control PRE
control TEST
```

the script:

1. collects all values from `o_CIJ_thresh` across animals at every density threshold;
2. builds histograms using:

```matlab
BinWidth = 0.01
```

3. verifies that histogram edges are identical across thresholds within each series;
4. calculates the change in histogram counts between adjacent density thresholds;
5. sets negative count differences to zero, matching the historical analysis;
6. plots those added-connection distributions for all eight 5%-density intervals.

Thus, for example:

```text
45 → 50%
```

shows the FC-value distribution of connections newly represented when increasing density from 45% to 50%.

## Important interpretation

The Supplementary Figure S18 caption highlights two features:

- FC values of newly added connections in the **conditioning TEST** network are shifted higher than the other PRE/control distributions;
- even between **45% and 50% density**, a relevant number of conditioning-TEST connections with FC values around 0.3–0.35 are still added.

This provides a descriptive explanation for why clustering-coefficient effects can remain visible even at relatively high graph densities.

## Histogram implementation

The repository script deliberately retains the historical histogram-count subtraction rather than replacing it with a new edge-selection algorithm.

For each series:

```matlab
addedCounts = counts_at_higher_density - counts_at_lower_density;
addedCounts(addedCounts < 0) = 0;
```

The script checks that bin edges are identical **within each series** before subtraction.

Conditioning/control and PRE/TEST series may retain their own histogram edge ranges, matching the historical workflow.

## Source-data exports

The original cumulative histogram counts are exported separately for:

```text
conditioning PRE
conditioning TEST
control PRE
control TEST
```

For example:

```text
SourceData_Conditioning_TPnoPuff11to40.csv
SourceData_Conditioning_TPnoPuff81to120.csv
SourceData_Control_TPnoPuff11to40.csv
SourceData_Control_TPnoPuff81to120.csv
```

For every density interval, the added-connection distributions are also exported separately, e.g.:

```text
SourceData_addedConnections_Conditioning_PRE_45to50.csv
SourceData_addedConnections_Conditioning_TEST_45to50.csv
SourceData_addedConnections_Control_PRE_45to50.csv
SourceData_addedConnections_Control_TEST_45to50.csv
```

The corrected script additionally writes:

```text
AnalysisMetadata_Figure_S18.csv
Results_Figure_S18_AddedConnections.mat
```

## MATLAB setup

The script determines the repository root from its own location and loads repository MATLAB code recursively from:

```text
src/matlab/
```

Optional provenance helper:

```text
docDataSrc.m
```

There are no additional statistical-toolbox requirements for this descriptive figure.

## Running

```matlab
run('figures/supplement/Figure_S18/figure_S18_added_connections_by_threshold.m')
```

## Repository check

The supplied S18 script was already consistent with the revised Supplementary Figure S18 caption and the historical graph-threshold workflow.

No core calculation was changed. The cleanup only adds:

1. an explicit `src/matlab/` existence check;
2. PRE/TEST sample-size consistency checks within each cohort;
3. an analysis-metadata CSV;
4. a complete MATLAB result file;
5. this README.
