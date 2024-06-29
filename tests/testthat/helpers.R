test_that("Package version required", {

  # Check the version of the package roxygen2 to take into account the breaking change.
  expect_true(packageVersion("roxygen2") > "7.1.2")

})
