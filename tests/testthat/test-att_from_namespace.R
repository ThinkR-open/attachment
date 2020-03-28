# test on dummy package
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
 recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
deps <- att_from_namespace(path = file.path(dummypackage, "NAMESPACE"))

test_that("att_from_namespace works", {
  expect_true(setequal(deps, c("magrittr")))
})

unlink(dummypackage, recursive = TRUE)

# File that failed in the past
deps <- att_from_namespace("fake_namespace", document = FALSE)

test_that("att_from_namespace works", {
  expect_true(setequal(deps, c("Rcpp", "magrittr")))
})
