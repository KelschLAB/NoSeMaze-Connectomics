# panel_G_H.R
#
# Figure 6G-H: mediation / moderated mediation
#
# social_rank -> deltaL_change -> vHC_BOLD_social_rank_T001
#
# The repository root is determined from this script's location so that
# the script can be sourced from any working directory or RStudio project.

# -------------------------------------------------------------------------
# Identify repository root from this script
# -------------------------------------------------------------------------

get_script_file <- function() {
  
  frame_files <- vapply(
    sys.frames(),
    function(frame) {
      if (!is.null(frame$ofile)) {
        as.character(frame$ofile)
      } else {
        NA_character_
      }
    },
    FUN.VALUE = character(1)
  )
  
  frame_files <- frame_files[!is.na(frame_files)]
  
  if (length(frame_files) > 0) {
    return(
      normalizePath(
        tail(frame_files, 1),
        winslash = "/",
        mustWork = TRUE
      )
    )
  }
  
  command_args <- commandArgs(
    trailingOnly = FALSE
  )
  
  file_argument <- grep(
    "^--file=",
    command_args,
    value = TRUE
  )
  
  if (length(file_argument) > 0) {
    return(
      normalizePath(
        sub("^--file=", "", file_argument[1]),
        winslash = "/",
        mustWork = TRUE
      )
    )
  }
  
  stop(
    paste0(
      "Could not determine the location of panel_G_H.R.\n\n",
      "Run the script using source('path/to/panel_G_H.R') ",
      "or with Rscript."
    ),
    call. = FALSE
  )
}

script_file <- get_script_file()
script_directory <- dirname(script_file)

# Script location:
# NoSeMaze-Connectomics/figures/main/Figure_6/panel_G_H.R
repo_root <- normalizePath(
  file.path(
    script_directory,
    "../../.."
  ),
  winslash = "/",
  mustWork = TRUE
)

message(
  "Repository root:\n",
  repo_root
)

# -------------------------------------------------------------------------
# Settings
# -------------------------------------------------------------------------

data_path <- file.path(
  repo_root,
  "data",
  "processed",
  "combined",
  "MediatorMediationData.xlsx"
)

out_dir <- file.path(
  repo_root,
  "results",
  "main",
  "Figure_6",
  "Figure_6G_H"
)

