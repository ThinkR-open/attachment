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

