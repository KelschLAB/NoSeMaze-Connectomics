# panel_C_statistics.R
# Jonathan Reinwald
#
# Statistical analysis for Figure 2C:
# Intrasession eyelid responses across conditioning blocks 1-3.
#
# Model:
# lid ~ block + (1 | animal_ID)
#
# Inference:
# 10,000-permutation mixed-effects analysis using predictmeans.
#
# Expected repository structure:
#
# NoSeMaze-Connectomics/
# ├── figures/main/Figure_2/panel_C_statistics.R
# ├── data/processed/eyelid/reappraisal/
# │   └── Mean_LidData_R_intrasession.xlsx
# └── results/main/Figure_2/statistics/

rm(list = ls())

# -------------------------------------------------------------------------
# Identify repository root from this script
# -------------------------------------------------------------------------

get_script_file <- function() {
  
  # When the script is run with source(), its path is stored in `ofile`
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
      "Could not determine the location of panel_C_statistics.R.\n\n",
      "Run the script using source('path/to/panel_C_statistics.R') ",
      "or with Rscript."
    ),
    call. = FALSE
  )
}

script_file <- get_script_file()
script_directory <- dirname(script_file)

# panel_C_statistics.R is located in:
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
      paste0(
        '"',
        missing_packages,
        '"',
        collapse = ", "
      ),
      "))"
    ),
    call. = FALSE
  )
}

# -------------------------------------------------------------------------
# Define paths
# -------------------------------------------------------------------------

