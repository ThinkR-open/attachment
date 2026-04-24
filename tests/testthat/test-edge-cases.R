# Detection edge cases: issues #120, #128, #129, #132
# See tests/testthat/f_edge_cases.R for the fixture.

res_edge <- att_from_rscript(path = "f_edge_cases.R")

must_find <- c(
  "findedge0", "findedge1", "findedge2", "findedge3", "glue", "stringr",
  "findedge4", "findedge5", "findedge6", "findedge7",
  "findedge8", "findedge9", "findedge10",
  "findedge11", "findedge12"
)
must_not_find <- c(
  "dontfind_a", "dontfind_b", "dontfind_c", "dontfind_d", "dontfind_e", "dontfind_f",
  "sibling", "label", "s"
)

test_that("edge cases: all true positives detected", {
  for (pkg in must_find) {
    expect_true(pkg %in% res_edge, info = paste("should detect", pkg))
  }
})

test_that("edge cases: no false positives from strings or comments", {
  for (pkg in must_not_find) {
    expect_false(pkg %in% res_edge, info = paste("should NOT detect", pkg))
  }
})

test_that("edge cases: base still filtered", {
  expect_false("base" %in% res_edge)
})

test_that("fully-qualified intro calls detect the inner package", {
  tf <- tempfile(fileext = ".R")
  on.exit(unlink(tf))
  writeLines(c(
    'base::library(findqual1)',
    'base::require(findqual2)',
    'base::requireNamespace("findqual3")',
    'base::loadNamespace("findqual4")',
    'methods::getFromNamespace("fn", "findqual5")'
  ), tf)
  res <- att_from_rscript(tf)
  for (pkg in paste0("findqual", 1:5)) {
    expect_true(pkg %in% res, info = paste("should detect", pkg))
  }
  expect_false("base" %in% res)
})

test_that("legacy fallback preserves underscores in package names", {
  # `a::b::c` is not valid R, so parse() fails and the legacy regex
  # detector is invoked with a warning. Underscored names must survive.
  tf <- tempfile(fileext = ".R")
  on.exit(unlink(tf))
  writeLines(c(
    'my_pkg_with_under_score::fn()',
    'library(pkg_one_two)',
    'a::b::c'   # parse error triggers fallback
  ), tf)
  res <- suppressWarnings(att_from_rscript(tf))
  expect_true("my_pkg_with_under_score" %in% res)
  expect_true("pkg_one_two" %in% res)
})
