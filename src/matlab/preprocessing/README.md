# Preprocessing

This directory contains the preprocessing code used for the
**NoSeMaze-Connectomics** manuscript.

Raw recordings are not distributed publicly. The preprocessing source is
included for methodological transparency and to document how the private raw
recordings were transformed into the processed inputs used by the analysis
and figure scripts.

```text
preprocessing/
├── NoSeMaze/     # RFID tube-test logs and hierarchy measures
├── eyelid/       # DeepLabCut eyelid geometry / video synchronization
├── rhd/          # Intan task/event timing
├── fmri/         # MRI preprocessing by cohort
├── helpers/
└── toolboxes/
```

See the `README.md` inside each module for its input/output conventions and
runtime dependencies.

Large intermediate products and raw MRI/RHD/video data may be supplied from
private storage through the environment variables documented in the
corresponding config/README files.
