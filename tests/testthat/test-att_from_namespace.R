# test on dummy package
tmpdir <- tempfile(pattern = "pkg")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
deps <- att_from_namespace(path = file.path(dummypackage, "NAMESPACE"))

test_that("att_from_namespace works", {
  expect_true(setequal(deps, c("magrittr")))
})

unlink(tmpdir, recursive = TRUE)

# Do not work when NAMESPACE does not exists
tmpdir <- tempfile(pattern = "pkgnamespace")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
file.remove(file.path(dummypackage, "NAMESPACE"))

test_that("att_from_namespace works", {
  expect_error(
    att_from_namespace(path = file.path(dummypackage, "NAMESPACE")),
    regexp = "does not exists"
  )

  expect_true(setequal(deps, c("magrittr")))
})

unlink(tmpdir, recursive = TRUE)

# Works when used twice
tmpdir <- tempfile(pattern = "pkgtwice")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

test_that("att_from_namespace works", {
  deps <- expect_error(
    att_from_namespace(path = file.path(dummypackage, "NAMESPACE")),
    regexp = NA
  )
  expect_true(setequal(deps, c("magrittr")))

  deps <- expect_error(
    att_from_namespace(path = file.path(dummypackage, "NAMESPACE")),
    regexp = NA
  )
  expect_true(setequal(deps, c("magrittr")))

  deps <- expect_error(
    att_from_namespace(path = file.path(dummypackage, "NAMESPACE")),
    regexp = NA
  )
  expect_true(setequal(deps, c("magrittr")))
})

unlink(tmpdir, recursive = TRUE)

# File that failed in the past ----
deps <- att_from_namespace("fake_namespace", document = FALSE)

test_that("att_from_namespace works", {
  expect_true(setequal(deps, c("Rcpp", "magrittr")))
})

# File that failed in the past with bad NAMESPACE ----
# test on dummy package
tmpdir <- tempfile(pattern = "pkgbadnamespace")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# Replace R script to introduce error in NAMESPACE
r_file <- file.path(dummypackage, "R", "my_mean.R")
lines_orig <- lines <- readLines(r_file)
lines[6] <- "#' @importFrom magrittr\n"
writeLines(enc2utf8(lines), r_file)

test_that("bad namespace can be corrected", {
  # expect_warning(cli::cli_warn("toto"), regexp = "tota")

  # Check that the information transmitted by roxygen2 is correctly retransmitted by attachment

  if (packageVersion("roxygen2") >= "7.3.0") {
    # roxygen > 7.3.0 generates a message

    expect_message(att_amend_desc(dummypackage),
                   "must have at least 2 words, not 1")

    # Still message because of r_file but no error
    expect_message(att_from_namespace(path = file.path(dummypackage, "NAMESPACE"),
                                      document = TRUE, clean = TRUE))
  } else {
    # roxygen > 7.1.2 generates a warning
    expect_warning(att_amend_desc(dummypackage),
                   "must have at least 2 words, not 1")
    # Hence no error
    expect_error(
      suppressWarnings(
        att_from_namespace(
          path = file.path(dummypackage, "NAMESPACE"),
          document = TRUE, clean = FALSE)
      ),
      regexp = NA)

    # Still warning because of r_file but no error
    expect_warning(att_from_namespace(path = file.path(dummypackage, "NAMESPACE"),
                                      document = TRUE, clean = TRUE))
  }


  # Correct R function, no warning, no error
  writeLines(enc2utf8(lines_orig), r_file)
  deps <- att_from_namespace(path = file.path(dummypackage, "NAMESPACE"),
                                    document = TRUE, clean = TRUE)
  expect_true(setequal(deps, c("magrittr")))
})

unlink(dummypackage, recursive = TRUE)
unlink(tmpdir, recursive = TRUE)

# Issue #135: inline R in @param must resolve package-local functions ----
tmpdir <- tempfile(pattern = "pkginline")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

# Enable roxygen markdown so inline R inside @param is actually evaluated.
# Strip trailing blank lines from the dummypackage DESCRIPTION before
# appending: in DCF format a blank line starts a new record, so an
# unstripped append would silently produce a second record and tooling may
# ignore the new field.
desc_file <- file.path(dummypackage, "DESCRIPTION")
desc_lines <- readLines(desc_file)
while (length(desc_lines) > 0 && !nzchar(desc_lines[length(desc_lines)])) {
  desc_lines <- desc_lines[-length(desc_lines)]
}
writeLines(c(desc_lines, "Roxygen: list(markdown = TRUE)"), desc_file)

# Add an exported helper that the @param will call inline
helper_file <- file.path(dummypackage, "R", "helper.R")
writeLines(
  c(
    "#' Return a doc snippet",
    "#' @param name a name",
    "#' @return a string",
    "#' @export",
    "helper <- function(name) {",
    "  paste('a', name, 'parameter')",
    "}"
  ),
  helper_file
)

# Rewrite my_mean.R so its @param uses inline R calling the package-local helper
my_mean_file <- file.path(dummypackage, "R", "my_mean.R")
writeLines(
  c(
    "#' my_mean",
    "#'",
    "#' @param x `r helper(\"x\")`",
    "#'",
    "#' @export",
    "#' @importFrom magrittr %>%",
    "my_mean <- function(x){",
    "  x <- x %>% stats::na.omit()",
    "  sum(x) / base::length(x)",
    "}"
  ),
  my_mean_file
)

test_that("inline R in @param resolves package-local functions (#135)", {
  unlink(file.path(dummypackage, "man"), recursive = TRUE)

  captured <- character()
  withCallingHandlers(
    att_amend_desc(dummypackage),
    message = function(m) {
      captured <<- c(captured, conditionMessage(m))
      invokeRestart("muffleMessage")
    },
    warning = function(w) {
      captured <<- c(captured, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  expect_false(
    any(grepl("could not find function", captured, fixed = TRUE)),
    info = paste0(
      "Inline R in @param failed to resolve `helper()`. Captured conditions:\n",
      paste(captured, collapse = "\n")
    )
  )

  rd_file <- file.path(dummypackage, "man", "my_mean.Rd")
  expect_true(file.exists(rd_file))
  rd_content <- paste(readLines(rd_file), collapse = "\n")
  expect_match(rd_content, "a x parameter", fixed = TRUE)
})

unlink(tmpdir, recursive = TRUE)

# @examplesIf condition payload must NOT be scanned for dependencies (#136 review) ----
tmpdir <- tempfile(pattern = "pkgexamplesif")
dir.create(tmpdir)
ifpkg_dir <- file.path(tmpdir, "Rscripts")
dir.create(ifpkg_dir)
ifpkg_file <- file.path(ifpkg_dir, "fun.R")
writeLines(
  c(
    "#' fun",
    "#' @param x a value",
    "#' @return x",
    "#' @export",
    "#' @examplesIf requireNamespace(\"fakeguardpkg\", quietly = TRUE)",
    "#' library(magrittr)",
    "#' x %>% identity()",
    "fun <- function(x) x"
  ),
  ifpkg_file
)

test_that("att_from_examples ignores @examplesIf condition for dep detection (#136 review)", {
  deps <- att_from_examples(dir.r = ifpkg_dir)
  expect_true("magrittr" %in% deps)
  expect_false("fakeguardpkg" %in% deps)
})

unlink(tmpdir, recursive = TRUE)

