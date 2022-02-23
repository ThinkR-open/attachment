# test on dummy package
tmpdir <- tempfile(pattern = "pkg")
dir.create(tmpdir)
file.copy(
  system.file("dummypackage", package = "attachment"), tmpdir,
  recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
print("ici")
print(dummypackage)
# Sys.sleep(525)
my_renv_golem <- create_renv_for_dev(path = dummypackage,install_if_missing = FALSE,dev_pkg = "golem")
my_renv_golem


local_renv_golem <- getFromNamespace("lockfile", "renv")(my_renv_golem)
local_renv_golem
les_pkg <- names(local_renv_golem$data()$Packages)


test_that("dev_pkg works", {
testthat::expect_true("golem" %in% les_pkg)
})
test_that("create_renv_for_dev works", {
testthat::expect_equal_to_reference(names(les_pkg),"my_renv.test")
})



