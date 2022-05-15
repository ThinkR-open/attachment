if (length(find.package("extrapackage", quiet = TRUE)) != 0) {
  unlink(find.package("extrapackage", quiet = TRUE), recursive = TRUE)
}

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

# Add a development package not required in DESCRIPTION: dummy.extra ----
lock_includes_extra <- file.path(tmpdir, "for_extra.lock")
lock_without_extra <- file.path(tmpdir, "blank.lock")

if (interactive()) {
  expect_message({my_renv_extra <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = "extrapackage",
      output = lock_includes_extra)}
    # "There is no directory named: dev, data-raw" # cli
  )
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
      force = TRUE)}#,
    # "There is no directory named: dev, data-raw" # cli
  )
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

test_that("extrapackage is present thanks to dev_pkg", {
  expect_true("extrapackage" %in% pkg_extra)
  expect_false("extrapackage" %in% pkg_blank)
  # all blank are in extra
  expect_true(all(pkg_blank %in% pkg_extra))
  # there are extra not in blank
  expect_equal(setdiff(pkg_extra, pkg_blank), c("extrapackage"))
})

# reference cannot work because it is system and R version dependent
# test_that("create_renv_for_dev works", {
#   expect_equal_to_reference(names(pkg_extra),"my_renv.test")
#   expect_equal_to_reference(names(pkg_blank),"my_renv_blank.test")
# })

# Test for extra and "_default" in interactive ----
test_that("_default works", {
  skip_if_not(interactive())

  lock_includes_extra_default<- file.path(tmpdir, "for_extra_default.lock")
  expect_message({my_renv_extra_default <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = c("_default", "extrapackage"),
      output = lock_includes_extra_default)}
    # "There is no directory named: dev, data-raw" # cli
  )

  expect_true(file.exists(lock_includes_extra_default))
  expect_true(file.exists(my_renv_extra_default))

  local_renv_extra_default <- getFromNamespace("lockfile", "renv")(my_renv_extra_default)
  expect_s3_class(local_renv_extra_default, "renv_lockfile_api")

  pkg_extra_default <- names(local_renv_extra_default$data()$Packages)
  expect_true("extrapackage" %in% pkg_extra_default)
  # all extra are in extra_default
  expect_true(all(pkg_extra %in% pkg_extra_default))
  # devtools and fusen are in extra_default
  expect_true(all(c("devtools", "fusen") %in% pkg_extra_default))
})

# Test for "folder_to_include" in dummypackage ----
dir.create(file.path(dummypackage, "dev"))
cat("library(glue)", file = file.path(dummypackage, "dev", "my_r.R"))
cat("```{r}\nlibrary(\"extrapackage\")\n```", file = file.path(dummypackage, "dev", "my_rmd.Rmd"))

test_that("folder_to_include works", {

  lock_includes_devdir <- file.path(tmpdir, "for_devdir.lock")
  expect_message({my_renv_devdir <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      output = lock_includes_devdir,
      force = TRUE)}
    # "There is no directory named: data-raw" # cli
  )

  expect_true(file.exists(lock_includes_devdir))
  expect_true(file.exists(my_renv_devdir))

  local_renv_devdir <- getFromNamespace("lockfile", "renv")(my_renv_devdir)
  expect_s3_class(local_renv_devdir, "renv_lockfile_api")

  pkg_devdir <- names(local_renv_devdir$data()$Packages)
  # glue and extrapackage in dev/ are there
  expect_true(all(c("glue", "extrapackage") %in% pkg_devdir))
})

# Test pkg_ignore works ----
# extrapackage is in "dev/" but I want it to be ignored
test_that("create_renv_(pkg_ignore) works", {

  lock_includes_ignore <- file.path(tmpdir, "for_ignore.lock")
  expect_message({my_renv_ignore <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      output = lock_includes_ignore,
      pkg_ignore = "extrapackage",
      force = TRUE)}
  )

  expect_true(file.exists(lock_includes_ignore))
  expect_true(file.exists(my_renv_ignore))

  local_renv_ignore <- getFromNamespace("lockfile", "renv")(my_renv_ignore)
  expect_s3_class(local_renv_ignore, "renv_lockfile_api")

  pkg_ignore <- names(local_renv_ignore$data()$Packages)
  # glue and  in dev/ are there
  expect_true(all(c("glue") %in% pkg_ignore))
  # extrapackage is ignored in dev/
  expect_false(all(c("extrapackage") %in% pkg_ignore))
})

remove.packages("extrapackage")
unlink(tmpdir, recursive = TRUE)
