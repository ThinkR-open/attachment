test_that("att_from_data works with a single package", {

  input1 <- 'data("starwars", package = "dplyr")'
  expect_equal(att_from_data(input1), "dplyr")

})

test_that("att_from_data works with multi package", {

  input1 <- 'data("starwars", package = "dplyr")data("dataset", package = "pkgfake")'
  expect_equal(att_from_data(input1), c("dplyr", "pkgfake"))

})


test_that("att_from_data works with extra spaces", {

  input1 <- 'data("starwars",package    = "dplyr")'
  expect_equal(att_from_data(input1), "dplyr")

})
