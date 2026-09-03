# Figures

This directory contains the manuscript-facing reproduction scripts.

```text
figures/
├── main/
│   └── Figure_*/
└── supplement/
    └── Figure_S*/
```

Each computational figure folder contains its own:

```text
README.md
```

describing the panel mapping, required input data, dependencies, statistics, and output files.

## Navigation

Start with the repository-level:

[`FIGURE_MAP.md`](../FIGURE_MAP.md)

It links every main and supplementary figure to the corresponding figure folder and generated results.

## Design principle

Scripts in `figures/` should remain **thin reproduction entry points**.

Reusable preprocessing and general analysis code belongs under:

```text
src/
```

Generated material belongs under:

```text
results/
```

Figure folders should not contain historical `_old`, `_new`, `_final`, backup, or machine-specific copies of scripts.

## Schematic panels

Not every manuscript panel requires an independent statistical script. Experimental schematics, hardware illustrations, workflow diagrams, and final layout elements may be assembled separately.

Where this applies, the corresponding figure README identifies the panel as schematic/reference-only and links to the relevant upstream workflow if appropriate.
