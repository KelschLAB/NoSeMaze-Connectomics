# BASCO analysis definition

The executable BASCO model definition is:

```text
anadef_reappraisal.m
```

It reproduces the historical configuration without absolute paths or
interactive metainfo selection.

Key settings:

```text
VoxelAnalysis       true
ROIAnalysis         false
TR                  1.2 s
fmri_t              22
fmri_t0             1
HRFDERIVS           [0 0]
MotionReg           true
CSFReg              true
DerivReg            true
GlobalMeanReg       false
SpecMask            mask_template_6_polished.nii
conditions          Lavender, TP Puff, TP NoPuff
```
