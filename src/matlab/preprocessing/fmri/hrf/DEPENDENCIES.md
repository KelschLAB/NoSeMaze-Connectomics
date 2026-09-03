# HRF preprocessing dependencies

## HRF-specific helpers

```text
wwf_correct_fm_pos.m
wwf_FieldMap_miceCF_jr.m
wwf_appl_fieldmapCF.m
do_slice_time_hrf_jr.m
```

## Shared fMRI preprocessing helpers

The HRF pipeline reuses project functions from the reappraisal preprocessing
module, including conversion, dummy-volume removal, realignment/unwarping,
brain extraction, template alignment, DARTEL, reslicing, smoothing,
intensity normalization, and wavelet despiking.

`do_smooth_lw` supports the HRF cohort's 0.5-mm (`s5_`) smoothing branch.

The DARTEL affine-reference mouse TPM is supplied with `job.tpm` or:

```text
NOSEMAZE_DARTEL_AFFINE_TPM
```

## External requirements

```text
MATLAB
SPM12 including FieldMap
private HRF Bruker MRI acquisitions
```