dir.create(
  out_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

sims_boot <- 1000
random_seed <- 123

# -------------------------------------------------------------------------
# Packages
# -------------------------------------------------------------------------

pkgs <- c(
  "readxl",
  "dplyr",
  "ggplot2",
  "mediation",
  "patchwork"
)

miss <- pkgs[
  !vapply(
    pkgs,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(miss) > 0) {
  stop(
    paste0(
      "The following required R packages are not installed:\n",
      paste(miss, collapse = ", "),
      "\n\nInstall them once using:\n",
      "install.packages(c(",
      paste0('"', miss, '"', collapse = ", "),
      "))"
    ),
    call. = FALSE
  )
}

library(readxl)
library(dplyr)
library(ggplot2)
library(mediation)
library(patchwork)

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

fmt_p <- function(p) {
  
  if (is.na(p)) {
    return("NA")
  }
  
  if (p < .001) {
    return("<.001")
  }
  
  paste0(
    "=",
    sub(
      "^0",
      "",
      sprintf("%.3f", p)
    )
  )
}

# -------------------------------------------------------------------------
# Load and prepare data
# -------------------------------------------------------------------------

if (!file.exists(data_path)) {
  stop(
    paste0(
      "Required input file not found:\n",
      data_path
    ),
    call. = FALSE
  )
}

raw <- readxl::read_excel(
  data_path
)

required <- c(
  "social_rank",
  "deltaL_change",
  "vHC_BOLD_social_rank_T001"
)

missing_columns <- setdiff(
  required,
  names(raw)
)

if (length(missing_columns) > 0) {
  stop(
    paste0(
      "The following required columns are missing:\n",
      paste(missing_columns, collapse = ", ")
    ),
    call. = FALSE
  )
}

d0 <- raw %>%
  dplyr::select(
    dplyr::all_of(required)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      dplyr::everything(),
      ~ suppressWarnings(as.numeric(.x))
    )
  ) %>%
  dplyr::filter(
    complete.cases(.)
  )

if (nrow(d0) < 10) {
  stop(
    "Fewer than 10 complete cases remain after data cleaning.",
    call. = FALSE
  )
}

# Standardized variables, matching the original analysis.
d <- d0 %>%
  dplyr::transmute(
    IV = as.numeric(scale(social_rank)),
    MED = as.numeric(scale(deltaL_change)),
    DV = as.numeric(scale(vHC_BOLD_social_rank_T001))
  )

N <- nrow(d)

# Save the exact analysis data.
utils::write.csv(
  cbind(
    d0,
    social_rank_z = d$IV,
    deltaL_change_z = d$MED,
    vHC_BOLD_social_rank_T001_z = d$DV
  ),
  file.path(
    out_dir,
    "Figure_6_G_H_source_data.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Path models
# -------------------------------------------------------------------------

m_total <- lm(
  DV ~ IV,
  data = d
)

m_M <- lm(
  MED ~ IV,
  data = d
)

m_Y <- lm(
  DV ~ IV + MED,
  data = d
)

m_int <- lm(
  DV ~ IV * MED,
  data = d
)

sm0 <- coef(summary(m_total))
smM <- coef(summary(m_M))
smY <- coef(summary(m_Y))

a <- smM["IV", "Estimate"]
a_p <- smM["IV", "Pr(>|t|)"]

b <- smY["MED", "Estimate"]
b_p <- smY["MED", "Pr(>|t|)"]

cpr <- smY["IV", "Estimate"]
cpr_p <- smY["IV", "Pr(>|t|)"]

ctot <- sm0["IV", "Estimate"]
ctot_p <- sm0["IV", "Pr(>|t|)"]

# -------------------------------------------------------------------------
# Figure 6G: mediation
# -------------------------------------------------------------------------

set.seed(random_seed)

med_g <- mediation::mediate(
  m_M,
  m_Y,
  treat = "IV",
  mediator = "MED",
  boot = TRUE,
  sims = sims_boot,
  boot.ci.type = "bca"
)

ACME <- med_g$d.avg %||% med_g$d0
ACME_ci <- med_g$d.avg.ci %||% med_g$d0.ci
ACME_p <- med_g$d.avg.p %||% med_g$d0.p

ADE <- med_g$z.avg %||% med_g$z0
ADE_p <- med_g$z.avg.p %||% med_g$z0.p

PROP <- med_g$n.avg %||% med_g$n0
PROP_p <- med_g$n.avg.p %||% med_g$n0.p

g_stats <- data.frame(
  effect = c(
    "a",
    "b",
    "c_prime",
    "c_total",
    "ACME",
    "ADE",
    "proportion_mediated"
  ),
  estimate = c(
    a,
    b,
    cpr,
    ctot,
    ACME,
    ADE,
    PROP
  ),
  p = c(
    a_p,
    b_p,
    cpr_p,
    ctot_p,
    ACME_p,
    ADE_p,
    PROP_p
  ),
  N = N
)

utils::write.csv(
  g_stats,
  file.path(
    out_dir,
    "Figure_6g_statistics.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Figure 6H: moderated mediation
# -------------------------------------------------------------------------

# Lower numeric rank = higher social rank:
#   IV = -1 SD = HIGH rank
#   IV = +1 SD = LOW rank

set.seed(random_seed)

med_h <- mediation::mediate(
  m_M,
  m_int,
  treat = "IV",
  mediator = "MED",
  control.value = -1,
  treat.value = 1,
  boot = TRUE,
  sims = sims_boot
)

h_stats <- data.frame(
  Rank = c(
    "High rank\n(-1 SD)",
    "Low rank\n(+1 SD)"
  ),
  ACME = c(
    med_h$d0,
    med_h$d1
  ),
  CI_low = c(
    med_h$d0.ci[1],
    med_h$d1.ci[1]
  ),
  CI_high = c(
    med_h$d0.ci[2],
    med_h$d1.ci[2]
  ),
  p = c(
    med_h$d0.p,
    med_h$d1.p
  )
)

h_stats$Rank <- factor(
  h_stats$Rank,
  levels = c(
    "High rank\n(-1 SD)",
    "Low rank\n(+1 SD)"
  )
)

h_stats$label <- paste0(
  "ACME = ",
  sprintf("%.2f", h_stats$ACME),
  "\np",
  vapply(
    h_stats$p,
    fmt_p,
    character(1)
  )
)

utils::write.csv(
  h_stats,
  file.path(
    out_dir,
    "Figure_6h_statistics.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Panel G: path diagram
# -------------------------------------------------------------------------

nodes <- data.frame(
  x = c(0, 1.5, 3),
  y = c(0, 1.15, 0),
  label = c(
    "Social rank",
    "\u0394L adaptation",
    "vHC BOLD change"
  )
)

pG <- ggplot2::ggplot() +
  ggplot2::annotate(
    "segment",
    x = .28,
    y = .18,
    xend = 1.23,
    yend = .96,
    linewidth = .75,
    arrow = grid::arrow(
      length = grid::unit(.16, "cm")
    )
  ) +
  ggplot2::annotate(
    "segment",
    x = 1.77,
    y = .96,
    xend = 2.72,
    yend = .18,
    linewidth = .75,
    arrow = grid::arrow(
      length = grid::unit(.16, "cm")
    )
  ) +
  ggplot2::annotate(
    "segment",
    x = .35,
    y = -.04,
    xend = 2.65,
    yend = -.04,
    linewidth = .6,
    linetype = 2,
    arrow = grid::arrow(
      length = grid::unit(.16, "cm")
    )
  ) +
  ggplot2::geom_label(
    data = nodes,
    ggplot2::aes(
      x = x,
      y = y,
      label = label
    ),
    size = 3.7,
    fill = "white",
    label.size = .4
  ) +
  ggplot2::annotate(
    "text",
    x = .62,
    y = .71,
    label = paste0(
      "a = ",
      sprintf("%.2f", a),
      "\np",
      fmt_p(a_p)
    ),
    size = 3.2
  ) +
  ggplot2::annotate(
    "text",
    x = 2.38,
    y = .71,
    label = paste0(
      "b = ",
      sprintf("%.2f", b),
      "\np",
      fmt_p(b_p)
    ),
    size = 3.2
  ) +
  ggplot2::annotate(
    "text",
    x = 1.5,
    y = -.26,
    label = paste0(
      "c' = ",
      sprintf("%.2f", cpr),
      "\np",
      fmt_p(cpr_p)
    ),
    size = 3.1
  ) +
  ggplot2::annotate(
    "label",
    x = 1.5,
    y = -.73,
    label = paste0(
      "Indirect effect (ACME) = ",
      sprintf("%.3f", ACME),
      ", p",
      fmt_p(ACME_p),
      "\nProportion mediated = ",
      sprintf("%.0f%%", 100 * PROP)
    ),
    size = 3.2,
    fill = "white",
    label.size = .3
  ) +
  ggplot2::coord_cartesian(
    xlim = c(-.5, 3.5),
    ylim = c(-1.05, 1.5),
    clip = "off"
  ) +
  ggplot2::labs(
    title = "g",
    subtitle = paste0(
      "Social rank \u2192 \u0394L \u2192 vHC BOLD response (n = ",
      N,
      ")"
    )
  ) +
  ggplot2::theme_void(
    base_size = 11
  ) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 14
    ),
    plot.subtitle = ggplot2::element_text(
      size = 9.5
    ),
    plot.margin = ggplot2::margin(
      8,
      12,
      8,
      12
    )
  )

# -------------------------------------------------------------------------
# Panel H: conditional ACME
# -------------------------------------------------------------------------

yr <- range(
  c(
    0,
    h_stats$CI_low,
    h_stats$CI_high
  ),
  na.rm = TRUE
)

pad <- max(
  diff(yr) * .25,
  .12
)

pH <- ggplot2::ggplot(
  h_stats,
  ggplot2::aes(
    x = Rank,
    y = ACME
  )
) +
  ggplot2::geom_hline(
    yintercept = 0,
    linetype = 2,
    linewidth = .4
  ) +
  ggplot2::geom_errorbar(
    ggplot2::aes(
      ymin = CI_low,
      ymax = CI_high
    ),
    width = .13,
    linewidth = .8
  ) +
  ggplot2::geom_point(
    size = 3.1
  ) +
  ggplot2::geom_text(
    ggplot2::aes(
      y = CI_high + .08 * max(1, diff(yr)),
      label = label
    ),
    vjust = 0,
    size = 3.15,
    lineheight = 1.05
  ) +
  ggplot2::coord_cartesian(
    ylim = c(
      yr[1] - pad,
      yr[2] + 2 * pad
    ),
    clip = "off"
  ) +
  ggplot2::labs(
    title = "h",
    subtitle = paste0(
      "Conditional indirect effect via \u0394L (n = ",
      N,
      ")"
    ),
    x = NULL,
    y = "Indirect effect (ACME)"
  ) +
  ggplot2::theme_classic(
    base_size = 11
  ) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 14
    ),
    plot.subtitle = ggplot2::element_text(
      size = 9.5
    ),
    plot.margin = ggplot2::margin(
      8,
      12,
      8,
      8
    )
  )

# -------------------------------------------------------------------------
# Export
# -------------------------------------------------------------------------

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6g_mediation.pdf"
  ),
  pG,
  width = 6.4,
  height = 4.7
)

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6g_mediation.png"
  ),
  pG,
  width = 6.4,
  height = 4.7,
  dpi = 600
)

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6h_moderated_mediation.pdf"
  ),
  pH,
  width = 4.8,
  height = 4.7
)

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6h_moderated_mediation.png"
  ),
  pH,
  width = 4.8,
  height = 4.7,
  dpi = 600
)