input_file <- file.path(
  repo_root,
  "data",
  "processed",
  "eyelid",
  "reappraisal",
  "Mean_LidData_R_intrasession.xlsx"
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
# Check input file
# -------------------------------------------------------------------------

if (!file.exists(input_file)) {
  stop(
    paste0(
      "Required input file not found:\n",
      input_file,
      "\n\nExpected repository location:\n",
      "data/processed/eyelid/reappraisal/",
      "Mean_LidData_R_intrasession.xlsx"
    ),
    call. = FALSE
  )
}

# -------------------------------------------------------------------------
# Load data
# -------------------------------------------------------------------------

my_data <- readxl::read_excel(
  input_file
)

required_columns <- c(
  "lid",
  "block",
  "animal_ID"
)

missing_columns <- setdiff(
  required_columns,
  names(my_data)
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

# -------------------------------------------------------------------------
# Prepare data
# -------------------------------------------------------------------------

# Convert values such as "NaN" to missing numeric values.
my_data$lid <- suppressWarnings(
  as.numeric(
    as.character(my_data$lid)
  )
)

# Remove rows with missing outcome, block or animal identifier.
my_data <- my_data[
  complete.cases(
    my_data[, required_columns]
  ),
  ,
  drop = FALSE
]

if (nrow(my_data) == 0) {
  stop(
    "No complete observations remain after data cleaning.",
    call. = FALSE
  )
}

my_data$animal_ID <- factor(
  my_data$animal_ID
)

# Preserve the observed block ordering.
block_levels <- unique(
  as.character(my_data$block)
)

# Explicitly use block 1 as the reference level.
if ("1" %in% block_levels) {
  block_levels <- c(
    "1",
    setdiff(block_levels, "1")
  )
}

my_data$block <- factor(
  as.character(my_data$block),
  levels = block_levels
)

if (nlevels(my_data$block) < 2) {
  stop(
    "The dataset contains fewer than two block levels.",
    call. = FALSE
  )
}

message(
  "\nObservations: ",
  nrow(my_data),
  "\nAnimals: ",
  nlevels(my_data$animal_ID),
  "\nBlock levels: ",
  paste(
    levels(my_data$block),
    collapse = ", "
  )
)

# -------------------------------------------------------------------------
# Fit random-intercept mixed-effects model
# -------------------------------------------------------------------------

model <- lme4::lmer(
  lid ~ block + (1 | animal_ID),
  data = my_data,
  REML = TRUE,
  na.action = na.omit
)

# -------------------------------------------------------------------------
# Permutation analysis
# -------------------------------------------------------------------------

number_of_permutations <- 10000
permutation_seed <- 1234

permutation_results <- predictmeans::permmodels(
  model = model,
  type = 1,
  nperm = number_of_permutations,
  seed = permutation_seed
)

# -------------------------------------------------------------------------
# Save cleaned input data
# -------------------------------------------------------------------------

utils::write.csv(
  my_data,
  file.path(
    output_directory,
    "SourceData_Figure2C_Intrasession_cleaned.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Save fitted model
# -------------------------------------------------------------------------

saveRDS(
  model,
  file.path(
    output_directory,
    "Model_Figure2C_Intrasession.rds"
  )
)

capture.output(
  summary(model),
  file = file.path(
    output_directory,
    "ModelSummary_Figure2C_Intrasession.txt"
  )
)

# -------------------------------------------------------------------------
# Save fixed-effect estimates
# -------------------------------------------------------------------------

fixed_effects <- as.data.frame(
  coef(summary(model))
)

fixed_effects$Term <- rownames(
  fixed_effects
)

rownames(fixed_effects) <- NULL

fixed_effects <- fixed_effects[
  ,
  c(
    "Term",
    setdiff(
      names(fixed_effects),
      "Term"
    )
  ),
  drop = FALSE
]

utils::write.csv(
  fixed_effects,
  file.path(
    output_directory,
    "ModelCoefficients_Figure2C_Intrasession.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Save complete permutation output
# -------------------------------------------------------------------------

saveRDS(
  permutation_results,
  file.path(
    output_directory,
    "PermutationModel_Figure2C_Intrasession.rds"
  )
)

capture.output(
  print(permutation_results),
  file = file.path(
    output_directory,
    "PermutationTest_Figure2C_Intrasession.txt"
  )
)

# -------------------------------------------------------------------------
# Extract coefficient-level permutation results
# -------------------------------------------------------------------------

permutation_coefficients <- as.data.frame(
  permutation_results$COEFFICENTS,
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
    "PermutationCoefficients_Figure2C_Intrasession.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Extract omnibus permutation ANOVA
# -------------------------------------------------------------------------

permutation_anova <- as.data.frame(
  permutation_results$ANOVA,
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
    "PermutationANOVA_Figure2C_Intrasession.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Save an immediately readable p-value table
# -------------------------------------------------------------------------

if (!"Perm_p_value" %in% names(permutation_coefficients)) {
  stop(
    paste0(
      'Column "Perm_p_value" was not found in the ',
      "permutation coefficient table."
    ),
    call. = FALSE
  )
}

if (!"Perm_p_value" %in% names(permutation_anova)) {
  stop(
    paste0(
      'Column "Perm_p_value" was not found in the ',
      "permutation ANOVA table."
    ),
    call. = FALSE
  )
}

# With block 1 as the reference level, these rows normally represent:
# block2 = block 2 versus block 1
# block3 = block 3 versus block 1
block_coefficient_rows <- grepl(
  "^block",
  permutation_coefficients$Term
)

coefficient_p_values <- data.frame(
  TestType = "Coefficient comparison",
  Comparison = permutation_coefficients$Term[
    block_coefficient_rows
  ],
  PermutationPValue = as.numeric(
    permutation_coefficients$Perm_p_value[
      block_coefficient_rows
    ]
  ),
  NumberOfPermutations = number_of_permutations,
  stringsAsFactors = FALSE
)

# Overall test of whether the block factor contributes to the model.
block_anova_rows <- permutation_anova$Term == "block"

if (!any(block_anova_rows)) {
  block_anova_rows <- grepl(
    "^block$",
    permutation_anova$Term,
    ignore.case = TRUE
  )
}

omnibus_p_values <- data.frame(
  TestType = "Omnibus block effect",
  Comparison = "Overall block effect",
  PermutationPValue = as.numeric(
    permutation_anova$Perm_p_value[
      block_anova_rows
    ]
  ),
  NumberOfPermutations = number_of_permutations,
  stringsAsFactors = FALSE
)

p_value_table <- rbind(
  omnibus_p_values,
  coefficient_p_values
)

utils::write.csv(
  p_value_table,
  file.path(
    output_directory,
    "PValues_Figure2C_Intrasession.csv"
  ),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# Save diagnostic plots
# -------------------------------------------------------------------------

diagnostic_file <- file.path(
  output_directory,
  "Diagnostics_Figure2C_Intrasession.pdf"
)

grDevices::pdf(
  diagnostic_file,
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

# -------------------------------------------------------------------------
# Record software versions
# -------------------------------------------------------------------------

capture.output(
  sessionInfo(),
  file = file.path(
    output_directory,
    "Figure2C_R_sessionInfo.txt"
  )
)

message(
  "\nFigure 2C statistical analysis completed.",
  "\nResults saved to:\n",
  output_directory
)