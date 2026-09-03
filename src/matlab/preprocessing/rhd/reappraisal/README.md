# Reappraisal RHD / task-timing preprocessing

The fMRI task timing was reconstructed from synchronized Intan RHD
recordings containing scanner triggers, olfactometer TTLs, and air-puff TTLs.

Run:

```matlab
main_preprocess_rhd_reappraisal
```

The cleaned wrapper expects protocol MAT files under:

```text
data/raw/RHD/reappraisal/protocol_files/
```

RHD files can either be stored under:

```text
data/raw/RHD/reappraisal/rhd_files/
```

or supplied externally via:

```text
NOSEMAZE_REAPPRAISAL_RHD_ROOT
```

Outputs are written to:

```text
data/processed/RHD/reappraisal/processed_protocol_files/
```

The scientific timing logic is retained in:

```text
functions/process_protocol_reappraisal.m
```

`RhdToMat_lw.m` is included. Raw RHD conversion additionally requires the compatible historical Intan-reader functions listed below.

## External Intan reader

Raw `.rhd` conversion requires the historical `BundleSession`, `LengthRhd`, and `IntanImport` functions. These are treated as an external reader dependency and are not reimplemented in the public repository.
