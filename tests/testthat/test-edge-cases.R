# Detection edge cases: issues #120, #128, #129, #132
# See tests/testthat/f_edge_cases.R for the fixture.

res_edge <- att_from_rscript(path = "f_edge_cases.R")

must_find <- c(
  "dplyr", "findedge1", "findedge2", "findedge3", "glue", "stringr",
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
