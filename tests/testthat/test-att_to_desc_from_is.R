# Note: glue is necessary for {attachment}, ggplot2 is not even in suggests.

# missing pkg in R is not installed ----
test_that("missing pkg is not installed", {
  # Copy package in a temporary directory
  tmpdir <- tempfile("dummy")
  dir.create(tmpdir)
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")
  # browseURL(dummypackage)

  cat("
#' Function
#' @importFrom ggplot ggplot
#' @export
my_fun <- function() {
data %>%
filter(col == 3) %>%
mutate(new_col = 1) %>%
ggplot() +
  aes(x, y, colour = new_col) +
  geom_point()
}
", file = file.path(dummypackage, "R", "function.R"))

 expect_error(attachment::att_amend_desc(path = dummypackage),
              "The package ggplot is missing or more probably misspelled.")

 # Clean after
 unlink(dummypackage)
})

# missing pkgS are not installed ----
test_that("missing pkgS are not installed", {

  # Copy package in a temporary directory
  tmpdir <- tempfile("dummy")
  dir.create(tmpdir)
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")

  cat("
#' Function
#' @importFrom ggplot ggplot
#' @importFrom ggplot3 ggplot
# @importFrom ggplot4 ggplot # Only comment, not used
#' @export
my_fun <- function() {
data %>%
filter(col == 3) %>%
mutate(new_col = 1) %>%
ggplot() +
  aes(x, y, colour = new_col) +
  geom_point()
}
", file = file.path(dummypackage, "R", "function.R"))

  expect_error(attachment::att_amend_desc(path = dummypackage),
               "Packages ggplot & ggplot3 are missing or more probably misspelled.")

  # Clean after
  unlink(dummypackage)
})

# missing pkg in vignette (Suggests) is not installed ----

test_that("missing pkg is not installed", {
  # Copy package in a temporary directory
  tmpdir <- tempfile("dummy")
  dir.create(tmpdir)
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")
  # browseURL(dummypackage)

  cat("
## The vignette
```{r}
library(glue)
library(ggplot3)
```
", file = file.path(dummypackage, "vignettes", "vignette.Rmd"))

  expect_error(attachment::att_amend_desc(path = dummypackage),
               "The package ggplot3 is missing or more probably misspelled.")

  # Clean after
  unlink(dummypackage)
})
