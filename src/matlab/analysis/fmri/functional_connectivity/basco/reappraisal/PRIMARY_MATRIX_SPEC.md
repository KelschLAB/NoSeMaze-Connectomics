# Primary BASCO v11 matrix specification

The manuscript describes **10 whole-brain Pearson correlation matrices per
subject**, computed from beta series at the distal and proximal conditioned
response (CR) time points.

The primary repository names are:

| CR | Experimental segment | Historical v11 suffix |
|---|---|---|
| distal | pre, trials 1–10 | `Odor1to10` |
| distal | pre, trials 11–40 | `Odor11to40` |
| distal | pairing, no-puff trials | `Odor_TPNoPuff` |
| distal | pairing, puff trials | `Odor_TPPuff` |
| distal | test, trials 81–120 | `Odor81to120` |
| proximal | pre, trials 1–10 | `TPnoPuff1to10` |
| proximal | pre, trials 11–40 | `TPnoPuff11to40` |
| proximal | pairing, no-puff trials | `TPnoPuff41to80` |
| proximal | pairing, puff trials | `TP-Puff` |
| proximal | test, trials 81–120 | `TPnoPuff81to120` |

These names are consistent with the historical `cormat_v11` outputs and the
final Supplementary Methods.

Older scripts also created convenience series such as `Odor1to40`,
`Odor81to110`, and `TPnoPuff1to40`. They are not required for the primary
10-matrix manuscript FC analysis and are disabled by default.
