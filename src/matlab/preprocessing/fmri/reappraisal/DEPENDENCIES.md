# Reappraisal fMRI preprocessing dependencies

## Project functions

The manuscript workflow uses repository functions for:

```text
Bruker conversion / reorientation      do_pvconv_jr
remove dummy volumes                   wwf_del_vol
field-map processing                   wwf_FieldMap_rat_jr
field-map filling                      fieldmap_fill_dilate_jr
realignment / unwarping                do_unwarp_jr
slice timing                           do_slice_time_reappraisal_jr
functional → anatomical coregistration do_coreg_func23d_lw
brain extraction                       ms_do_brainExtraction
template alignment                     do_shift_auto_brain_TwoPfunc_jr
                                       do_coreg_all2temp_2func_jr
bias correction                        wwf_do_bias_jr
segmentation                           jr_do_segmentation
DARTEL                                 jr_do_DARTEL_inital_import
                                       jr_do_DARTEL_create_templates
                                       spm_dartel_norm_fun_mice_jr
reslicing                              do_reslice
smoothing                              do_smooth_lw
intensity normalization                intensity_normalization
motion mitigation                      WaveletDespike
```

The DARTEL affine-reference mouse TPM is supplied with `job.tpm` or the
environment variable `NOSEMAZE_DARTEL_AFFINE_TPM`.

## External software

```text
MATLAB
SPM12
AFNI 3dDespike
Wavelet Despiking toolbox (repository-local copy)
```

The public raw-data master is primarily a workflow/provenance description;
full raw-to-processed execution additionally requires access to the private
Bruker acquisition tree.
