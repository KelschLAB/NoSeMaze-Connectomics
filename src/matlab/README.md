# MATLAB preprocessing and analysis code

This directory contains the preprocessing and analysis code supporting the
**NoSeMaze-Connectomics** manuscript.

## Data-availability boundary

Raw MRI, RHD, video, and large intermediate processed datasets are not
distributed in this repository because they remain in use for ongoing
analyses and additional manuscripts.

The code therefore has two purposes:

1. document the preprocessing and analysis workflow used for the private raw data;
2. provide canonical analysis entry points for the processed/source data used by the public figure scripts.

Figure reproduction starts from the repository-level `FIGURE_MAP.md` and the
`README.md` inside each folder under `figures/`.

## Pipeline overview

```text
private raw data
│
├── NoSeMaze logs ──> tube-test extraction / hierarchy
├── RHD files ──────> task/event timing
├── eyelid data ────> DLC-based eyelid preprocessing
└── Bruker MRI ─────> fMRI preprocessing
                         │
                         v
                    HRF estimation
                         │
                         v
                    voxelwise GLM
                         │
                         v
                  BASCO beta-series FC
                         │
                         v
                    graph analysis
                         │
                         v
                      figures/
```

## Directory structure

```text
matlab/
├── preprocessing/
│   ├── NoSeMaze/
│   ├── eyelid/
│   ├── rhd/
│   ├── fmri/
│   ├── helpers/
│   └── toolboxes/
├── analysis/
│   └── fmri/
│       ├── hrf_estimation/
│       ├── glm/
│       ├── functional_connectivity/
│       └── graph_analysis/
└── helpers/
```

## Canonical preprocessing entry points

| Purpose | Entry point | Public status |
|---|---|---|
| NoSeMaze tube-test preprocessing | `preprocessing/NoSeMaze/tubetest/main_preprocessing_nosemaze_tubetest.m` | requires input/raw log data |
| NoSeMaze hierarchy 1 | `preprocessing/NoSeMaze/hierarchy/compute_hierarchy_NoSeMaze_1.m` | final prescan windows days 3-16 and 8-21 |
| NoSeMaze hierarchy 2 | `preprocessing/NoSeMaze/hierarchy/compute_hierarchy_NoSeMaze_2.m` | final prescan window days 1-14 |
| Eyelid DLC preprocessing | `preprocessing/eyelid/main_preprocess_eyelid_dlc.m` | requires private/video-derived inputs |
| Reappraisal RHD | `preprocessing/rhd/reappraisal/main_preprocess_rhd_reappraisal.m` | requires private RHD data + historical Intan reader |
| HRF RHD | `preprocessing/rhd/hrf/main_preprocess_protocol_hrf.m` | requires private RHD/protocol data + historical Intan reader |
| Eyelid RHD | `preprocessing/rhd/eyelid/main_preprocess_rhd_eyelid.m` | requires private RHD data + historical Intan reader |
| Reappraisal fMRI | `preprocessing/fmri/reappraisal/main_preprocessing_fmri_reappraisal.m` | workflow/provenance master for private MRI data |
| Control fMRI | `preprocessing/fmri/control/main_preprocessing_fmri_control.m` | workflow/provenance master for private MRI data |
| HRF fMRI | `preprocessing/fmri/hrf/main_preprocessing_fmri_hrf.m` | preprocessing entry point for private MRI data |

The reappraisal/control fMRI masters intentionally keep all processing-stage
switches disabled because the non-public raw acquisition tree and historical
execution environment are not distributed. They document the exact ordered
workflow and dependencies; downstream analysis scripts use the processed
inputs.

## Canonical analysis entry points

| Purpose | Entry point |
|---|---|
| HRF residual GLM | `analysis/fmri/hrf_estimation/main_residual_glm_hrf.m` |
| HRF time-course extraction | `analysis/fmri/hrf_estimation/main_extract_hrf_timecourses.m` |
| HRF fitting | `analysis/fmri/hrf_estimation/main_hrf_estimation.m` |
| Reappraisal first-level GLM | `analysis/fmri/glm/reappraisal/main_glm_reappraisal.m` |
| Social-hierarchy second-level GLMs | `analysis/fmri/glm/reappraisal/main_secondlevel_social_hierarchy_reappraisal.m` |
| Graph-derived ΔL second-level GLM | `analysis/fmri/glm/reappraisal/main_secondlevel_graph_covariates_reappraisal.m` |
| Control first-level GLM | `analysis/fmri/glm/control/main_glm_control.m` |
| HRF mask GLM | `analysis/fmri/glm/hrf/main_glm_hrf_mask.m` |
| Reappraisal BASCO FC | `analysis/fmri/functional_connectivity/basco/reappraisal/main_fc_basco_reappraisal.m` |
| Control BASCO FC | `analysis/fmri/functional_connectivity/basco/control/main_fc_basco_control.m` |
| Reappraisal graph metrics | `analysis/fmri/graph_analysis/reappraisal/main_graph_analysis_reappraisal.m` |
| Control graph metrics | `analysis/fmri/graph_analysis/control/main_graph_analysis_control.m` |

## MATLAB path handling

Do **not** recursively add the complete `src/matlab` tree to the MATLAB path.
The repository contains third-party toolboxes and multiple HRF implementations
with overlapping function names. Run the relevant module-specific `main_*`
script, which adds only the dependencies required for that analysis.

## Private/external inputs

Machine-specific raw-data roots are supplied through module configuration and
environment variables. Important examples are:

```text
NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT
NOSEMAZE_CONTROL_FMRI_RAW_ROOT
NOSEMAZE_REAPPRAISAL_FMRI_PROCESSED_ROOT
NOSEMAZE_REAPPRAISAL_RHD_ROOT
NOSEMAZE_REAPPRAISAL_GRAPH_AUC_ROOT
NOSEMAZE_DARTEL_AFFINE_TPM
```

The Intan RHD conversion additionally requires the historical reader functions
`BundleSession`, `LengthRhd`, and `IntanImport`; these are treated as an
external data-reader dependency rather than silently reimplemented.

## Two analysis-provenance points that remain explicit

- Eyelid DLC preprocessing keeps the historically executed likelihood
  threshold of **0.80**. The current manuscript text should be checked if it
  still states 0.95.
- HRF mask selection keeps the executed top-fraction setting documented in
  the HRF module. The Methods text should match the executed setting.

These are scientific provenance choices and should not be changed merely for
code cleanup.
