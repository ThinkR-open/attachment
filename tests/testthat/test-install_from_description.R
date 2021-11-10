dummypackage <- system.file("dummypackage", package = "attachment")
# Copy to tmpdir
pkg_dir <- tempdir()
file.copy(dummypackage, pkg_dir, recursive = TRUE)
# browseURL(file.path(pkg_dir, "dummypackage"))
# install_from_description(path = file.path(dummypackage,"DESCRIPTION"), field = c("Imports", "Depends"))

# This test need "magrittr" to be correctly tested
if (length(find.package("magrittr", quiet = TRUE)) == 0) {
  install.packages("magrittr", repos = "https://cloud.r-project.org")
}

# install_from_description ----
test_that("install_from_description works", {
  expect_message(
    install_from_description(
      path = file.path(pkg_dir, "dummypackage","DESCRIPTION"), field = c("Imports", "Depends")),
    'All required packages are installed'
  )
  lines <- readLines(file.path(pkg_dir, "dummypackage","DESCRIPTION"))
  w.magrittr <- grep("magrittr", lines)
  lines[w.magrittr] <- c("    magrittr,\n    toto,\n    tata, ")
  writeLines(lines, file.path(pkg_dir, "dummypackage","DESCRIPTION"))
  # Add dummy package name to try to install
  # test message
  # There is a warning to capture because tata and toto do not exist
  expect_message(
    capture_warning(
      install_from_description(
        path = file.path(pkg_dir, "dummypackage","DESCRIPTION"), field = c("Imports", "Depends"),
        repos = "https://cloud.r-project.org")
    ),
    "Installation of: tata, toto"
  )
  # There is a warning because tata and toto do not exist
  # This is expected warning from install.package()
  expect_warning(
    install_from_description(
      path = file.path(pkg_dir, "dummypackage","DESCRIPTION"), field = c("Imports", "Depends"),
      repos = "https://cloud.r-project.org")
  )
})

unlink(file.path(pkg_dir, "dummypackage"), recursive = TRUE)
