# Figure map

This file is the top-level navigation guide for **NoSeMaze-Connectomics**.

All computational figure scripts are organized under `figures/`, and the corresponding scripts have been run to generate outputs under `results/`. Each figure folder contains its own `README.md` with exact panel definitions, required inputs, dependencies, analysis settings, and output files.

Use this file for orientation; use the figure-specific `README.md` for reproduction details.

## Repository convention

```text
figures/
├── main/
│   └── Figure_X/
│       ├── README.md
│       └── panel / figure scripts
└── supplement/
    └── Figure_SX/
        ├── README.md
        └── panel / figure scripts

results/
├── main/
│   └── Figure_X/
└── supplement/
    └── Figure_SX/
```

The `results/` tree contains generated figures, source-data tables, statistics, metadata, and result objects where produced by the corresponding scripts.

---

# Main figures

| Figure | Main content | Reproduction code | Generated outputs |
|---|---|---|---|
| **Figure 1** | Experimental design, NoSeMaze hierarchy, David's score / social rank | [`figures/main/Figure_1/`](figures/main/Figure_1/) — computational panels include `panel_E_F.m` and `panel_G.R`; see figure README | [`results/main/Figure_1/`](results/main/Figure_1/) |
| **Figure 2** | Eyelid-conditioned responses, baseline odor BOLD, BOLD time courses | [`figures/main/Figure_2/`](figures/main/Figure_2/) — `panel_B.m`, `panel_B_statistics.R`, `panel_C.m`, `panel_C_statistics.R`, `panel_D_mricrogl.py`, `panel_E.m` | [`results/main/Figure_2/`](results/main/Figure_2/) |
| **Figure 3** | Proximal-CR functional connectivity, paired FC changes, NBS, mean positive FC | [`figures/main/Figure_3/`](figures/main/Figure_3/) — see figure README for panel-specific MATLAB scripts | [`results/main/Figure_3/`](results/main/Figure_3/) |
| **Figure 4** | Local and global graph adaptation in conditioning vs control cohorts | [`figures/main/Figure_4/`](figures/main/Figure_4/) — includes `panel_A_localGA_histograms.m`; see figure README for remaining panels | [`results/main/Figure_4/`](results/main/Figure_4/) |
| **Figure 5** | Social rank, wins/losses, and global graph adaptation | [`figures/main/Figure_5/`](figures/main/Figure_5/) — includes `panel_A_B_D_globalGA_social_hierarchy.m`; see figure README for panel C | [`results/main/Figure_5/`](results/main/Figure_5/) |
| **Figure 6** | Social rank, vHC recall BOLD, subordination, ΔL adaptation, mediation | [`figures/main/Figure_6/`](figures/main/Figure_6/) — MRIcroGL, MATLAB, and R panel scripts; see figure README | [`results/main/Figure_6/`](results/main/Figure_6/) |

### Notes on schematic panels

Not every manuscript panel is produced de novo by an analysis script. Experimental schematics, conceptual illustrations, and final layout elements may be assembled outside the analysis pipeline. The figure-specific README identifies which panels are computationally reproduced.

---

# Supplementary figures

