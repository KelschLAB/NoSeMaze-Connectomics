# Preprocessing

This directory documents the preprocessing used for the
NoSeMaze-Connectomics manuscript.

## Scope

Raw recordings are not distributed publicly. The preprocessing code is
included for methodological transparency and provenance. Processed inputs
required by the manuscript's figure scripts are stored separately under
`data/processed/`.

Planned preprocessing modules:

```text
src/matlab/preprocessing/
├── README.md
├── helpers/
├── nosemaze/
│   ├── tubetest/
│   └── hierarchy/
├── eyelid/
├── rhd/
└── fmri/
```

# NoSeMaze tube-test / social-hierarchy preprocessing

## Data flow

```text
combined raw CSV
      ↓
daily LOG_YYYY-MM-DD.mat
      ↓
automatic tube-competition extraction
      ↓
event-level QC plots + daily hierarchy_data
      ↓
MANUAL CURATION
(include / exclude / invert)
      ↓
full_hierarchy_jr.mat
      ↓
David's score / linear social rank
      ↓
optional single close-following/chasing hierarchy
```

Multiple/double chasing is intentionally excluded from the cleaned public
pipeline.

## Raw data layout

Preferred:

```text
data/raw/NoSeMaze/
├── NoSeMaze_1/
│   └── AT1_experiment_live_log_since_2020-07-08_combined.csv
└── NoSeMaze_2/
    └── AT2_experiment_live_log_since_2020-07-08_combined.csv
```

For compatibility, the code also accepts the historical local layout:

```text
data/raw/NoSeMaze/<group>/tube/<combined CSV>
```

## Interim data layout

```text
data/interim/NoSeMaze/<group>/tube/LOG-files/
├── LOG_YYYY-MM-DD.mat
└── plots/
    ├── LOG_YYYY-MM-DD/
    │   ├── Data.mat
    │   └── event-QC PNG files
    ├── include_events.mat
    ├── exclude_events.mat
    └── invert_events.mat
```

## Processed data layout

```text
data/processed/NoSeMaze/tubetest/
├── NoSeMaze_1/
│   ├── full_hierarchy_jr.mat
│   └── full_hierarchy_withChasing_jr.mat
└── NoSeMaze_2/
    ├── full_hierarchy_jr.mat
    └── full_hierarchy_withChasing_jr.mat
```

## Running the preprocessing

Run:

```matlab
src/matlab/preprocessing/nosemaze/tubetest/
main_preprocessing_nosemaze_tubetest.m
```

The script determines the repository root automatically.

### First pass

```matlab
runStage.convertCsvToLog = true;
runStage.findAndPlotEvents = true;
runStage.combineCuratedData = false;
```

This generates the daily logs, extracts putative competitions, and writes
QC plots.

### Manual curation

Inspect the QC plots and define the optional event lists:

```text
include_events.mat   variable: include
exclude_events.mat   variable: exclude
invert_events.mat    variable: invert
```

### Second pass

```matlab
runStage.convertCsvToLog = false;
runStage.findAndPlotEvents = false;
runStage.combineCuratedData = true;
```

This produces `full_hierarchy_jr.mat`.

If an existing historical `full_hierarchy_jr.mat` is already present, the
master can compare the recomputed day-wise match matrices against it before
overwriting.

## Hierarchy calculation

After preprocessing, run:

```matlab
compute_hierarchy_NoSeMaze_1
compute_hierarchy_NoSeMaze_2
```

The NoSeMaze 1 script includes the two later-introduced RFIDs explicitly
instead of relying on fragile numeric matrix indices.

The NoSeMaze 2 historical day window still needs one final confirmation
before repository freeze; the earlier genuine NoSeMaze 2 script used
days 5-14.

## Included helper functions

The public preprocessing is now self-contained for Stages 1-4. In
particular, the formerly missing functions are included:

```text
extract_tube_tests_from_LOG_clean.m
plot_tube_test_events.m
```

The historical per-day `compute_DS.m` call was removed because its output
was not used by the downstream cumulative hierarchy calculation.

Optional hierarchy plotting functions such as
`plot_David_score_in_group.m` are not required for the numerical analysis.
