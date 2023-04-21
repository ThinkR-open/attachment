# These tests can not run on CRAN
skip_on_cran()

if (length(find.package("extrapackage", quiet = TRUE)) != 0) {
  unlink(find.package("extrapackage", quiet = TRUE), recursive = TRUE)
}

# test on dummy package
tmpdir <- tempfile(pattern = "pkgrenv")
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
lock_includes_extra_dev <- file.path(tmpdir, "for_extra_dev.lock")
lock_without_extra_dev <- file.path(tmpdir, "blank_dev.lock")
lock_includes_extra_prod <- file.path(tmpdir, "for_extra_prod.lock")
lock_without_extra_prod <- file.path(tmpdir, "blank_prod.lock")

# if (interactive()) {
#   expect_message({my_renv_extra <-
#     create_renv_for_dev(
#       path = dummypackage,
#       install_if_missing = FALSE,
#       dev_pkg = "extrapackage",
#       output = lock_includes_extra_dev)}
#     # "There is no directory named: dev, data-raw" # cli
#   )
#   expect_message({
#     # message, but not missing directories as they are skipped
#     my_renv_blank <-
#       create_renv_for_dev(
#         path = dummypackage,
#         dev_pkg = NULL,
#         install_if_missing = FALSE,
#         output = lock_without_extra_dev)}
#   )
# } else {

  expect_message({

    my_renv_extra_dev <- create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = "extrapackage",
      output = lock_includes_extra_dev,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)}#,
    # "There is no directory named: dev, data-raw" # cli
  )
  expect_message({
    # message, but not missing directories as they are skipped
    my_renv_blank_dev <- create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = NULL,
      output = lock_without_extra_dev,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)})

  # renv for prod


  expect_message({
    my_renv_extra_prod <- create_renv_for_prod(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = "extrapackage",
      output = lock_includes_extra_prod,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)}#,
    # "There is no directory named: dev, data-raw" # cli
  )
  expect_message({
    # message, but not missing directories as they are skipped
    my_renv_blank_prod <- create_renv_for_prod(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = NULL,
      output = lock_without_extra_prod,
      # force generation of a lockfile even when pre-flight validation checks have failed?
      force = TRUE)})
# }


test_that("create_renv_for_dev creates lock files", {
  expect_true(file.exists(lock_includes_extra_dev))
  expect_true(file.exists(my_renv_extra_dev))
  expect_true(file.exists(lock_without_extra_dev))
  expect_true(file.exists(my_renv_blank_dev))
  expect_true(file.exists(lock_includes_extra_prod))
  expect_true(file.exists(my_renv_extra_prod))
  expect_true(file.exists(lock_without_extra_prod))
  expect_true(file.exists(my_renv_blank_prod))
})

# print(my_renv_extra)


local_renv_extra_dev <- getFromNamespace("lockfile", "renv")(my_renv_extra_dev)
local_renv_blank_dev <- getFromNamespace("lockfile", "renv")(my_renv_blank_dev)
local_renv_extra_prod <- getFromNamespace("lockfile", "renv")(my_renv_extra_prod)
local_renv_blank_prod <- getFromNamespace("lockfile", "renv")(my_renv_blank_prod)

test_that("lockfile are renv files", {
  expect_s3_class(local_renv_extra_dev, "renv_lockfile_api")
  expect_s3_class(local_renv_blank_dev, "renv_lockfile_api")
  expect_s3_class(local_renv_extra_prod, "renv_lockfile_api")
  expect_s3_class(local_renv_blank_prod, "renv_lockfile_api")
})

pkg_extra_dev <- names(local_renv_extra_dev$data()$Packages)
pkg_blank_dev <- names(local_renv_blank_dev$data()$Packages)
pkg_extra_prod <- names(local_renv_extra_prod$data()$Packages)
pkg_blank_prod <- names(local_renv_blank_prod$data()$Packages)

test_that("extrapackage is present thanks to dev_pkg", {

  #dev

  expect_true("extrapackage" %in% pkg_extra_dev)
  expect_false("extrapackage" %in% pkg_blank_dev)
  # all blank are in extra
  expect_true(all(pkg_blank_dev %in% pkg_extra_dev))
  # there are extra not in blank
  expect_equal(setdiff(pkg_extra_dev, pkg_blank_dev), c("extrapackage"))

  # prod
  expect_true("extrapackage" %in% pkg_extra_prod)
  expect_false("extrapackage" %in% pkg_blank_prod)
  # all blank are in extra
  expect_true(all(pkg_blank_prod %in% pkg_extra_prod))
  # there are extra not in blank
  expect_equal(setdiff(pkg_extra_prod, pkg_blank_prod), c("extrapackage"))
})

