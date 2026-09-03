# NoSeMaze tube-test and social-hierarchy preprocessing

Historical source code used the names **Autonomouse**, **AM1**, and **AM2**;
the public repository uses **NoSeMaze** consistently.

```text
NoSeMaze/
├── tubetest/     # raw combined CSV -> manually curated full_hierarchy_jr.mat
└── hierarchy/    # hierarchy -> David's score, rank, single chasing measure
```

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
manual include / exclude / invert curation
      ↓
full_hierarchy_jr.mat
      ↓
David's score / linear social rank
      ↓
optional single close-following/chasing hierarchy
```

Multiple/double chasing is intentionally excluded from the canonical public
pipeline.

## Canonical hierarchy windows used in this manuscript

```text
NoSeMaze 1 / scan group 1: days 3-16
NoSeMaze 1 / scan group 2: days 8-21
NoSeMaze 2:                days 1-14
```

Run, in order:

```matlab
run('preprocessing/NoSeMaze/tubetest/main_preprocessing_nosemaze_tubetest.m')
run('preprocessing/NoSeMaze/hierarchy/compute_hierarchy_NoSeMaze_1.m')
run('preprocessing/NoSeMaze/hierarchy/compute_hierarchy_NoSeMaze_2.m')
```

The tube-test README describes the two-pass manual-curation workflow in more
detail.
