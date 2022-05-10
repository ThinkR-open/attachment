# test on dummy package
tmpdir <- tempfile(pattern = "pkg")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE
)
dummypackage <- file.path(tmpdir, "dummypackage")

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
# Rename package
desc_lines <- readLines(file.path(extrapackage, "DESCRIPTION"))
desc_lines <- gsub("dummypackage", "extrapackage", desc_lines)
cat(desc_lines, sep = "\n", file = file.path(extrapackage, "DESCRIPTION"))
att_amend_desc(extrapackage)
# Install package to make it available to {renv}
install.packages(extrapackage, repos = NULL)

# Add a development package not required in DESCRIPTION: dummy.extra ----
lock_includes_extra <- file.path(tmpdir, "for_extra.lock")
lock_without_extra <- file.path(tmpdir, "blank.lock")

if (interactive() | tolower(Sys.info()[["sysname"]]) == "linux") {
  expect_message({my_renv_extra <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = "extrapackage",
      output = lock_includes_extra)},
    "There is no directory named: dev, data-raw")
  expect_message({
    # message, but not missing directories as they are skipped
    my_renv_blank <-
      create_renv_for_prod(
        path = dummypackage,
        dev_pkg = NULL,
        install_if_missing = FALSE,
        output = lock_without_extra)}
  )
} else {
  expect_message({
    my_renv_extra <- create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = "extrapackage",
      output = lock_includes_extra,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)},
    "There is no directory named: dev, data-raw")

  expect_message({
    # message, but not missing directories as they are skipped
    my_renv_blank <- create_renv_for_prod(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = NULL,
      output = lock_without_extra,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)})
}

rstudioapi::navigateToFile(lock_without_extra)
rstudioapi::navigateToFile(lock_includes_extra)

test_that("create_renv_for_dev creates lock files", {
  expect_true(file.exists(lock_includes_extra))
  expect_true(file.exists(my_renv_extra))
  expect_true(file.exists(lock_without_extra))
  expect_true(file.exists(my_renv_blank))
})

# print(my_renv_extra)
local_renv_extra <- getFromNamespace("lockfile", "renv")(my_renv_extra)
local_renv_blank <- getFromNamespace("lockfile", "renv")(my_renv_blank)

test_that("lockfile are renv files", {
  expect_s3_class(local_renv_extra, "renv_lockfile_api")
  expect_s3_class(local_renv_blank, "renv_lockfile_api")
})

pkg_extra <- names(local_renv_extra$data()$Packages)
pkg_blank <- names(local_renv_blank$data()$Packages)

# je ne trouve pas de moyen de controler que extra est bien dans local_renv_extra
# et pas dans local_renv_

# print(les_pkg) # devtools::check()pas de extra ici !!!
test_that("extrapackage is present thank to dev_pkg", {
  expect_true("extrapackage" %in% pkg_extra)
  expect_false("extrapackage" %in% pkg_blank)
  # all blank are in extra
  expect_true(all(pkg_blank %in% pkg_extra))
  # there are extra not in blank
  expect_equal(setdiff(pkg_extra, pkg_blank), c("Rcpp", "extrapackage"))
})

# reference cannot work because it is system and R version dependent
# test_that("create_renv_for_dev works", {
#   expect_equal_to_reference(names(pkg_extra),"my_renv.test")
#   expect_equal_to_reference(names(pkg_blank),"my_renv_blank.test")
# })

remove.packages("extrapackage")
unlink(tmpdir, recursive = TRUE)
