# Figure_S1D_stats.R
# Jonathan Reinwald
#
# Reviewer-facing statistics for Supplementary Figure_S1D.
#
# Cohort: control/no-puff
# Outcome: lid_TP2
# Model: lid_TP2 ~ block_label + (1 | animal_ID)
# Permutation inference: predictmeans::permmodels(), 10,000 permutations,
# seed = 1234.
#
# The repository root is determined from this script's own location.

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
    return(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/", mustWork = TRUE))
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

input_file <- file.path(
  repo_root,
  "data",
  "processed",
  "eyelid",
  "control",
  "Mean_LidData_R_control_block1to3_TP2.xlsx"
)

output_dir <- file.path(
  repo_root,
  "results",
  "supplement",
  "Figure_S1",
  "Figure_S1D"
)

if (!file.exists(input_file)) {
  stop("Required input file not found:\n", input_file, call. = FALSE)
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

required_packages <- c("readxl", "lmerTest", "predictmeans")
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

myData <- readxl::read_excel(input_file)

required_columns <- c("animal_ID", "block", "lid_TP2")
missing_columns <- setdiff(required_columns, names(myData))

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(missing_columns, collapse = ", "),
    call. = FALSE
  )
}

myData$lid_TP2 <- suppressWarnings(as.numeric(as.character(myData$lid_TP2)))
myData$block <- suppressWarnings(as.numeric(as.character(myData$block)))

myData <- myData[
  is.finite(myData$lid_TP2) &
    is.finite(myData$block) &
    !is.na(myData$animal_ID),
  ,
  drop = FALSE
]

# Retain only the periods used in the displayed Supplementary Figure S1
# analysis. Historical processed tables can contain additional block codes.
allowed_blocks <- c(1, 2, 3)
myData <- myData[myData$block %in% allowed_blocks, , drop = FALSE]

present_blocks <- sort(unique(myData$block))
if (!identical(as.numeric(present_blocks), as.numeric(allowed_blocks))) {
  stop(
    "Expected block codes ",
    paste(allowed_blocks, collapse = ", "),
    "; present after filtering: ",
    paste(present_blocks, collapse = ", "),
    call. = FALSE
  )
}

myData$block <- factor(
  as.character(myData$block),
  levels = as.character(allowed_blocks)
)
myData$animal_ID <- factor(myData$animal_ID)

block_label_map <- c("PRE", "NON_PAIRING", "TEST")
names(block_label_map) <- c("1", "2", "3")
myData$block_label <- factor(
  unname(block_label_map[as.character(myData$block)]),
  levels = unname(block_label_map)
)

if (nrow(myData) == 0) {
  stop("No valid observations remain after cleaning.", call. = FALSE)
}

model <- lmerTest::lmer(
  lid_TP2 ~ block_label + (1 | animal_ID),
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

utils::write.csv(
  myData,
  file.path(output_dir, "SourceData_Figure_S1D_TP2_stats.csv"),
  row.names = FALSE
)

model_summary <- summary(model)

capture.output(
  model_summary,
  file = file.path(output_dir, "Statistics_Figure_S1D_TP2_LME_summary.txt")
)

coefficient_table <- as.data.frame(model_summary$coefficients)
coefficient_table$Term <- rownames(coefficient_table)
rownames(coefficient_table) <- NULL
coefficient_table <- coefficient_table[
  c("Term", setdiff(names(coefficient_table), "Term"))
]

utils::write.csv(
  coefficient_table,
  file.path(output_dir, "Statistics_Figure_S1D_TP2_LME_coefficients.csv"),
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
  file.path(output_dir, "Statistics_Figure_S1D_TP2_LME_ANOVA.csv"),
  row.names = FALSE
)

writeLines(
  permutation_console_output,
  con = file.path(output_dir, "Statistics_Figure_S1D_TP2_PERMUTATION_RESULTS.txt")
)

saveRDS(
  permutation_result,
  file.path(output_dir, "Statistics_Figure_S1D_TP2_permutation_permlist.rds")
)

metadata <- data.frame(
  Figure = "Figure_S1D",
  Cohort = "control/no-puff",
  Timepoint = "TP2",
  Outcome = "lid_TP2",
  BlockCodes = paste(allowed_blocks, collapse = ";"),
  Formula = "lid_TP2 ~ block_label + (1 | animal_ID)",
  N_Observations = nrow(myData),
  N_Animals = length(unique(myData$animal_ID)),
  N_Permutations = 10000,
  Seed = 1234,
  InputFile = normalizePath(input_file, winslash = "/", mustWork = TRUE),
  stringsAsFactors = FALSE
)

utils::write.csv(
  metadata,
  file.path(output_dir, "AnalysisMetadata_Figure_S1D_TP2_stats.csv"),
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
  file.path(output_dir, "Figure_S1D_TP2_stats_complete_results.rds")
)

capture.output(
  sessionInfo(),
  file = file.path(output_dir, "Figure_S1D_TP2_R_sessionInfo.txt")
)

cat("\nCompleted Figure_S1D TP2 statistics.\n")
cat("Outputs saved to:\n", output_dir, "\n")
