# panel_C_lid_stats.R
# Jonathan Reinwald
#
# Supplementary Figure S1C:
# non-parametric linear mixed-effects analysis of tonic eyelid opening
# across four periods:
#
#   PRE              = trials 11-40
#   PAIRING          = trials 41-80
#   TEST             = trials 81-120
#   ADDITIONAL TEST  = trials 121-160
#
# TEST and ADDITIONAL TEST are each treated as one 40-trial block.
#
# Run panel_C_lid_boxplot.m first. It derives the animal-level,
# non-normalized tonic values directly from pupil_summary_all.mat and
# writes the exact source CSV used here.
#
# Model:
#   lid ~ block_label + (1 | animal_ID)
#
# Permutation inference:
#   predictmeans::permmodels()
#   nperm = 10000
#   seed = 1234

get_script_file <- function() {

  frame_files <- vapply(
    sys.frames(),
    function(frame) if (!is.null(frame$ofile)) as.character(frame$ofile) else NA_character_,
    FUN.VALUE = character(1)
  )

  frame_files <- frame_files[!is.na(frame_files)]

  if (length(frame_files) > 0) {
    return(normalizePath(tail(frame_files, 1), winslash = "/", mustWork = TRUE))
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
    "Could not determine this script's location. Run it with source() or Rscript.",
    call. = FALSE
  )
}

script_file <- get_script_file()
script_dir <- dirname(script_file)

repo_root <- normalizePath(
  file.path(script_dir, "..", "..", ".."),
  winslash = "/",
  mustWork = TRUE
)

output_dir <- file.path(
  repo_root,
  "results",
  "supplement",
  "Figure_S1",
  "Figure_S1C"
)

input_file <- file.path(
  output_dir,
  "SourceData_Figure_S1C_tonic_lid_four_periods.csv"
)

if (!file.exists(input_file)) {
  stop(
    paste0(
      "Required source table not found:\n",
      input_file,
      "\n\nRun panel_C_lid_boxplot.m first."
    ),
    call. = FALSE
  )
}

required_packages <- c("lmerTest", "predictmeans")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing required R package(s): ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

myData <- utils::read.csv(
  input_file,
  stringsAsFactors = FALSE
)

required_columns <- c("animal_ID","block","block_label","lid")
missing_columns <- setdiff(required_columns, names(myData))

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(missing_columns, collapse = ", "),
    call. = FALSE
  )
}

myData$lid <- suppressWarnings(as.numeric(myData$lid))
myData$animal_ID <- factor(myData$animal_ID)

expected_labels <- c(
  "PRE",
  "PAIRING",
  "TEST",
  "ADDITIONAL TEST"
)

if (!all(expected_labels %in% unique(myData$block_label))) {
  stop(
    "The S1C source table does not contain all expected PRE/PAIRING/TEST/ADDITIONAL TEST labels.",
    call. = FALSE
  )
}

myData <- myData[
  is.finite(myData$lid) &
    !is.na(myData$animal_ID) &
    myData$block_label %in% expected_labels,
  ,
  drop = FALSE
]

myData$block_label <- factor(
  myData$block_label,
  levels = expected_labels
)

model <- lmerTest::lmer(
  lid ~ block_label + (1 | animal_ID),
  data = myData,
  REML = TRUE
)

permutation_console_output <- capture.output({

  permutation_result <- predictmeans::permmodels(
    model = model,
    type = 1,
    nperm = 10000,
    seed = 1234,
    prt = TRUE
  )
})

cat(paste(permutation_console_output, collapse = "\n"), "\n")

model_summary <- summary(model)

capture.output(
  model_summary,
  file = file.path(output_dir,"Statistics_Figure_S1C_LME_summary.txt")
)

coefficient_table <- as.data.frame(model_summary$coefficients)
coefficient_table$Term <- rownames(coefficient_table)
rownames(coefficient_table) <- NULL
coefficient_table <- coefficient_table[
  c("Term", setdiff(names(coefficient_table), "Term"))
]

utils::write.csv(
  coefficient_table,
  file.path(output_dir,"Statistics_Figure_S1C_LME_coefficients.csv"),
  row.names = FALSE
)

anova_table <- as.data.frame(anova(model))
anova_table$Term <- rownames(anova_table)
rownames(anova_table) <- NULL
anova_table <- anova_table[
  c("Term", setdiff(names(anova_table), "Term"))
]

utils::write.csv(
  anova_table,
  file.path(output_dir,"Statistics_Figure_S1C_LME_ANOVA.csv"),
  row.names = FALSE
)

writeLines(
  permutation_console_output,
  con = file.path(output_dir,"Statistics_Figure_S1C_PERMUTATION_RESULTS.txt")
)

saveRDS(
  permutation_result,
  file.path(output_dir,"Statistics_Figure_S1C_permutation_permlist.rds")
)

metadata <- data.frame(
  Figure = "Figure S1C",
  Cohort = "conditioning/reappraisal",
  Outcome = "non-normalized tonic lid mean",
  Periods = "PRE;PAIRING;TEST;ADDITIONAL TEST",
  TrialRanges = "11-40;41-80;81-120;121-160",
  Formula = "lid ~ block_label + (1 | animal_ID)",
  N_Observations = nrow(myData),
  N_Animals = length(unique(myData$animal_ID)),
  N_Permutations = 10000,
  Seed = 1234,
  InputFile = normalizePath(input_file, winslash = "/", mustWork = TRUE),
  stringsAsFactors = FALSE
)

utils::write.csv(
  metadata,
  file.path(output_dir,"AnalysisMetadata_Figure_S1C_stats.csv"),
  row.names = FALSE
)

saveRDS(
  list(
    data = myData,
    model = model,
    permutation = permutation_result,
    permutation_console_output = permutation_console_output,
    metadata = metadata
  ),
  file.path(output_dir,"Figure_S1C_lid_stats_complete_results.rds")
)

capture.output(
  sessionInfo(),
  file = file.path(output_dir,"Figure_S1C_R_sessionInfo.txt")
)

cat("\nCompleted Supplementary Figure S1C statistics.\n")
cat("Periods: PRE / PAIRING / TEST / ADDITIONAL TEST\n")
cat("Outputs saved to:\n", output_dir, "\n")
