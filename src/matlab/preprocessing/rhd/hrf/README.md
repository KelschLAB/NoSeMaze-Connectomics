# HRF cohort: protocol/RHD preprocessing

Primary entry point:

```text
main_preprocess_protocol_hrf.m
```

The final protocol parser is included under:

```text
functions/process_protocol__hrf.m
```

The historical HRF task run used:

```text
nVolume = 8200
```

Raw RHD/protocol files are non-public and configured through the HRF module
configuration/environment variables.

## External Intan reader

RHD conversion relies on the historical Intan-reader functions:

```text
BundleSession.m
LengthRhd.m
IntanImport.m
```

These functions are not scientifically reimplemented in this repository.
Users with access to the raw RHD data must add the compatible Intan reader to
the MATLAB path before running the RHD conversion stage.
