# Supplementary Figure S14

Script used to reproduce Supplementary Figure S14, which repeats the Figure 6 mediation framework using **fraction of losses** as the independent variable.

The manuscript states that equivalent mediation and moderated-mediation effects were obtained when fraction of losses replaced social rank as the independent variable, supporting the interpretation that the pathway is driven by subordination experience.

## Script

```text
figure_S14_fraction_losses_mediation.R
```

## Panels

| Panel | Analysis |
|---|---|
| S14A | Mediation: fraction of losses → ΔL adaptation → vHC BOLD |
| S14B | Moderated mediation: conditional indirect effect at lower vs higher fraction of losses |

Outputs are written to:

```text
results/supplement/Figure_S14/Figure_S14A_B/
```

## Input

```text
data/processed/combined/
└── MediatorMediationData.xlsx
```

Required source columns:

```text
fraction_losses
deltaL_change
vHC_BOLD_fraction_losses_T01
```

The corrected script keeps the actual BOLD source-column name explicit. The supplied script searched for:

```text
vHC_BOLD_fraction_losses_T01
```

but then silently renamed it internally to:

```text
vHC_BOLD_fraction_losses_T001
```

That was potentially misleading. The repository version now uses the neutral internal alias:

```text
vHC_BOLD
```

while exporting the exact source-column name in the metadata.

## Standardization

Complete cases are selected first. The three analysis variables are then standardized:

```text
IV  = z(fraction_losses)
MED = z(deltaL_change)
DV  = z(vHC_BOLD)
```

The script stops if fewer than 10 complete cases remain.

## Figure S14A — mediation

Models:

```r
m_total <- lm(DV ~ IV)
m_M     <- lm(MED ~ IV)
m_Y     <- lm(DV ~ IV + MED)
```

Thus:

```text
a      = IV → mediator
b      = mediator → DV controlling for IV
c'     = direct IV → DV effect controlling for mediator
c      = total IV → DV effect
```

The indirect effect is estimated with `mediation::mediate`:

```r
mediate(
  m_M,
  m_Y,
  treat = "IV",
  mediator = "MED",
  boot = TRUE,
  sims = 1000,
  boot.ci.type = "bca"
)
```

Reported outputs include:

```text
ACME
ADE
proportion mediated
a, b, c', c path coefficients
```

## Figure S14B — moderated mediation

The outcome model includes an IV × mediator interaction:

```r
m_int <- lm(DV ~ IV * MED)
```

Conditional indirect effects are probed for:

```text
IV = -1 SD  → lower fraction of losses
IV = +1 SD  → higher fraction of losses
```

using:

```r
mediate(
  m_M,
  m_int,
  treat = "IV",
  mediator = "MED",
  control.value = -1,
  treat.value = 1,
  boot = TRUE,
  sims = 1000
)
```

S14B displays the corresponding ACME estimates with bootstrap confidence intervals and p-values.

## Reproducibility settings

```text
bootstrap simulations = 1000
random seed           = 123
```

These match the Figure 6G-H mediation script.

## R dependencies

```text
readxl
dplyr
ggplot2
mediation
patchwork
```

The script checks for missing packages and stops with a clear installation message.

## Repository-root handling

Unlike the supplied version, the corrected script does not contain a hard-coded Windows repository path.

It determines its own script location and derives:

```text
repo_root
```

from:

```text
figures/supplement/Figure_S14/
```

The helper supports both:

```text
source(...)
Rscript ...
```

## Outputs

The script exports:

```text
SourceData_Figure_S14A_B.csv
Statistics_Figure_S14A.csv
Statistics_Figure_S14B.csv
AnalysisMetadata_Figure_S14A_B.csv
Statistics_Figure_S14A_mediation_full.txt
Statistics_Figure_S14B_moderated_mediation_full.txt
Results_Figure_S14A_B.rds
sessionInfo.txt

Figure_S14A_mediation.pdf
Figure_S14A_mediation.png
Figure_S14B_moderated_mediation.pdf
Figure_S14B_moderated_mediation.png
Figure_S14A_B_combined.pdf
Figure_S14A_B_combined.png
```

## Running

From R:

```r
source("figures/supplement/Figure_S14/figure_S14_fraction_losses_mediation.R")
```

or:

```bash
Rscript figures/supplement/Figure_S14/figure_S14_fraction_losses_mediation.R
```

## Repository check

The mediation logic itself matches the Figure 6G-H structure: standardized IV/mediator/DV variables, 1,000 bootstrap simulations, and the same mediation/moderated-mediation framework.

The substantive cleanup is therefore limited to:

1. removing the hard-coded repository path;
2. fixing the `T01` → `T001` relabeling inconsistency;
3. standardizing output filenames;
4. adding metadata and a complete `.rds` result object.
