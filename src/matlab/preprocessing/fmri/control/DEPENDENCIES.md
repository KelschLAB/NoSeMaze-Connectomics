# Control fMRI preprocessing dependencies

The control workflow reuses the shared reappraisal preprocessing functions
and adds control-specific field-map handling.

Core project functions include:

```text
wwf_del_vol
fieldmap_fill_dilate_jr
wwf_fix_fm_offset
wwf_appl_fieldmap_reappraisal_control_2023_jr
do_unwarp_jr
do_slice_time_reappraisal_jr
do_coreg_func23d_lw
ms_do_brainExtraction
do_shift_auto_brain_TwoPfunc_jr
do_coreg_all2temp_2func_jr
wwf_do_bias_jr
jr_do_segmentation
jr_do_DARTEL_inital_import
jr_do_DARTEL_create_templates
spm_dartel_norm_fun_mice_jr
do_reslice
do_smooth_lw
WaveletDespike
```

External software:

```text
MATLAB
SPM12
AFNI 3dDespike
```

The exact historical conversion helper `wwf_reform_bruker3.m` and historical
`intensity_normalization_by100.m` are not substituted silently in the public
workflow. Full raw-to-processed recreation therefore requires the original
private acquisition environment in addition to the code distributed here.
