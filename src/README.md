# Source code

This directory contains reusable preprocessing and analysis code that sits upstream of the manuscript-facing figure scripts.

The current public codebase is MATLAB-centered:

```text
src/
└── matlab/
    ├── README.md
    ├── preprocessing/
    ├── analysis/
    └── helpers/
```

For the detailed workflow, data-availability boundary, dependency handling, and canonical preprocessing/analysis entry points, see:

[`matlab/README.md`](matlab/README.md)

## Relationship to figure scripts

```text
src/       reusable preprocessing / analysis
   ↓
data/      processed/source figure inputs
   ↓
figures/   manuscript-facing reproduction scripts
   ↓
results/   generated outputs
```

Figure scripts should not duplicate general-purpose upstream pipelines from `src/`.
