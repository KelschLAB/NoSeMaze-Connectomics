# Network-Based Statistics (NBS)

NBS analyses in this project are **figure-specific**.

They are intentionally implemented in the corresponding manuscript figure
scripts rather than as a separate standalone `src` pipeline, because the
figure script contains the exact:

- input correlation matrices;
- within- or between-cohort design;
- contrast;
- NBS threshold/permutation settings;
- component extraction; and
- panel-specific plotting/export.

Accordingly, this directory is a documentation pointer only. Its presence
does **not** indicate that an additional NBS preprocessing stage is missing.

The NBS toolbox itself is retained under:

```text
src/matlab/preprocessing/toolboxes/NBS1.2/
```

For reproduction of an NBS result, start from the corresponding figure
script and the distributed derived correlation matrices.
