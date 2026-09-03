# panel_G.R
# Jonathan Reinwald
#
# Reproduces Figure 1, panel G.
#
# This script is independent of the current R working directory.
#
# Input:
#   data/processed/NoSeMaze/tubetest/combined_dataset/
#     plot_data_sarah_21days.csv
#
# Output:
#   results/main/Figure_1/

# -------------------------------------------------------------------------
# Locate this script and repository root
# -------------------------------------------------------------------------

get_script_path <- function() {
  
  # Works when the file is executed with source(".../panel_G.R")
  frames <- sys.frames()
  
  for (i in rev(seq_along(frames))) {
    if (!is.null(frames[[i]]$ofile)) {
      return(normalizePath(
        frames[[i]]$ofile,
        winslash = "/",
        mustWork = TRUE
      ))
    }
  }
  
  stop(
    paste0(
      "Could not determine the location of panel_G.R.\n",
      "Run the script using source('.../panel_G.R') or from RStudio."
    )
  )
}

script_file <- get_script_path()
script_dir <- dirname(script_file)

# panel_G.R:
# repository/figures/main/Figure_1/panel_G.R
repo_root <- normalizePath(
  file.path(script_dir, "..", "..", ".."),
  winslash = "/",
  mustWork = TRUE
)

# -------------------------------------------------------------------------
# Packages
# -------------------------------------------------------------------------

required_packages <- c(
  "readr",
  "dplyr"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Missing required R package(s): ",
      paste(missing_packages, collapse = ", ")
    )
  )
}

library(readr)
library(dplyr)

# -------------------------------------------------------------------------
# Source plotting helper
# -------------------------------------------------------------------------

helper_file <- file.path(
  repo_root,
  "src",
  "R",
  "plotting",
  "plot_stability_measures_tube.R"
)

if (!file.exists(helper_file)) {
  stop(
    paste0(
      "Required plotting helper not found:\n",
      helper_file
    )
  )
}

source(helper_file)

# -------------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------------

data_file <- file.path(
  repo_root,
  "data",
  "processed",
  "NoSeMaze",
  "tubetest",
  "combined_dataset",
  "plot_data_sarah_21days.csv"
)

output_directory <- file.path(
  repo_root,
  "results",
  "main",
  "Figure_1"
)

output_file_prefix <- file.path(
  output_directory,
  "Figure_1G_hierarchy_characteristics"
)

script_name <- "Script: figures/main/Figure_1/panel_G.R"

if (!file.exists(data_file)) {
  stop(
    paste0(
      "Required input file not found:\n",
      data_file
    )
  )
}

dir.create(
  output_directory,
  recursive = TRUE,
  showWarnings = FALSE
)

# -------------------------------------------------------------------------
# Load data
# -------------------------------------------------------------------------

data_to_plot <- read_csv(
  data_file,
  show_col_types = FALSE
)

vars <- c(
  "steepness",
  "transitivity_pt",
  "stabilityIndex",
  "uncertainty_rep"
)

required_columns <- c(
  "cohort",
  vars
)

missing_columns <- setdiff(
  required_columns,
  names(data_to_plot)
)

if (length(missing_columns) > 0) {
  stop(
    paste0(
      "Missing required column(s): ",
      paste(missing_columns, collapse = ", ")
    )
  )
}

# Preserve cohort order from the processed input file
cohort_levels <- unique(
  na.omit(as.character(data_to_plot$cohort))
)

if (length(cohort_levels) < 2) {
  stop("At least two cohorts are required.")
}

data_to_plot <- data_to_plot %>%
  mutate(
    cohort = factor(
      as.character(cohort),
      levels = cohort_levels
    )
  )

# -------------------------------------------------------------------------
# Cohort colors
# -------------------------------------------------------------------------

# Reference cohorts are grey. The final two cohorts in the processed
# dataset correspond to the two NoSeMaze cohorts and are highlighted.
cohort_colors <- setNames(
  rep("grey70", length(cohort_levels)),
  cohort_levels
)

cohort_colors[length(cohort_colors) - 1] <- "#FF4C4C"
cohort_colors[length(cohort_colors)] <- "#CC0000"

# -------------------------------------------------------------------------
# Plot and save
# -------------------------------------------------------------------------

plots <- generate_variable_boxplots(
  data_to_plot,
  vars,
  cohort_colors
)

save_combined_plots(
  plots,
  data_to_plot,
  output_file_prefix,
  script_name
)

message(
  "\nFigure 1G output saved to:\n",
  output_directory
)
