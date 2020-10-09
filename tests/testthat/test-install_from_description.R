context("install_from_description")
dummypackage <- system.file("dummypackage", package = "attachment")
# Copy to tmpdir
pkg_dir <- tempdir()
file.copy(dummypackage, pkg_dir, recursive = TRUE)
browseURL(file.path(pkg_dir, "dummypackage"))
# install_from_description(path = file.path(dummypackage,"DESCRIPTION"), field = c("Imports", "Depends"))

# This test need "magrittr" to be correctly tested
if (length(find.package("magrittr", quiet = TRUE)) == 0) {
  install.packages("magrittr", repos = "https://cloud.r-project.org")
}

test_that("install_from_description works", {
  expect_message(
    install_from_description(
      path = file.path(pkg_dir, "dummypackage","DESCRIPTION"), field = c("Imports", "Depends")),
    'All required packages are installed'
  )
  lines <- readLines(file.path(pkg_dir, "dummypackage","DESCRIPTION"))
  lines[14] <- c("    magrittr,\n    toto, ")
  writeLines(lines, file.path(pkg_dir, "dummypackage","DESCRIPTION"))
  # Add dummy package name to try to install
  expect_warning(
    install_from_description(
      path = file.path(pkg_dir, "dummypackage","DESCRIPTION"), field = c("Imports", "Depends"),
      repos = "https://cloud.r-project.org")
  )
})

unlink(file.path(pkg_dir, "dummypackage"), recursive = TRUE)
