context("create_dependencies_file.R")

# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)

create_dependencies_file(path = file.path(dummypackage,"DESCRIPTION"),
                         to = file.path(dummypackage, "inst/dependencies.R"),
                         field = c("Depends", "Imports", "Suggests"),
                         open_file = FALSE)
dep_file <- readLines(file.path(tmpdir, "dummypackage", "inst/dependencies.R"))

test_that("create-dependencies-file works", {
  expect_equal(dep_file[3], "to_install <- c(\"knitr\", \"magrittr\", \"rmarkdown\", \"testthat\")")
})
