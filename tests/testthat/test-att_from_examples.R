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
