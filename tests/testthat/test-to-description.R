# att_amend_desc ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_amend_desc(path = dummypackage)
desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
namespace_file <- readLines(file.path(tmpdir, "dummypackage", "NAMESPACE"))

test_that("att_amend_desc updates namespace", {
  expect_length(namespace_file, 4)
})

test_that("att_amend_desc updates description", {
  # person() can be 1 or 4 lines depending on {desc} version
  w.depends <- grep("Depends:", desc_file)
  expect_length(w.depends, 1)
  expect_equal(desc_file[w.depends + 1], "    R (>= 3.5.0)")
  expect_equal(desc_file[w.depends + 2], "Imports: ")
  expect_equal(desc_file[w.depends + 3], "    magrittr,")
  expect_equal(desc_file[w.depends + 4], "    stats")
  expect_equal(desc_file[w.depends + 5], "Suggests: ")
  expect_equal(desc_file[w.depends + 6], "    glue,")
  expect_equal(desc_file[w.depends + 7], "    knitr,")
  expect_equal(desc_file[w.depends + 8], "    rmarkdown,")
  expect_equal(desc_file[w.depends + 9], "    testthat")
  expect_equal(desc_file[w.depends + 10], "LinkingTo:" )
  expect_equal(desc_file[w.depends + 11], "    Rcpp")
  # base does not appear
  expect_false(all(grepl("base", desc_file)))
  # utils is removed
  expect_false(all(grepl("utils", desc_file)))
})
unlink(dummypackage, recursive = TRUE)

# Remotes stays here if exists ----
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
path.d <- file.path(dummypackage, "DESCRIPTION")
cat(
"Remotes:
    thinkr-open/fusen,
    tidyverse/magrittr,
    rstudio/rmarkdown
", append = TRUE,
    file = path.d)

test_that("Remotes stays here if exists and package in imports/suggests", {
  suppressMessages(
    expect_error(att_amend_desc(path = dummypackage), regexp = NA))
  desc_file <- readLines(file.path(dummypackage, "DESCRIPTION"))

  expect_false(any(grepl("thinkr-open/fusen", desc_file))) # not in deps
  w.remotes <- grep('Remotes:', desc_file)
  expect_length(w.remotes, 1)
  expect_equal(desc_file[w.remotes + 1], "    rstudio/rmarkdown,") #suggest
  expect_equal(desc_file[w.remotes + 2], "    tidyverse/magrittr") #imports
})
unlink(dummypackage, recursive = TRUE)

# pkg_ignore and extra.suggests are used ----
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

test_that("pkg_ignore and extra.suggests are used", {
  suppressMessages(
    expect_error(
      att_amend_desc(path = dummypackage,
                     pkg_ignore = "glue",
                     extra.suggests = "roxygen2"),
      regexp = NA)
  )
  desc_file <- readLines(file.path(dummypackage, "DESCRIPTION"))

  expect_false(any(grepl("glue", desc_file))) # ignored totally
  w.suggests <- grep('Suggests:', desc_file)
  expect_length(w.suggests, 1)
  expect_equal(desc_file[w.suggests + 3], "    roxygen2,") #suggest
})
unlink(dummypackage, recursive = TRUE)

# Test fails if dir.t do not exists
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

test_that("fails if dir.t do not exists", {
    expect_message(
      att_amend_desc(path = dummypackage,
                     dir.r = c("R", "rara")),
      regexp = "There is no directory named: rara")

  expect_message(
    att_amend_desc(path = dummypackage,
                   dir.v = c("vignettes", "vava")),
    regexp = "There is no directory named: vava")

  expect_message(
    att_amend_desc(path = dummypackage,
                   dir.v = c("tests", "tata")),
    regexp = "There is no directory named: tata")
})
unlink(dummypackage, recursive = TRUE)

# Test Deprecated att_to_description ----
# suppressWarnings()
# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
suppressWarnings(att_to_description(path = dummypackage))
desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
namespace_file <- readLines(file.path(tmpdir, "dummypackage", "NAMESPACE"))

test_that("att_to_description still updates namespace", {
  expect_length(namespace_file, 4)
})
unlink(dummypackage, recursive = TRUE)


# att_to_desc_from_is ----
# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
                    imports = c("magrittr", "attachment"), suggests = c("knitr"))

desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))

