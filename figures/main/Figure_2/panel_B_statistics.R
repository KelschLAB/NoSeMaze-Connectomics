# panel_B_statistics.R
# Jonathan Reinwald
#
# Statistical analysis for Figure 2B:
# Eyelid response during conditioning block 1 versus block 3
# at two prespecified time windows.
#
# Expected repository structure:
#
# NoSeMaze-Connectomics/
# ├── figures/main/Figure_2/panel_B_statistics.R
# ├── data/processed/eyelid/reappraisal/
# │   ├── Mean_LidData_R_TP1.xlsx
# │   │   NOTE: Derived from time bins 22-31 (0.1-1.1 s after odor onset)
# │   │   from:
# │   │   results/main/Figure_2/SourceData_Figure2B_Block1_ConditioningCohort.csv
# │   │   results/main/Figure_2/SourceData_Figure2B_Block3_ConditioningCohort.csv
# │   │
# │   └── Mean_LidData_R_TP2.xlsx
# │       NOTE: Derived from time bins 46-55 (2.5-3.5 s after odor onset)
# │       from:
# │       results/main/Figure_2/SourceData_Figure2B_Block1_ConditioningCohort.csv
# │       results/main/Figure_2/SourceData_Figure2B_Block3_ConditioningCohort.csv
# └── results/main/Figure_2/statistics/

rm(list = ls())

# -------------------------------------------------------------------------
# Identify repository root from this script
# -------------------------------------------------------------------------

get_script_file <- function() {
  
  # When the script is run with source(), the path is stored in `ofile`
  # in one of the active call frames.
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
  
  # Fallback for execution with Rscript.
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
      "Could not determine the location of panel_B_statistics.R.\n\n",
      "Run the script using source('path/to/panel_B_statistics.R') ",
      "or with Rscript."
    ),
    call. = FALSE
  )
}

script_file <- get_script_file()
script_directory <- dirname(script_file)

# panel_B_statistics.R is located in:
# figures/main/Figure_2/
#
# Therefore, moving three levels upward gives the repository root.
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
# Check required packages
# -------------------------------------------------------------------------

required_packages <- c(
  "readxl",
  "lme4",
  "predictmeans"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    quietly = TRUE,
    FUN.VALUE = logical(1)
  )
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "The following required R packages are not installed:\n",
      paste(missing_packages, collapse = ", "),
      "\n\nInstall them once using:\n",
      "install.packages(c(",
      paste0('"', missing_packages, '"', collapse = ", "),
      "))"
    ),
    call. = FALSE
  )
}

# -------------------------------------------------------------------------
# Define input and output paths
# -------------------------------------------------------------------------

data_directory <- file.path(
  repo_root,
  "data",
  "processed",
  "eyelid",
  "reappraisal"
)

tp1_file <- file.path(
  data_directory,
  "Mean_LidData_R_TP1.xlsx"
)

tp2_file <- file.path(
  data_directory,
  "Mean_LidData_R_TP2.xlsx"
)

output_directory <- file.path(
  repo_root,
  "results",
  "main",
  "Figure_2",
  "statistics"
)

dir.create(
  output_directory,
  recursive = TRUE,
  showWarnings = FALSE
)

# -------------------------------------------------------------------------
# Check input files
# -------------------------------------------------------------------------

input_files <- c(
  TP1 = tp1_file,
  TP2 = tp2_file
)

missing_files <- input_files[
  !file.exists(input_files)
]

if (length(missing_files) > 0) {
  stop(
    paste0(
      "The following required input files were not found:\n\n",
      paste(missing_files, collapse = "\n"),
      "\n\nExpected repository folder:\n",
      "data/processed/eyelid/reappraisal/"
    ),
    call. = FALSE
  )
}

# -------------------------------------------------------------------------
# Function: load and prepare one time-point dataset
# -------------------------------------------------------------------------

