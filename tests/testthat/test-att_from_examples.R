test_that("att_from_examples works", {
  tmpdir <- tempfile("suggestexamples")

  dir.create(file.path(tmpdir, "R"), recursive = TRUE)

  r_file <- file.path(tmpdir, "R", "fun_manual.R")
  file.create(r_file)

  writeLines(
    text = "#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' fakepkg::fun()
#' @export
my_length <- function(x) {
  x %>% length()
}",
    con = r_file
  )

  expect_equal(att_from_examples(dir.r = file.path(tmpdir, "R")),
               c("magrittr", "fakepkg"))

})


test_that("att_from_examples works with escape characters", {
  tmpdir <- tempfile("suggestexamples")

  dir.create(file.path(tmpdir, "R"), recursive = TRUE)

  r_file <- file.path(tmpdir, "R", "fun_manual.R")
  file.create(r_file)

  writeLines(
    text = "#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' fakepkg::fun()
#' 1 %not_in% 1:10
#' not_null(NULL)
`%not_in%` <- Negate(`%in%`)
",
    con = r_file
  )

  expect_equal(att_from_examples(dir.r = file.path(tmpdir, "R")),
               c("magrittr", "fakepkg"))

})


test_that("att_from_examples works even with sysdata.rda", {
  tmpdir <- tempfile("suggestexamples")

  dir.create(file.path(tmpdir, "R"), recursive = TRUE)

  r_file <- file.path(tmpdir, "R", "fun_manual.R")
  file.create(r_file)

  writeLines(
    text = "#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' fakepkg::fun()
#' @export
my_length <- function(x) {
  x %>% length()
}",
    con = r_file
  )

  save(iris,file = file.path(tmpdir,"R","sysdata.rda"),compress = "bzip2",version = 3,ascii = FALSE)

  expect_equal(att_from_examples(dir.r = file.path(tmpdir, "R")),
               c("magrittr", "fakepkg"))

})



test_that("att_from_examples works with dontrun", {
  tmpdir <- tempfile("suggestexamples")

  dir.create(file.path(tmpdir, "R"), recursive = TRUE)

  file.copy(test_path("fake_function.R"),file.path(tmpdir, "R"))

  expect_equal(att_from_examples(dir.r = file.path(tmpdir, "R")),
               c("magrittr", "fakepkg"))

})