# reference cannot work because it is system and R version dependent
# test_that("create_renv_for_dev works", {
#   expect_equal_to_reference(names(pkg_extra),"my_renv.test")
#   expect_equal_to_reference(names(pkg_blank),"my_renv_blank.test")
# })

# Test for extra and "_default" in interactive ----
test_that("_default works", {
  skip_if_not(interactive()) # to pass devtools::check()

  lock_includes_extra_default<- file.path(tmpdir, "for_extra_default.lock")
  expect_message({my_renv_extra_default <-
    create_renv_for_dev(
      path = dummypackage,
      install_if_missing = FALSE,
      dev_pkg = c("_default", "glue"),
      output = lock_includes_extra_default)}
    # "There is no directory named: dev, data-raw" # cli
  )

  expect_true(file.exists(lock_includes_extra_default))
  expect_true(file.exists(my_renv_extra_default))

  local_renv_extra_default <- getFromNamespace("lockfile", "renv")(my_renv_extra_default)
  expect_s3_class(local_renv_extra_default, "renv_lockfile_api")

  pkg_extra_default <- names(local_renv_extra_default$data()$Packages)
  expect_true("glue" %in% pkg_extra_default)
  # all extra are in extra_default
  # expect_true(all(pkg_extra_dev %in% pkg_extra_default))
  # devtools and fusen are in extra_default
  expect_true(all(c("devtools", "fusen") %in% pkg_extra_default))
})

# Test for "folder_to_include" in dummypackage ----
dev_dir <- file.path(dummypackage, "dev")
if (!dir.exists(dev_dir)) {dir.create(dev_dir)}
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
test_that("DEV create_renv_(pkg_ignore) works", {

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
  expect_true(all(c("magrittr") %in% pkg_ignore))
  # extrapackage is ignored in dev/
  expect_false(all(c("extrapackage") %in% pkg_ignore))
})