test_that("att_to_desc_from_is updates description", {
  # person() can be 1 or 4 lines depending on {desc} version
  w.depends <- grep("Depends:", desc_file)
  expect_length(w.depends, 1)
  expect_equal(desc_file[w.depends], "Depends: ")
  expect_equal(desc_file[w.depends + 1], "    R (>= 3.5.0)")
  expect_equal(desc_file[w.depends + 2], "Imports: ")
  expect_equal(desc_file[w.depends + 3], "    attachment,")
  expect_equal(desc_file[w.depends + 4], "    magrittr")
  expect_equal(desc_file[w.depends + 5], "Suggests: ")
  expect_equal(desc_file[w.depends + 6], "    knitr")
  expect_equal(desc_file[w.depends + 7], "LinkingTo:" )
  expect_equal(desc_file[w.depends + 8], "    Rcpp")
})
unlink(dummypackage, recursive = TRUE)



# Test missing DESCRIPTION works ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
file.remove(file.path(dummypackage, "DESCRIPTION"))
test_that("Works with missing DESCRIPTION", {
  expect_false(file.exists(file.path(dummypackage, "DESCRIPTION")))
  expect_message(att_amend_desc(path = dummypackage), "use_description")
  expect_true(file.exists(file.path(dummypackage, "DESCRIPTION")))
  desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
  expect_true(grepl("dummypackage", desc_file[1]))
  expect_false(any(grepl("dummypackage", desc_file[-1])))

  file.remove(file.path(dummypackage, "DESCRIPTION"))
  expect_false(file.exists(file.path(dummypackage, "DESCRIPTION")))
  expect_message(att_to_desc_from_is(path = file.path(dummypackage, "DESCRIPTION"),
                                     imports = c("magrittr")), "use_description")
  expect_true(file.exists(file.path(dummypackage, "DESCRIPTION")))
  desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
  expect_true(grepl("dummypackage", desc_file[1]))
  expect_false(any(grepl("dummypackage", desc_file[-1])))
})

# Test missing NAMESPACE works ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
file.remove(file.path(dummypackage, "NAMESPACE"))
test_that("Works with missing DESCRIPTION", {
  expect_false(file.exists(file.path(dummypackage, "NAMESPACE")))
  expect_error(att_from_namespace(file.path(dummypackage, "NAMESPACE")), "attachment::att_amend_desc()")

  expect_message(att_amend_desc(path = dummypackage, document = FALSE),
                 "no directory named: NAMESPACE")
  expect_false(file.exists(file.path(dummypackage, "NAMESPACE")))

  expect_message(att_amend_desc(path = dummypackage), "new path.n")
  expect_true(file.exists(file.path(dummypackage, "NAMESPACE")))

})

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
               "The package ggplot is missing or misspelled.")

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
               "Packages ggplot & ggplot3 are missing or misspelled.")

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
               "The package ggplot3 is missing or misspelled.")

  # Clean after
  unlink(dummypackage)
})

# Test update desc when missing packages for books ----
tmpdir <- tempfile("miss")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"),
          tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

test_that("att_to_desc_from_is can update DESCRIPTION w/o uninstalled packages", {
  imports <- unique(
    c("fakeinstalled", # Not exists
      "bookdown", "knitr",
      "pagedown", # Not installed on CI usually
      att_from_rmds(file.path(dummypackage, "vignettes"), recursive = FALSE))
  )
  # Default to error
  expect_error(att_to_desc_from_is(
    path.d = file.path(dummypackage, "DESCRIPTION"),
    imports = imports
  ), regexp = "missing or misspelled")

  # must.exist = FALSE
  expect_warning(
    att_to_desc_from_is(
      path.d = file.path(dummypackage, "DESCRIPTION"),
      imports = imports,
      must.exist = NA # then warning
    ),
    regexp = "missing or misspelled")

  expect_warning(
    expect_error(
      att_to_desc_from_is(
        path.d = file.path(dummypackage, "DESCRIPTION"),
        imports = imports,
        must.exist = FALSE # then no error, no warning
      ), regexp = NA),
    regexp = NA)

  desc <- readLines(file.path(file.path(dummypackage, "DESCRIPTION")))
  expect_true(any(grepl("fakeinstalled", desc)))
  expect_true(any(grepl("bookdown", desc)))
  expect_true(any(grepl("knitr", desc)))
  expect_true(any(grepl("pagedown", desc)))
})
unlink(tmpdir, recursive = TRUE)
