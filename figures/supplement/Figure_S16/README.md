# Supplementary Figure S16

Scripts and repository entry points used for Supplementary Figure S16, which documents the fMRI preprocessing and motion-control analyses.

The manuscript describes:

```text
S16A   preprocessing workflow
S16B   summary of head-motion parameters / framewise displacement
S16C   DVARS–FD correlations across preprocessing strategies
```

The preprocessing workflow itself belongs under `src/`, whereas the quantitative reviewer-facing panels S16B-C are reproduced from the scripts in this figure folder.

## Files

| Panel | Analysis | Repository entry point |
|---|---|---|
| S16A | fMRI preprocessing workflow | `src/matlab/preprocessing/fmri/reappraisal/main_preprocessing_fmri_reappraisal.m` |
| S16B | motion parameters and framewise displacement | `panel_B_motion_parameters.m` |
| S16C | subject-wise DVARS–FD correlations | `panel_C_dvars_fd_correlations.m` |

Outputs from the figure scripts are written under:

```text
results/supplement/Figure_S16/
├── Figure_S16B/
└── Figure_S16C/
```

## Figure S16A — preprocessing workflow

S16A is a schematic/overview of the preprocessing pipeline rather than a separate statistical figure script.

The canonical executable preprocessing entry point is:

```text
src/matlab/preprocessing/fmri/reappraisal/
└── main_preprocessing_fmri_reappraisal.m
```

The repository preprocessing workflow includes, in order:

```text
1. Bruker/ParaVision conversion, scaling and reorientation
2. removal of first 5 EPI volumes
3. AFNI 3dDespike
4. field-map preparation and distortion correction
5. SPM realignment/unwarping
6. slice-time correction
7. EPI-to-anatomical coregistration
8. anatomical brain extraction
9. alignment to Paxinos-space template
10. bias correction / tissue segmentation
11. DARTEL template creation and normalization
12. output branches:
      unsmoothed normalized EPI for FC/graph analyses
      0.6 mm FWHM for primary voxelwise BOLD analyses
      0.4 mm FWHM robustness analysis
13. masking / intensity normalization
14. wavelet despiking
```

External dependencies include SPM12 and AFNI. Repository-local preprocessing functions/toolboxes are loaded by the preprocessing master itself.

---

## Figure S16B — motion parameters

Script:

```text
panel_B_motion_parameters.m
```

Input root:

```text
data/processed/fMRI/preprocessing/reappraisal/
├── ZI_M13/
│   └── motion/
│       └── rp_despiked_del*.txt
├── ZI_M14/
│   └── motion/
│       └── rp_despiked_del*.txt
└── ...
```

Each animal must have exactly one canonical despiked motion-parameter file. The script preferentially searches for:

```text
rp_despiked_del5*.txt
```

and falls back to:

```text
rp_despiked_del*.txt
```

### Motion processing

For each animal:

```text
1. load six realignment parameters
2. quadratic detrending of each parameter
3. calculate SNiP framewise displacement
4. divide translation columns 1–3 by 10 after FD calculation
5. calculate frame-to-frame changes in the corrected motion parameters
6. summarize mean absolute motion per animal
7. summarize mean FD per animal
```

The ordering is deliberate: FD is calculated from the detrended original realignment parameters **before** the post-hoc translation scaling used for the motion-parameter display.

Displayed quantities:

```text
translation: right, forward, up
rotation:    pitch, roll, yaw
FD
```

The manuscript reports low-to-moderate motion in the conditioning cohort, with mean FD approximately 0.0374 mm (SEM 0.0032 mm). The script exports the observed values rather than hard-coding this result.

Required helpers:

```text
SNiP_framewise_displacement.m
notBoxPlot.m
```

Run:

```matlab
run('figures/supplement/Figure_S16/panel_B_motion_parameters.m')
```

Outputs include:

```text
SourceData_Figure_S16B_MotionParameters.csv
Statistics_Figure_S16B_MotionParameters.csv
AnalysisMetadata_Figure_S16B_MotionParameters.csv
Results_Figure_S16B_MotionParameters.mat
Figure_S16B_MotionParameters.pdf
Figure_S16B_MotionParameters.png
```

---

## Figure S16C — DVARS versus framewise displacement

Script:

```text
panel_C_dvars_fd_correlations.m
```

Input:

```text
data/processed/fMRI/preprocessing/reappraisal/model_selection/
└── DVARS_info.mat
```

Required variable:

```text
DVARS_info
```

with fields:

```text
DVARS_info.Nothing.DVARS
DVARS_info.Nothing.FD_SNiP

DVARS_info.AFNI.DVARS
DVARS_info.AFNI.FD_SNiP

DVARS_info.WD10_AFNI.DVARS
DVARS_info.WD10_AFNI.FD_SNiP
```

The three retained preprocessing strategies are:

```text
Nothing
AFNI
WD10_AFNI
```

where `WD10_AFNI` represents the wavelet-despiking + AFNI branch used to demonstrate reduced motion-related contamination.

### Correlation calculation

For each preprocessing strategy, the script calculates a Pearson DVARS–FD correlation separately for every animal.

The historical calculation is retained:

```matlab
correlationMatrix = corr( ...
    dvarsMatrix', ...
    fdMatrix', ...
    'Type','Pearson', ...
    'Rows','pairwise' ...
);

subjectCorrelations = diag(correlationMatrix);
```

Given matrices organized as:

```text
subjects × time points
```

the transpose makes subjects the variables in `corr`; extracting the diagonal therefore returns each animal's own DVARS–FD correlation.

The script uses:

```matlab
FD_SNiP(:,2:end)
```

to align FD with DVARS after the initial frame.

The manuscript describes a marked reduction of DVARS–FD correlation after wavelet despiking.

Required helper:

```text
notBoxPlot.m
```

Run:

```matlab
run('figures/supplement/Figure_S16/panel_C_dvars_fd_correlations.m')
```

Outputs include:

```text
SourceData_Figure_S16C_DVARS_FD_Correlations.csv
Statistics_Figure_S16C_DVARS_FD_Correlations.csv
AnalysisMetadata_Figure_S16C_DVARS_FD_Correlations.csv
Results_Figure_S16C_DVARS_FD_Correlations.mat
Figure_S16C_DVARS_FD_Correlations.pdf
Figure_S16C_DVARS_FD_Correlations.png
Figure_S16C_DVARS_FD_Correlations.fig
```

## MATLAB setup

Both figure scripts derive the repository root from their own script location and load helpers recursively from:

```text
src/matlab/
```

The corrected versions explicitly stop if that directory is missing.

Optional provenance helper:

```text
docDataSrc.m
```

## Repository check

The supplied S16B and S16C analyses were already internally consistent.

No motion calculation or DVARS–FD statistic was changed. The cleanup only adds:

1. explicit `src/matlab/` existence checks;
2. per-panel `AnalysisMetadata_*.csv` exports;
3. this README linking S16A to the canonical preprocessing master rather than duplicating preprocessing logic inside `figures/`.
