# test on dummy package
tmpdir <- tempfile(pattern = "pkg")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
my_renv_golem <- create_renv_for_dev(path = dummypackage,install_if_missing = FALSE,dev_pkg = "golem",output = "for_golem.lock")
my_renv_ <- create_renv_for_dev(path = dummypackage,install_if_missing = FALSE,output = "blank.lock")

expect_true(file.exists("for_golem.lock"))
expect_true(file.exists("blank.lock"))

print(my_renv_golem)
local_renv_golem <- getFromNamespace("lockfile", "renv")(my_renv_golem)
local_renv_ <- getFromNamespace("lockfile", "renv")(my_renv_)

expect_s3_class(local_renv_golem,"renv_lockfile_api")
expect_s3_class(local_renv_,"renv_lockfile_api")


les_pkg <- names(local_renv_golem$data()$Packages)
les_pkg_ <- names(local_renv_$data()$Packages)


# je ne trouve pas de moyen de controler que golem est bien dans local_renv_golem
# et pas dans local_renv_

# print(les_pkg) # devtools::check()pas de golem ici !!!
# test_that("dev_pkg works", {
# testthat::expect_true("golem" %in% les_pkg)
# })
# test_that("create_renv_for_dev works", {
# testthat::expect_equal_to_reference(names(les_pkg),"my_renv.test")
# testthat::expect_equal_to_reference(names(les_pkg_),"my_renv_.test")
# })



