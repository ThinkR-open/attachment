# These tests can not run on CRAN
skip_on_cran()

if (length(find.package("extrapackage", quiet = TRUE)) != 0) {
  unlink(find.package("extrapackage", quiet = TRUE), recursive = TRUE)
}

# test on dummy package
tmpdir <- tempfile(pattern = "pkgrenv2")
dir.create(tmpdir)
file.copy(
  system.file("dummyfolder", package = "attachment"), tmpdir,
  recursive = TRUE
)
dummyfolder <- file.path(tmpdir, "dummyfolder")







# Create a second dummy package that will be a dependance of dummy
# So that, we are sure it does not exists on CRAN for extra checks
extra_path <- file.path(tmpdir, "dummy.extra")
dir.create(extra_path, recursive = TRUE)
file.copy(
  system.file("dummypackage", package = "attachment"),
  extra_path,
  recursive = TRUE
)
extrapackage <- file.path(extra_path, "extrapackage")
file.rename(file.path(extra_path, "dummypackage"), extrapackage)
# Rename package and remove 'Rcpp'
desc_lines <- readLines(file.path(extrapackage, "DESCRIPTION"))
desc_lines <- gsub("dummypackage", "extrapackage", desc_lines)
desc_lines <- desc_lines[-grep("LinkingTo|Rcpp", desc_lines)]
cat(desc_lines, sep = "\n", file = file.path(extrapackage, "DESCRIPTION"))
# Remove calls to 'dummypackage' and 'Rcpp'
unlink(file.path(extrapackage, "tests"), recursive = TRUE)
# document
# inuse <- search()
att_amend_desc(path = extrapackage)
unloadNamespace("extrapackage") # for windows mainly
# Install package to make it available to {renv}
install.packages(extrapackage, repos = NULL, type = "source")












lock_ <- file.path(tmpdir, "my_lock.lock")


  expect_message({

    my_renv_ <- create_renv_for_dev(
      path = dummyfolder,
      install_if_missing = FALSE,
      output = lock_,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)}
  )





test_that("create_renv_for_dev creates lock files even without DESCRIPTION file", {
  expect_true(file.exists(lock_))
})

# print(my_renv_extra)


renv_content <- getFromNamespace("lockfile", "renv")(my_renv_)


test_that("lockfile are correct renv files", {
expect_s3_class(renv_content, "renv_lockfile_api")
expect_true("glue" %in% names(renv_content$data()$Packages))
expect_true("extrapackage" %in% names(renv_content$data()$Packages))
})


