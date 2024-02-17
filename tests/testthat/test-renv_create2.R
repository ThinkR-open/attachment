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
expect_true("dplyr" %in% names(renv_content$data()$Packages))
expect_true("sudoku" %in% names(renv_content$data()$Packages))
})


