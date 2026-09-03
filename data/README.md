# Data

This directory contains the **processed/source inputs and reference resources** required by the public manuscript figure scripts.

Raw MRI acquisitions, raw RHD recordings, original eyelid videos, and large intermediate processed datasets are not distributed here because they remain in active use for ongoing analyses and additional manuscripts.

## Principle

The exact input files required for a manuscript panel are documented in the corresponding figure README under:

```text
figures/main/Figure_*/
figures/supplement/Figure_S*/
```

Use the repository-level [`FIGURE_MAP.md`](../FIGURE_MAP.md) to navigate from a manuscript figure to its required inputs.

## Main data categories

The repository may contain processed/source inputs under categories such as:

```text
data/
├── processed/
│   ├── NoSeMaze/
│   ├── eyelid/
│   ├── fMRI/
│   └── combined/
└── reference/
    └── templates/
```

The exact tree is analysis-specific and is described in each figure/module README.

## Processed versus private data

`data/processed/` contains derived inputs that are sufficiently compact and manuscript-specific for public reproduction.

The upstream code showing how those data were generated is available under:

```text
src/matlab/
```

Private raw/acquisition data are intentionally outside the public repository.

## Do not edit figure inputs in place

Where possible, treat files under `data/` as immutable analysis inputs. Figure scripts should write generated material to:

```text
results/
```

rather than modifying the source data.