pGH <- pG | pH

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6_G_H_combined.pdf"
  ),
  pGH,
  width = 11.2,
  height = 4.8
)

ggplot2::ggsave(
  file.path(
    out_dir,
    "Figure_6_G_H_combined.png"
  ),
  pGH,
  width = 11.2,
  height = 4.8,
  dpi = 600
)

capture.output(
  summary(med_g),
  file = file.path(
    out_dir,
    "Figure_6g_mediation_full.txt"
  )
)

capture.output(
  summary(med_h),
  file = file.path(
    out_dir,
    "Figure_6h_moderated_mediation_full.txt"
  )
)

capture.output(
  sessionInfo(),
  file = file.path(
    out_dir,
    "sessionInfo.txt"
  )
)

# -------------------------------------------------------------------------
# Console check
# -------------------------------------------------------------------------

cat("\nFigure 6G-H complete\n")
cat("N =", N, "\n")

cat(
  "G: ACME =",
  sprintf("%.3f", ACME),
  ", p",
  fmt_p(ACME_p),
  "; proportion mediated =",
  sprintf("%.1f%%", 100 * PROP),
  "\n"
)

cat(
  "H: high rank (-1 SD): ACME =",
  sprintf("%.3f", med_h$d0),
  ", p",
  fmt_p(med_h$d0.p),
  "\n"
)

cat(
  "H: low rank (+1 SD): ACME =",
  sprintf("%.3f", med_h$d1),
  ", p",
  fmt_p(med_h$d1.p),
  "\n"
)

cat(
  "Saved to:",
  out_dir,
  "\n"
)