prepare_lid_data <- function(file_path) {
  
  data <- readxl::read_excel(
    file_path
  )
  
  required_columns <- c(
    "lid",
    "block",
    "animal_ID"
  )
  
  missing_columns <- setdiff(
    required_columns,
    names(data)
  )
  
  if (length(missing_columns) > 0) {
    stop(
      paste0(
        "The following columns are missing from ",
        basename(file_path),
        ":\n",
        paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  
  # Convert lid values to numeric.
  #
  # Text values such as "NaN" become NA during conversion and are
  # subsequently removed.
  data$lid <- suppressWarnings(
    as.numeric(
      as.character(data$lid)
    )
  )
  
  # Remove rows that cannot be included in the model.
  data <- data[
    complete.cases(
      data[, required_columns]
    ),
    ,
    drop = FALSE
  ]
  
  if (nrow(data) == 0) {
    stop(
      paste0(
        "No complete observations remain after cleaning ",
        basename(file_path),
        "."
      ),
      call. = FALSE
    )
  }
  
  # Define animal as the grouping factor.
  data$animal_ID <- factor(
    data$animal_ID
  )
  
  # Preserve the order in which block values first occur.
  block_levels <- unique(
    as.character(
      data$block
    )
  )
  
  # Explicitly use block 1 as the reference level when it is present.
  if ("1" %in% block_levels) {
    block_levels <- c(
      "1",
      setdiff(
        block_levels,
        "1"
      )
    )
  }
  
  data$block <- factor(
    as.character(data$block),
    levels = block_levels
  )
  
  if (nlevels(data$block) < 2) {
    stop(
      paste0(
        "The dataset ",
        basename(file_path),
        " contains fewer than two block levels."
      ),
      call. = FALSE
    )
  }
  
  data
}

# -------------------------------------------------------------------------
# Function: fit model, run permutation test and save results
# -------------------------------------------------------------------------

analyse_time_point <- function(
    data,
    time_point,
    output_directory,
    n_permutations = 10000,
    permutation_seed = 1234) {
  
  message(
    "\nRunning analysis for ",
    time_point,
    "..."
  )
  
  # Standard parametric linear mixed-effects model.
  #
  # This preserves the model used in the original script:
  # one random intercept per animal.
  model <- lme4::lmer(
    lid ~ block + (1 | animal_ID),
    data = data,
    REML = TRUE,
    na.action = na.omit
  )
  
  # Permutation test.
  permutation_model <- predictmeans::permmodels(
    model = model,
    type = 1,
    nperm = n_permutations,
    seed = permutation_seed
  )
  
  # -----------------------------------------------------------------------
  # Extract and save permutation p-values
  # -----------------------------------------------------------------------
  
  # Note: predictmeans uses the object name "COEFFICENTS"
  # with this spelling.
  permutation_coefficients <- as.data.frame(
    permutation_model$COEFFICENTS,
    stringsAsFactors = FALSE
  )
  
  permutation_coefficients$Term <- rownames(
    permutation_coefficients
  )
  
  rownames(permutation_coefficients) <- NULL
  
  permutation_coefficients <- permutation_coefficients[
    ,
    c(
      "Term",
      setdiff(
        names(permutation_coefficients),
        "Term"
      )
    ),
    drop = FALSE
  ]
  
  utils::write.csv(
    permutation_coefficients,
    file.path(
      output_directory,
      paste0(
        "PermutationCoefficients_Figure2B_",
        time_point,
        ".csv"
      )
    ),
    row.names = FALSE
  )
  
  # Save the term-level permutation ANOVA table.
  permutation_anova <- as.data.frame(
    permutation_model$ANOVA,
    stringsAsFactors = FALSE
  )
  
  permutation_anova$Term <- rownames(
    permutation_anova
  )
  
  rownames(permutation_anova) <- NULL
  
  permutation_anova <- permutation_anova[
    ,
    c(
      "Term",
      setdiff(
        names(permutation_anova),
        "Term"
      )
    ),
    drop = FALSE
  ]
  
  utils::write.csv(
    permutation_anova,
    file.path(
      output_directory,
      paste0(
        "PermutationANOVA_Figure2B_",
        time_point,
        ".csv"
      )
    ),
    row.names = FALSE
  )
  
  # Extract the block coefficient from the coefficient table.
  # With block 1 as the reference, this will normally be named "block3".
  block_row <- grep(
    "^block",
    permutation_coefficients$Term
  )
  
  if (length(block_row) != 1) {
    stop(
      paste0(
        "Expected exactly one block coefficient, but found ",
        length(block_row),
        " in ",
        time_point,
        ". Terms were: ",
        paste(
          permutation_coefficients$Term,
          collapse = ", "
        )
      ),
      call. = FALSE
    )
  }
  
  # Identify columns robustly.
  estimate_column <- grep(
    "^Estimate$",
    names(permutation_coefficients),
    value = TRUE
  )
  
  standard_error_column <- grep(
    "Std",
    names(permutation_coefficients),
    value = TRUE
  )[1]
  
  statistic_column <- grep(
    "value",
    names(permutation_coefficients),
    value = TRUE
  )[1]
  
  permutation_p_column <- grep(
    "Perm_p_value",
    names(permutation_coefficients),
    value = TRUE
  )
  
  block_result <- data.frame(
    TimePoint = time_point,
    Comparison = permutation_coefficients$Term[block_row],
    Estimate = as.numeric(
      permutation_coefficients[
        block_row,
        estimate_column
      ]
    ),
    StandardError = as.numeric(
      permutation_coefficients[
        block_row,
        standard_error_column
      ]
    ),
    TestStatistic = as.numeric(
      permutation_coefficients[
        block_row,
        statistic_column
      ]
    ),
    PermutationPValue = as.numeric(
      permutation_coefficients[
        block_row,
        permutation_p_column
      ]
    ),
    NumberOfPermutations = n_permutations
  )
  
  utils::write.csv(
    block_result,
    file.path(
      output_directory,
      paste0(
        "PValue_Figure2B_",
        time_point,
        ".csv"
      )
    ),
    row.names = FALSE
  )
  
  # -----------------------------------------------------------------------
  # Save cleaned input data
  # -----------------------------------------------------------------------
  
  cleaned_data_file <- file.path(
    output_directory,
    paste0(
      "SourceData_Figure2B_",
      time_point,
      "_cleaned.csv"
    )
  )
  
  utils::write.csv(
    data,
    cleaned_data_file,
    row.names = FALSE
  )
  
  # -----------------------------------------------------------------------
  # Save model objects
  # -----------------------------------------------------------------------
  
  saveRDS(
    model,
    file.path(
      output_directory,
      paste0(
        "Model_Figure2B_",
        time_point,
        ".rds"
      )
    )
  )
  
  saveRDS(
    permutation_model,
    file.path(
      output_directory,
      paste0(
        "PermutationModel_Figure2B_",
        time_point,
        ".rds"
      )
    )
  )
  
  # -----------------------------------------------------------------------
  # Save standard model summary
  # -----------------------------------------------------------------------
  
  model_summary_file <- file.path(
    output_directory,
    paste0(
      "ModelSummary_Figure2B_",
      time_point,
      ".txt"
    )
  )
  
  capture.output(
    summary(model),
    file = model_summary_file
  )
  
  # Save fixed-effect coefficient table separately.
  coefficient_table <- as.data.frame(
    coef(summary(model))
  )
  
  coefficient_table$Term <- rownames(
    coefficient_table
  )
  
  rownames(coefficient_table) <- NULL
  
  coefficient_table <- coefficient_table[
    ,
    c(
      "Term",
      setdiff(
        names(coefficient_table),
        "Term"
      )
    ),
    drop = FALSE
  ]
  
  utils::write.csv(
    coefficient_table,
    file.path(
      output_directory,
      paste0(
        "ModelCoefficients_Figure2B_",
        time_point,
        ".csv"
      )
    ),
    row.names = FALSE
  )
  
  # -----------------------------------------------------------------------
  # Save permutation-test output
  # -----------------------------------------------------------------------
  
  permutation_summary_file <- file.path(
    output_directory,
    paste0(
      "PermutationTest_Figure2B_",
      time_point,
      ".txt"
    )
  )
  
  capture.output(
    print(permutation_model),
    file = permutation_summary_file
  )
  
  # -----------------------------------------------------------------------
  # Save diagnostic plots
  # -----------------------------------------------------------------------
  
  diagnostic_plot_file <- file.path(
    output_directory,
    paste0(
      "Diagnostics_Figure2B_",
      time_point,
      ".pdf"
    )
  )
  
  grDevices::pdf(
    diagnostic_plot_file,
    width = 8,
    height = 6
  )
  
  tryCatch(
    {
      predictmeans::residplot(
        model,
        newwd = FALSE
      )
    },
    finally = {
      grDevices::dev.off()
    }
  )
  
  # -----------------------------------------------------------------------
  # Return results to the R session
  # -----------------------------------------------------------------------
  
  list(
    data = data,
    model = model,
    permutation_model = permutation_model
  )
}

# -------------------------------------------------------------------------
# Load input data
# -------------------------------------------------------------------------

data_tp1 <- prepare_lid_data(
  tp1_file
)

data_tp2 <- prepare_lid_data(
  tp2_file
)

message(
  "\nTP1 observations: ",
  nrow(data_tp1),
  "\nTP1 animals: ",
  nlevels(data_tp1$animal_ID),
  "\nTP1 block levels: ",
  paste(
    levels(data_tp1$block),
    collapse = ", "
  )
)

message(
  "\nTP2 observations: ",
  nrow(data_tp2),
  "\nTP2 animals: ",
  nlevels(data_tp2$animal_ID),
  "\nTP2 block levels: ",
  paste(
    levels(data_tp2$block),
    collapse = ", "
  )
)

# -------------------------------------------------------------------------
# Run analyses
# -------------------------------------------------------------------------

results_tp1 <- analyse_time_point(
  data = data_tp1,
  time_point = "TP1",
  output_directory = output_directory,
  n_permutations = 10000,
  permutation_seed = 1234
)

results_tp2 <- analyse_time_point(
  data = data_tp2,
  time_point = "TP2",
  output_directory = output_directory,
  n_permutations = 10000,
  permutation_seed = 1234
)

# -------------------------------------------------------------------------
# Save complete statistical results
# -------------------------------------------------------------------------

saveRDS(
  list(
    TP1 = results_tp1,
    TP2 = results_tp2
  ),
  file.path(
    output_directory,
    "Figure2B_complete_statistical_results.rds"
  )
)

# Record R and package versions.
capture.output(
  sessionInfo(),
  file = file.path(
    output_directory,
    "Figure2B_R_sessionInfo.txt"
  )
)

message(
  "\nFigure 2B statistical analyses completed.",
  "\nResults saved to:\n",
  output_directory
)