# Issue #131: quarto .qmd vignettes should not force `rmarkdown` into Suggests.

make_vignettes_dir <- function(exts) {
  d <- tempfile(pattern = "vig")
  dir.create(file.path(d, "vignettes"), recursive = TRUE)
  for (ext in exts) {
    f <- file.path(d, "vignettes", paste0("demo_", ext, ".", ext))
    writeLines(c(
      "---",
      "title: demo",
      "---",
      "",
      "```{r}",
      "library(findme.quarto)",
      "```"
    ), f)
  }
  file.path(d, "vignettes")
}

test_that("qmd-only vignettes dir yields quarto but not rmarkdown", {
  p <- make_vignettes_dir("qmd")
  res <- attachment::att_from_rmds(path = p)
  expect_true("knitr" %in% res)
  expect_true("quarto" %in% res)
  expect_false("rmarkdown" %in% res)
  unlink(dirname(p), recursive = TRUE)
})

test_that("Rmd-only vignettes dir still yields rmarkdown (backwards compat)", {
  p <- make_vignettes_dir("Rmd")
  res <- attachment::att_from_rmds(path = p)
  expect_true("knitr" %in% res)
  expect_true("rmarkdown" %in% res)
  expect_false("quarto" %in% res)
  unlink(dirname(p), recursive = TRUE)
})

test_that("mixed qmd + Rmd vignettes dir yields both engines", {
  p <- make_vignettes_dir(c("qmd", "Rmd"))
  res <- attachment::att_from_rmds(path = p)
  expect_true("knitr" %in% res)
  expect_true("quarto" %in% res)
  expect_true("rmarkdown" %in% res)
  unlink(dirname(p), recursive = TRUE)
})
