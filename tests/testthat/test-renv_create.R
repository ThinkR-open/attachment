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
my_renv <- create_renv_for_dev(path = dummypackage,install_if_missing = FALSE)
my_renv


local_renv <- getFromNamespace("lockfile", "renv")(my_renv)
les_pkg <- local_renv$data()$Packages
testthat::expect_equal_to_reference(names(les_pkg),"my_renv.test")
