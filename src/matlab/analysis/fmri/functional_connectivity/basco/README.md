# BASCO beta-series functional connectivity

BASCO estimates voxelwise trial-specific beta images. ROI beta series and
Pearson connectivity matrices are derived afterward using the study's merged
Allen atlas.

```text
basco/
├── common/functions/
├── reappraisal/
└── control/
```

Primary reappraisal settings:

```text
unsmoothed task EPI
v19 trial-wise event model
v11 BASCO analysis
52 merged anatomical ROIs
```

The BASCO toolbox remains under:

```text
src/matlab/preprocessing/toolboxes/BASCO/
```

SPM12 remains external.