| Figure | Main content | Reproduction code | Generated outputs |
|---|---|---|---|
| **Figure S1** | Extended eyelid-conditioning analyses and control cohort | [`figures/supplement/Figure_S1/`](figures/supplement/Figure_S1/) — MATLAB/R eyelid scripts; see README | [`results/supplement/Figure_S1/`](results/supplement/Figure_S1/) |
| **Figure S2** | No-puff control BOLD / olfactory time courses | [`figures/supplement/Figure_S2/`](figures/supplement/Figure_S2/) — `panel_A_mricrogl.py`, `panel_B_OB_AON_timecourses_control.m` | [`results/supplement/Figure_S2/`](results/supplement/Figure_S2/) |
| **Figure S3** | Study-specific mouse HRF | [`figures/supplement/Figure_S3/`](figures/supplement/Figure_S3/) — `panel_A_mricrogl.py`, `panel_B_HRF_comparison.m` | [`results/supplement/Figure_S3/`](results/supplement/Figure_S3/) |
| **Figure S4** | Proximal-CR FC / local graph metric detail | [`figures/supplement/Figure_S4/`](figures/supplement/Figure_S4/) — `panel_A_conditioning_TMatrix.m`, `panel_B_control_TMatrix.m`, `panel_C_local_graph_metrics_conditioning.m`, `panel_D_local_graph_metrics_control.m` | [`results/supplement/Figure_S4/`](results/supplement/Figure_S4/) |
| **Figure S5** | Distal-CR FC, NBS, and mean FC | [`figures/supplement/Figure_S5/`](figures/supplement/Figure_S5/) — `panel_A_conditioning.m`, `panel_A_control.m`, `panel_B_Odor_NBS_control_vs_conditioning.m`, `panel_C_meanFC_Odor.m` | [`results/supplement/Figure_S5/`](results/supplement/Figure_S5/) |
| **Figure S6** | Global graph metrics across 10–50% sparsity thresholds | [`figures/supplement/Figure_S6/`](figures/supplement/Figure_S6/) — `figure_S6_global_metrics_thresholds.m` | [`results/supplement/Figure_S6/`](results/supplement/Figure_S6/) |
| **Figure S7** | Distal-CR local/global graph metrics | [`figures/supplement/Figure_S7/`](figures/supplement/Figure_S7/) — `panel_A_localGA_odor_task_vs_control.m`, `panel_B_C_global_graph_metrics_odor.m` | [`results/supplement/Figure_S7/`](results/supplement/Figure_S7/) |
| **Figure S8** | Rank assignments, week-to-week hierarchy stability, fraction of wins vs graph adaptation | [`figures/supplement/Figure_S8/`](figures/supplement/Figure_S8/) — `panel_A_social_rank_by_animal.m`, `panel_B_C_week1_week2_rank_DS.m`, `panel_D_E_fr_winner_globalGA.m` | [`results/supplement/Figure_S8/`](results/supplement/Figure_S8/) |
| **Figure S9** | Rank / David's score and graph-metric threshold robustness | [`figures/supplement/Figure_S9/`](figures/supplement/Figure_S9/) — `figure_S9_rank_graphmetrics_threshold_robustness.m` | [`results/supplement/Figure_S9/`](results/supplement/Figure_S9/) |
| **Figure S10** | Social rank and distal-CR global graph adaptation | [`figures/supplement/Figure_S10/`](figures/supplement/Figure_S10/) — `panel_A_B_rank_globalGA_distalCR.m` | [`results/supplement/Figure_S10/`](results/supplement/Figure_S10/) |
| **Figure S11** | vHC BOLD rank association at alternative cluster-defining thresholds | [`figures/supplement/Figure_S11/`](figures/supplement/Figure_S11/) — `panel_A_rank_vHC_BOLD.m`, `panel_B_rank_vHC_BOLD.m` | [`results/supplement/Figure_S11/`](results/supplement/Figure_S11/) |
| **Figure S12** | Spatial robustness maps for rank / David's score vHC effects | [`figures/supplement/Figure_S12/`](figures/supplement/Figure_S12/) — MRIcroGL scripts `panel_A_mricrogl_S12A.py`–`panel_D_mricrogl_S12D.py` | [`results/supplement/Figure_S12/`](results/supplement/Figure_S12/) |
| **Figure S13** | ΔC-associated vHC map and extracted BOLD association | [`figures/supplement/Figure_S13/`](figures/supplement/Figure_S13/) — `panel_A_mricrogl_S13A.py`, `panel_B_deltaC_BOLD.m` | [`results/supplement/Figure_S13/`](results/supplement/Figure_S13/) |
| **Figure S14** | Fraction-of-losses mediation / moderated mediation | [`figures/supplement/Figure_S14/`](figures/supplement/Figure_S14/) — `figure_S14_fraction_losses_mediation.R` | [`results/supplement/Figure_S14/`](results/supplement/Figure_S14/) |
| **Figure S15** | NoSeMaze / experimental hardware and workflow details | [`figures/supplement/Figure_S15/`](figures/supplement/Figure_S15/) if retained for figure assets / README | No independent statistical analysis output required |
| **Figure S16** | fMRI preprocessing and motion-control analyses | [`figures/supplement/Figure_S16/`](figures/supplement/Figure_S16/) — `panel_B_motion_parameters.m`, `panel_C_dvars_fd_correlations.m`; S16A points to the canonical preprocessing pipeline under `src/matlab/preprocessing/fmri/reappraisal/` | [`results/supplement/Figure_S16/`](results/supplement/Figure_S16/) |
| **Figure S17** | First-level GLM / nuisance-regressor specification | [`figures/supplement/Figure_S17/`](figures/supplement/Figure_S17/) if retained for schematic / README; executable GLM workflow lives under `src/matlab/` | No independent figure-statistics output required |
| **Figure S18** | FC values of connections added across 5% density increments | [`figures/supplement/Figure_S18/`](figures/supplement/Figure_S18/) — `figure_S18_added_connections_by_threshold.m` | [`results/supplement/Figure_S18/`](results/supplement/Figure_S18/) |
| **Figure S19** | Threshold-dependent FC matrix comparisons | [`figures/supplement/Figure_S19/`](figures/supplement/Figure_S19/) — `figure_S19_threshold_matrix_comparison.m` | [`results/supplement/Figure_S19/`](results/supplement/Figure_S19/) |

---

# Upstream analysis pipelines

The figure scripts are intentionally thin reproduction entry points. Reusable preprocessing and analysis code belongs under `src/`.

Important upstream modules include preprocessing, GLM, HRF, BASCO / functional connectivity, graph analysis, hierarchy processing, eyelid processing, and shared helpers.

### fMRI preprocessing

The canonical reappraisal-cohort preprocessing entry point is:

```text
src/matlab/preprocessing/fmri/reappraisal/
└── main_preprocessing_fmri_reappraisal.m
```

This pipeline produces the processed fMRI inputs used by the GLM, functional-connectivity, graph-analysis, and motion-control workflows.

---

# Reproduction status

At the time of the final repository cleanup:

- figure-specific scripts have been converted to repository-relative paths;
- each computational figure folder contains a `README.md`;
- the figure scripts have been run;
- generated outputs are stored under the corresponding `results/main/` or `results/supplement/` directory;
- reusable preprocessing / analysis functions are kept under `src/`, not duplicated in `figures/`;
- MRIcroGL panels retain a single manually editable `repo_root` because MRIcroGL's embedded Python environment cannot reliably infer the script location.

For exact inputs, model definitions, statistical tests, helper functions, and output filenames, open the `README.md` in the corresponding figure folder.
