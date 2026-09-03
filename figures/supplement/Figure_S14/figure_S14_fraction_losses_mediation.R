# Supplementary Figure S14A-B:
# standalone mediation / moderated mediation
# fraction_losses -> deltaL_change -> fraction-loss-associated vHC BOLD

# ---------------- SETTINGS ----------------

get_script_file <- function() {
  # RStudio/source() and Rscript-compatible script discovery.
  ofile <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)

  if (!is.null(ofile) && nzchar(ofile)) {
    return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  }

  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)

  if (length(file_arg) > 0) {
    return(normalizePath(
      sub("^--file=", "", file_arg[1]),
      winslash = "/",
      mustWork = TRUE
    ))
  }

  stop(
    "Could not determine the script location. ",
    "Run the complete saved script via source() or Rscript."
  )
}

script_file <- get_script_file()
script_dir <- dirname(script_file)

# repo/figures/supplement/Figure_S14/figure_S14_fraction_losses_mediation.R
repo_root <- normalizePath(
  file.path(script_dir, "..", "..", ".."),
  winslash = "/",
  mustWork = TRUE
)

data_path <- file.path(
  repo_root, "data", "processed", "combined",
  "MediatorMediationData.xlsx"
)

out_dir <- file.path(
  repo_root, "results", "supplement",
  "Figure_S14", "Figure_S14A_B"
)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

sims_boot <- 1000   # same as Figure 6G-H
set.seed(123)

# ---------------- PACKAGES ----------------
pkgs <- c("readxl", "dplyr", "ggplot2", "mediation", "patchwork")
miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(miss)) {
  stop("Install missing packages: ", paste(miss, collapse = ", "))
}

library(readxl)
library(dplyr)
library(ggplot2)
library(mediation)
library(patchwork)

`%||%` <- function(x, y) if (is.null(x)) y else x

fmt_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < .001) return("<.001")
  paste0("=", sub("^0", "", sprintf("%.3f", p)))
}

# ---------------- LOAD / IDENTIFY COLUMNS ----------------
if (!file.exists(data_path)) stop("File not found: ", data_path)

raw <- read_excel(data_path)

# The historical NoSeMaze scripts use "fr_loser".
# Alternative names are accepted here to make the script robust to the
# exact column naming used in MediatorMediationData.xlsx.
iv_candidates <- c(
  "fraction_losses"
)

dv_candidates <- c(
  "vHC_BOLD_fraction_losses_T01"
)

pick_column <- function(candidates, available, label) {
  hit <- candidates[candidates %in% available]

  if (length(hit) == 0) {
    stop(
      "Could not find ", label, " column.\n",
      "Expected one of: ", paste(candidates, collapse = ", "), "\n",
      "Available columns are:\n", paste(available, collapse = ", ")
    )
  }

  if (length(hit) > 1) {
    message(
      "Multiple ", label, " columns found; using: ", hit[1]
    )
  }

  hit[1]
}

iv_col <- pick_column(
  iv_candidates,
  names(raw),
  "fraction-of-losses"
)

dv_col <- pick_column(
  dv_candidates,
  names(raw),
  "fraction-loss vHC BOLD"
)

med_col <- "deltaL_change"

if (!med_col %in% names(raw)) {
  stop("Missing mediator column: ", med_col)
}

message("Using IV column: ", iv_col)
message("Using mediator column: ", med_col)
message("Using DV column: ", dv_col)

# ---------------- PREP ----------------
d0 <- raw %>%
  dplyr::select(
    fraction_losses = dplyr::all_of(iv_col),
    deltaL_change = dplyr::all_of(med_col),
    vHC_BOLD = dplyr::all_of(dv_col)
  ) %>%
  mutate(across(everything(), ~ suppressWarnings(as.numeric(.x)))) %>%
  filter(complete.cases(.))

if (nrow(d0) < 10) stop("Fewer than 10 complete cases.")

# Standardized analysis variables, matching Figure 6G-H
d <- d0 %>%
  transmute(
    IV  = as.numeric(scale(fraction_losses)),
    MED = as.numeric(scale(deltaL_change)),
    DV  = as.numeric(scale(vHC_BOLD))
  )

N <- nrow(d)

# Save exact data used
write.csv(
  cbind(
    d0,
    fraction_losses_z = d$IV,
    deltaL_change_z = d$MED,
    vHC_BOLD_z = d$DV
  ),
  file.path(out_dir, "SourceData_Figure_S14A_B.csv"),
  row.names = FALSE
)

# ---------------- PATH MODELS ----------------
m_total <- lm(DV ~ IV, data = d)          # c
m_M     <- lm(MED ~ IV, data = d)         # a
m_Y     <- lm(DV ~ IV + MED, data = d)    # b, c'
m_int   <- lm(DV ~ IV * MED, data = d)    # moderated mediation

sm0 <- coef(summary(m_total))
smM <- coef(summary(m_M))
smY <- coef(summary(m_Y))

