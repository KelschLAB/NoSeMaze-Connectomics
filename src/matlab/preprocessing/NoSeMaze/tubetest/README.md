# NoSeMaze tube-test preprocessing

Run:

```matlab
main_preprocessing_nosemaze_tubetest
```

The preprocessing has four stages:

1. **Combined CSV → daily LOG files**  
   `convert_csv_to_LOG.m`

2. **Daily LOG files → extracted competitions and QC plots**  
   `extract_tube_tests_from_LOG_clean.m`  
   `plot_tube_test_events.m`

3. **Manual event curation**  
   inspect event plots and create optional:
   `include_events.mat`, `exclude_events.mat`, `invert_events.mat`

4. **Curated daily files → `full_hierarchy_jr.mat`**  
   `combine_curated_tube_days.m`

For the first pass:

```matlab
runStage.convertCsvToLog = true;
runStage.findAndPlotEvents = true;
runStage.combineCuratedData = false;
```

After manual curation:

```matlab
runStage.convertCsvToLog = false;
runStage.findAndPlotEvents = false;
runStage.combineCuratedData = true;
```

Hierarchy calculation runs afterwards from `../hierarchy/`.

Multiple/double chasing is intentionally not included.