# Test pkg_ignore works ----
# extrapackage is in "dev/" but I want it to be ignored
test_that("PROD create_renv_(pkg_ignore) works", {

  lock_includes_ignore <- file.path(tmpdir, "for_ignore.lock")
  expect_message({my_renv_ignore <-
    create_renv_for_prod(
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
  expect_false(all(c("glue") %in% pkg_ignore)) # in suggests only so not present
  expect_true(all(c("magrittr") %in% pkg_ignore))
  # extrapackage is ignored in dev/
  expect_false(all(c("extrapackage") %in% pkg_ignore))
})

# Clean userspace
remove.packages("extrapackage")
unlink(extrapackage, recursive = TRUE)
unlink(tmpdir, recursive = TRUE)
unlink(dummypackage, recursive = TRUE)


tmpdir <- tempfile("dummyrenv")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
desc_file <- file.path(dummypackage, "DESCRIPTION")
desc_lines <- readLines(desc_file)
# desc_lines <- c(desc_lines,"Suggests: \n    idontexist")
desc_lines[desc_lines == "Suggests: "] <- "Suggests: \n    idontexist,\n    withr,"
writeLines(desc_lines,desc_file)

test_that("suggested package are not in renv prod", {

  out_renv_file <- tempfile(pattern = "renv.lock.prod")

  create_renv_for_prod(
    document = FALSE,# to use the DESCRIPTION file we have created
    path = dummypackage,
    install_if_missing = FALSE,
    output = out_renv_file,
    # check_if_suggests_is_installed = FALSE,
    force = TRUE)

  base <- paste(readLines(out_renv_file),collapse = " ")
  expect_false(grepl(pattern = "idontexist",x = base))
  expect_false(grepl(pattern = "withr",x = base))
  expect_true(grepl(pattern = "magrittr",x = base))

  unlink(dummypackage, recursive = TRUE)
}
)













tmpdir <- tempfile("dummyrenvdev")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
desc_file <- file.path(dummypackage, "DESCRIPTION")
desc_lines <- readLines(desc_file)
# desc_lines <- c(desc_lines,"Suggests: \n    idontexist")
desc_lines[desc_lines == "Suggests: "] <- "Suggests: \n    idontexist,\n    withr,"
writeLines(desc_lines,desc_file)

test_that("suggested package are in renv dev", {

  lock_temp<- file.path(tmpdir, "temp.lock")

  my_renv <- create_renv_for_dev(
    document = FALSE, # to use the DESCRIPTION file we have created
    path = dummypackage,
    install_if_missing = FALSE,
    output =  lock_temp,
    # check_if_suggests_is_installed = TRUE,
    force = TRUE)

  expect_true(file.exists(lock_temp))
  expect_true(file.exists(my_renv))
  local_renv <- getFromNamespace("lockfile", "renv")(my_renv)
  expect_s3_class(local_renv, "renv_lockfile_api")
  pkg_local_renv <- names(local_renv$data()$Packages)

  base <- paste(pkg_local_renv,collapse = " ")
  # expect_true(grepl(pattern = "idontexist",x = base)) #renv dont install unistalled package
  expect_true(grepl(pattern = "withr",x = base)) # ici ca coince dans le check, mais ok dans le test
  expect_true(grepl(pattern = "magrittr",x = base))

  unlink(dummypackage, recursive = TRUE)

}
)






unlink(tmpdir, recursive = TRUE)


unlink(dummypackage, recursive = TRUE)


tmpdir <- tempfile("dummyrenvsuggest")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
desc_file <- file.path(dummypackage, "DESCRIPTION")
desc_lines <- readLines(desc_file)
# desc_lines <- c(desc_lines,"Suggests: \n    idontexist")
desc_lines[desc_lines == "Suggests: "] <- "Suggests: \n    idontexist,\n    withr,"
writeLines(desc_lines,desc_file)
cat("
## The vignette
```{r}
library(glue)
library(ggplot3)
```
", file = file.path(dummypackage, "vignettes", "vignette.Rmd"))


test_that("suggested package are not in renv prod even from vignettes", {

  out_renv_file <- tempfile(pattern = "renv.lock.prod")

  create_renv_for_prod(
    document = FALSE,# to use the DESCRIPTION file we have created
    path = dummypackage,
    install_if_missing = FALSE,
    output = out_renv_file,
    # check_if_suggests_is_installed = FALSE,
    force = TRUE)

  base <- paste(readLines(out_renv_file),collapse = " ")
  expect_false(grepl(pattern = "idontexist",x = base))
  expect_false(grepl(pattern = "withr",x = base))
  expect_false(grepl(pattern = "ggplot3",x = base))
  expect_false(grepl(pattern = "glue",x = base))
  expect_true(grepl(pattern = "magrittr",x = base))

  unlink(dummypackage, recursive = TRUE)
  file.remove(out_renv_file)
}
)




unlink(tmpdir, recursive = TRUE)


unlink(dummypackage, recursive = TRUE)


tmpdir <- tempfile("dummyrenvprod")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
desc_file <- file.path(dummypackage, "DESCRIPTION")
desc_lines <- readLines(desc_file)
# desc_lines <- c(desc_lines,"Suggests: \n    idontexist")
desc_lines[desc_lines == "Suggests: "] <- "Suggests: \n    idontexist,\n    withr,"
writeLines(desc_lines,desc_file)
cat("
## The vignette
```{r}
library(glue)
library(ggplot3)
```
", file = file.path(dummypackage, "vignettes", "vignette.Rmd"))


test_that("suggested package are not in renv prod even from vignettes", {

  out_renv_file <- tempfile(pattern = "renv.lock.prod")

  create_renv_for_prod(
    document = TRUE,
    path = dummypackage,
    install_if_missing = FALSE,
    output = out_renv_file,
    # check_if_suggests_is_installed = FALSE,
    force = TRUE)

  base <- paste(readLines(out_renv_file),collapse = " ")
  expect_false(grepl(pattern = "idontexist",x = base))
  expect_false(grepl(pattern = "withr",x = base))
  expect_false(grepl(pattern = "ggplot3",x = base))
  expect_false(grepl(pattern = "glue",x = base))
  expect_true(grepl(pattern = "magrittr",x = base))

  unlink(dummypackage, recursive = TRUE)
  file.remove(out_renv_file)
}
)