a      <- smM["IV",  "Estimate"]
a_p    <- smM["IV",  "Pr(>|t|)"]
b      <- smY["MED", "Estimate"]
b_p    <- smY["MED", "Pr(>|t|)"]
cpr    <- smY["IV",  "Estimate"]
cpr_p  <- smY["IV",  "Pr(>|t|)"]
ctot   <- sm0["IV",  "Estimate"]
ctot_p <- sm0["IV",  "Pr(>|t|)"]

# ---------------- FIGURE S14A: MEDIATION ----------------
set.seed(123)
med_a <- mediation::mediate(
  m_M, m_Y,
  treat = "IV",
  mediator = "MED",
  boot = TRUE,
  sims = sims_boot,
  boot.ci.type = "bca"
)

ACME    <- med_a$d.avg    %||% med_a$d0
ACME_ci <- med_a$d.avg.ci %||% med_a$d0.ci
ACME_p  <- med_a$d.avg.p  %||% med_a$d0.p
ADE     <- med_a$z.avg    %||% med_a$z0
ADE_p   <- med_a$z.avg.p  %||% med_a$z0.p
PROP    <- med_a$n.avg    %||% med_a$n0
PROP_p  <- med_a$n.avg.p  %||% med_a$n0.p

a_stats <- data.frame(
  effect = c(
    "a", "b", "c_prime", "c_total",
    "ACME", "ADE", "proportion_mediated"
  ),
  estimate = c(a, b, cpr, ctot, ACME, ADE, PROP),
  p = c(a_p, b_p, cpr_p, ctot_p, ACME_p, ADE_p, PROP_p),
  N = N
)

write.csv(
  a_stats,
  file.path(out_dir, "Statistics_Figure_S14A.csv"),
  row.names = FALSE
)

# ---------------- FIGURE S14B: MODERATED MEDIATION ----------------
# IV is standardized fraction of losses:
#   IV = -1 SD = lower fraction of losses
#   IV = +1 SD = higher fraction of losses
set.seed(123)
med_b <- mediation::mediate(
  m_M, m_int,
  treat = "IV",
  mediator = "MED",
  control.value = -1,
  treat.value = 1,
  boot = TRUE,
  sims = sims_boot
)

b_stats <- data.frame(
  Losses = c(
    "Lower fraction of losses\n(-1 SD)",
    "Higher fraction of losses\n(+1 SD)"
  ),
  ACME = c(med_b$d0, med_b$d1),
  CI_low = c(med_b$d0.ci[1], med_b$d1.ci[1]),
  CI_high = c(med_b$d0.ci[2], med_b$d1.ci[2]),
  p = c(med_b$d0.p, med_b$d1.p)
)

b_stats$Losses <- factor(
  b_stats$Losses,
  levels = c(
    "Lower fraction of losses\n(-1 SD)",
    "Higher fraction of losses\n(+1 SD)"
  )
)

b_stats$label <- paste0(
  "ACME = ", sprintf("%.2f", b_stats$ACME),
  "\np", vapply(b_stats$p, fmt_p, character(1))
)

write.csv(
  b_stats,
  file.path(out_dir, "Statistics_Figure_S14B.csv"),
  row.names = FALSE
)

# ---------------- METADATA ----------------

metadata <- data.frame(
  Panel = "Figure_S14A_B",
  IV_Source_Column = iv_col,
  Mediator_Source_Column = med_col,
  DV_Source_Column = dv_col,
  N = N,
  Bootstrap_Simulations = sims_boot,
  Random_Seed = 123,
  Standardized_IV = TRUE,
  Standardized_Mediator = TRUE,
  Standardized_DV = TRUE,
  stringsAsFactors = FALSE
)

write.csv(
  metadata,
  file.path(out_dir, "AnalysisMetadata_Figure_S14A_B.csv"),
  row.names = FALSE
)

# ---------------- PANEL A: PATH DIAGRAM ----------------
nodes <- data.frame(
  x = c(0, 1.5, 3),
  y = c(0, 1.15, 0),
  label = c(
    "Fraction of losses",
    "\u0394L adaptation",
    "vHC BOLD change"
  )
)

