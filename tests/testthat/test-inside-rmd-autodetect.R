# Issue #106: att_from_rmd() should auto-detect whether it is called
# from inside a knit session, so the user does not have to pass inside_rmd.

test_that("inside_rmd defaults to NULL (auto-detect)", {
  default_val <- formals(attachment::att_from_rmd)$inside_rmd
  expect_null(default_val)
})

test_that("inside_rmd = NULL outside knit returns package deps", {
  skip_if_not(file.exists("f1.Rmd"))
  res <- suppressMessages(suppressWarnings(
    attachment::att_from_rmd(path = "f1.Rmd", inside_rmd = NULL)
  ))
  expect_type(res, "character")
  expect_gt(length(res), 0)
})

test_that("auto-detect reads knitr::opts_knit$get('out.format')", {
  # Unit-level check of the detection expression used by att_from_rmd():
  # outside a knit session it must be NULL, and once out.format is set it
  # must be non-NULL. We do NOT re-run the purl pipeline here because that
  # spawns an external Rscript via system() and would make the test slow
  # and OS-dependent.
  expect_null(knitr::opts_knit$get("out.format"))

  withr::defer(knitr::opts_knit$restore())
  knitr::opts_knit$set(out.format = "markdown")
  expect_false(is.null(knitr::opts_knit$get("out.format")))
})
