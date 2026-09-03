# Scanlist audit

File: `scanlist_reappraisal_jr.csv`

- Total acquisition rows: **271**
- Unique Subject IDs: **24**
- Core preprocessing scan types: **6**
- Core rows: **144**

Core acquisition counts:

- `EPI_RS`: 24
- `EPI_reappraisal`: 24
- `Fieldmap_1`: 24
- `Fieldmap_2`: 24
- `Fieldmap_3`: 24
- `TurboRARE3D`: 24

Each of the 24 subjects has exactly one row for every core scan type.

The remaining rows correspond to localizers, EPI tests, field-map test
acquisitions, scanner adjustments, or rows without a final Examination
label. They are retained in the original CSV for provenance but ignored by
the core preprocessing manifest.