pA <- ggplot() +
  annotate(
    "segment",
    x = .28, y = .18, xend = 1.23, yend = .96,
    linewidth = .75,
    arrow = grid::arrow(length = grid::unit(.16, "cm"))
  ) +
  annotate(
    "segment",
    x = 1.77, y = .96, xend = 2.72, yend = .18,
    linewidth = .75,
    arrow = grid::arrow(length = grid::unit(.16, "cm"))
  ) +
  annotate(
    "segment",
    x = .35, y = -.04, xend = 2.65, yend = -.04,
    linewidth = .6,
    linetype = 2,
    arrow = grid::arrow(length = grid::unit(.16, "cm"))
  ) +
  geom_label(
    data = nodes,
    aes(x = x, y = y, label = label),
    size = 3.7,
    fill = "white",
    label.size = .4
  ) +
  annotate(
    "text",
    x = .62, y = .71,
    label = paste0(
      "a = ", sprintf("%.2f", a),
      "\np", fmt_p(a_p)
    ),
    size = 3.2
  ) +
  annotate(
    "text",
    x = 2.38, y = .71,
    label = paste0(
      "b = ", sprintf("%.2f", b),
      "\np", fmt_p(b_p)
    ),
    size = 3.2
  ) +
  annotate(
    "text",
    x = 1.5, y = -.26,
    label = paste0(
      "c' = ", sprintf("%.2f", cpr),
      "\np", fmt_p(cpr_p)
    ),
    size = 3.1
  ) +
  annotate(
    "label",
    x = 1.5, y = -.73,
    label = paste0(
      "Indirect effect (ACME) = ", sprintf("%.3f", ACME),
      ", p", fmt_p(ACME_p),
      "\nProportion mediated = ", sprintf("%.0f%%", 100 * PROP)
    ),
    size = 3.2,
    fill = "white",
    label.size = .3
  ) +
  coord_cartesian(
    xlim = c(-.5, 3.5),
    ylim = c(-1.05, 1.5),
    clip = "off"
  ) +
  labs(
    title = "a",
    subtitle = paste0(
      "Fraction of losses \u2192 \u0394L \u2192 vHC BOLD response (n = ",
      N, ")"
    )
  ) +
  theme_void(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 9.5),
    plot.margin = margin(8, 12, 8, 12)
  )

# ---------------- PANEL B: CONDITIONAL ACME ----------------
yr <- range(
  c(0, b_stats$CI_low, b_stats$CI_high),
  na.rm = TRUE
)

pad <- max(diff(yr) * .25, .12)

pB <- ggplot(b_stats, aes(x = Losses, y = ACME)) +
  geom_hline(
    yintercept = 0,
    linetype = 2,
    linewidth = .4
  ) +
  geom_errorbar(
    aes(ymin = CI_low, ymax = CI_high),
    width = .13,
    linewidth = .8
  ) +
  geom_point(size = 3.1) +
  geom_text(
    aes(
      y = CI_high + .08 * max(1, diff(yr)),
      label = label
    ),
    vjust = 0,
    size = 3.15,
    lineheight = 1.05
  ) +
  coord_cartesian(
    ylim = c(yr[1] - pad, yr[2] + 2 * pad),
    clip = "off"
  ) +
  labs(
    title = "b",
    subtitle = paste0(
      "Conditional indirect effect via \u0394L (n = ",
      N, ")"
    ),
    x = NULL,
    y = "Indirect effect (ACME)"
  ) +
  theme_classic(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 9.5),
    plot.margin = margin(8, 12, 8, 8)
  )

# ---------------- EXPORT ----------------
ggsave(
  file.path(out_dir, "Figure_S14A_mediation.pdf"),
  pA,
  width = 6.4,
  height = 4.7
)

ggsave(
  file.path(out_dir, "Figure_S14A_mediation.png"),
  pA,
  width = 6.4,
  height = 4.7,
  dpi = 600
)

ggsave(
  file.path(out_dir, "Figure_S14B_moderated_mediation.pdf"),
  pB,
  width = 4.8,
  height = 4.7
)

ggsave(
  file.path(out_dir, "Figure_S14B_moderated_mediation.png"),
  pB,
  width = 4.8,
  height = 4.7,
  dpi = 600
)

pAB <- pA | pB

ggsave(
  file.path(out_dir, "Figure_S14A_B_combined.pdf"),
  pAB,
  width = 11.2,
  height = 4.8
)

ggsave(
  file.path(out_dir, "Figure_S14A_B_combined.png"),
  pAB,
  width = 11.2,
  height = 4.8,
  dpi = 600
)

capture.output(
  summary(med_a),
  file = file.path(out_dir, "Statistics_Figure_S14A_mediation_full.txt")
)

capture.output(
  summary(med_b),
  file = file.path(out_dir, "Statistics_Figure_S14B_moderated_mediation_full.txt")
)

capture.output(
  sessionInfo(),
  file = file.path(out_dir, "sessionInfo.txt")
)


saveRDS(
  list(
    data = d,
    source_data = d0,
    models = list(
      total = m_total,
      mediator = m_M,
      outcome = m_Y,
      interaction = m_int
    ),
    mediation = med_a,
    moderated_mediation = med_b,
    metadata = metadata
  ),
  file.path(out_dir, "Results_Figure_S14A_B.rds")
)

# ---------------- CONSOLE CHECK ----------------
cat("\nSupplementary Figure S14A-B complete\n")
cat("IV column =", iv_col, "\n")
cat("DV column =", dv_col, "\n")
cat("N =", N, "\n")

cat(
  "A: ACME =", sprintf("%.3f", ACME),
  ", p", fmt_p(ACME_p),
  "; proportion mediated =", sprintf("%.1f%%", 100 * PROP), "\n"
)

cat(
  "B: lower fraction losses (-1 SD): ACME =",
  sprintf("%.3f", med_b$d0),
  ", p", fmt_p(med_b$d0.p), "\n"
)

cat(
  "B: higher fraction losses (+1 SD): ACME =",
  sprintf("%.3f", med_b$d1),
  ", p", fmt_p(med_b$d1.p), "\n"
)

cat("Saved to:", out_dir, "\n")
