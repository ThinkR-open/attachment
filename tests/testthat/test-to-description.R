context("test-to-description.R")

# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_to_description(path = dummypackage)
desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
namespace_file <- readLines(file.path(tmpdir, "dummypackage", "NAMESPACE"))

create_dependencies_file(path = file.path(dummypackage,"DESCRIPTION"),
                         to = file.path(dummypackage, "inst/dependencies.R"),
                         field = c("Depends", "Imports", "Suggests"),
                         open_file = FALSE)
dep_file <- readLines(file.path(tmpdir, "dummypackage", "inst/dependencies.R"))

test_that("to-descritpion updates namespace", {
  # importFrom(utils,na.omit) should be removed
  expect_length(namespace_file, 4)
})

test_that("to-description updates description", {
  expect_equal(desc_file[11], "Depends: ")
  expect_equal(desc_file[12], "    R (>= 3.5.0)")
  expect_equal(desc_file[13], "Imports: ")
  expect_equal(desc_file[14], "    magrittr,")
  expect_equal(desc_file[15], "    stats")
  expect_equal(desc_file[16], "Suggests: ")
  expect_equal(desc_file[17], "    ggplot2,")
  expect_equal(desc_file[18], "    knitr,")
  expect_equal(desc_file[19], "    rmarkdown,")
  expect_equal(desc_file[20], "    testthat")
  expect_equal(desc_file[21], "LinkingTo:" )
  expect_equal(desc_file[22], "    Rcpp")
})

test_that("create-dependencies-file works", {
  expect_equal(dep_file[3], "to_install <- c(\"ggplot2\", \"knitr\", \"magrittr\", \"rmarkdown\", \"testthat\")")
})
