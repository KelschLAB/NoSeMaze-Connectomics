# Figure 1

This folder contains the scripts required to reproduce the data-driven panels of Figure 1.

## Panels E–F

Run:

```matlab
panel_E_F
```

Input data:

```text
data/processed/NoSeMaze/tubetest/NoSeMaze_1/
data/processed/NoSeMaze/tubetest/NoSeMaze_2/
```

The script reproduces the hierarchy-score and hierarchy-graph panels for both NoSeMaze cohorts and exports the corresponding source-data CSV files.

Outputs:

```text
results/main/Figure_1/
```

## Panel G

Run:

```r
source("figures/main/Figure_1/panel_G.R")
```

Input:

```text
data/processed/NoSeMaze/tubetest/combined_dataset/plot_data_sarah_21days.csv
```

The plotting functions are provided in:

```text
src/R/plotting/plot_stability_measures_tube.R
```

Outputs:

```text
results/main/Figure_1/
```
