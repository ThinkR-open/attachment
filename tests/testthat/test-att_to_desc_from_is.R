test_that("missing pkg is not installed", {
  library(usethis)
  pkg_path <- tempfile(pattern = "pkg.")
  dir.create(pkg_path)
  usethis::create_package(pkg_path, open = FALSE)
  cat("
#' Function
#' @importFrom dplyr filter
#' @importFrom ggplot ggplot
# @importFrom ggplot3 ggplot
# @importFrom ggplot4 ggplot
#' @export
my_fun <- function() {
data %>%
filter(col == 3) %>%
mutate(new_col = 1) %>%
ggplot() +
  aes(x, y, colour = new_col) +
  geom_point()
}
", file = file.path(pkg_path, "R", "function.R"))

 expect_error(attachment::att_amend_desc(path = pkg_path))

})



test_that("missing pkgS are not installed", {

  pkg_path <- tempfile(pattern = "pkg.")
  dir.create(pkg_path)
  usethis::create_package(pkg_path, open = FALSE)
  cat("
#' Function
#' @importFrom dplyr filter
#' @importFrom ggplot ggplot
#' @importFrom ggplot3 ggplot
# @importFrom ggplot4 ggplot
#' @export
my_fun <- function() {
data %>%
filter(col == 3) %>%
mutate(new_col = 1) %>%
ggplot() +
  aes(x, y, colour = new_col) +
  geom_point()
}
", file = file.path(pkg_path, "R", "function.R"))

  expect_error(attachment::att_amend_desc(path = pkg_path))

})

