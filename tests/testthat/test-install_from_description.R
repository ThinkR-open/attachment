context("install_from_description")
dummypackage <- system.file("dummypackage", package = "attachment")
install_from_description(path = file.path(dummypackage,"DESCRIPTION"), field = "Depends")

test_that("install_from_description works", {
  expect_message(
    install_from_description(
      path = file.path(dummypackage,"DESCRIPTION"), field = "Depends"),
    'All required packages are installed'
  )
})
