# Issue #106: att_from_rmd() should auto-detect whether it is called
# from inside a knit session, so the user does not have to pass inside_rmd.

test_that("inside_rmd = NULL auto-detects outside knit", {
  skip_if_not(file.exists("f1.Rmd"))
  expect_silent(
    res <- attachment::att_from_rmd(path = "f1.Rmd", inside_rmd = NULL)
  )
  expect_true(length(res) > 0)
})

test_that("inside_rmd defaults to NULL (auto-detect)", {
  default_val <- formals(attachment::att_from_rmd)$inside_rmd
  expect_true(is.null(default_val))
})

test_that("inside_rmd auto-detects TRUE when knitr out.format is set", {
  skip_if_not(file.exists("f1.Rmd"))
  withr::defer(knitr::opts_knit$restore())
  knitr::opts_knit$set(out.format = "markdown")
  expect_silent(
    res <- attachment::att_from_rmd(path = "f1.Rmd")
  )
  expect_true(length(res) > 0)
})
