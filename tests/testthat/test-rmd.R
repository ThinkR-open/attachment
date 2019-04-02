context("test-rmd.R")

test_that("rmd well parsed", {

  res <- sort(attachment::att_from_rmds(path = "."))


  expect_equal(sort(res),

               sort(
                 c("find.me",
                   # "attachment",
                   "knitr",
                   "findme1",
                   "findme2",
                   "findme3",
                   "findme4",
                   "findme5",
                   "findme6",
                   "findme1a",
                   "findme2a",
                   "findme3a",
                   "findme4a",
                   "findme5a",
                   "findme6a"
                 )

               ))


  })
