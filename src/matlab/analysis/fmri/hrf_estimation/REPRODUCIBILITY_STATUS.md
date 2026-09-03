
# HRF estimation reproducibility status

## Code-complete from processed HRF EPI + processed protocol onward

The repository now contains:

- v1 odor-regressor creation;
- v1 14-column nuisance construction;
- the first-level odor-mask GLM and `Odors_combined` contrast;
- individual odor-mask creation;
- nuisance-only residual GLM;
- residual concatenation;
- ROI time-course extraction;
- high-resolution HRF objective;
- multi-start `fminsearch`;
- final session-wise fit aggregation.

## Raw-preprocessing status

The HRF-specific field-map and slice-time helpers that were previously
missing are now included:

```text
wwf_correct_fm_pos.m
wwf_FieldMap_miceCF_jr.m
wwf_appl_fieldmapCF.m
do_slice_time_hrf_jr.m
```

Together with the shared preprocessing functions already present in `src`,
the manuscript-relevant HRF raw-MRI preprocessing code is now covered.

Public raw-to-processed execution still requires the original non-distributed
Bruker MRI and RHD/protocol data. Disabled exploratory/QC branches from the
historical master may reference additional legacy utilities, but those are
not part of the primary HRF derivation.

## One unresolved scientific provenance issue

The individual-mask source comment says "top 5%", while its executed
threshold expression selects approximately the top 1%.

The active code defaults to 1% to reproduce the historical expression and
flags this discrepancy explicitly.
