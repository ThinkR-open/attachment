# Amend DESCRIPTION with dependencies read from package code parsing

Amend package DESCRIPTION file with the list of dependencies extracted
from R, examples, tests, vignettes files. att_to_desc_from_pkg() is an
alias of att_amend_desc(), for the correspondence with
[`att_to_desc_from_is()`](https://thinkr-open.github.io/attachment/reference/att_to_desc_from_is.md).

## Usage

``` r
att_amend_desc(
  path = ".",
  path.n = "NAMESPACE",
  path.d = "DESCRIPTION",
  dir.r = "R",
  dir.v = "vignettes",
  dir.t = "tests",
  extra.suggests = NULL,
  pkg_ignore = NULL,
  document = TRUE,
  normalize = TRUE,
  inside_rmd = NULL,
  must.exist = TRUE,
  check_if_suggests_is_installed = TRUE,
  update.config = FALSE,
  use.config = TRUE,
  path.c = "dev/config_attachment.yaml"
)

att_to_desc_from_pkg(
  path = ".",
  path.n = "NAMESPACE",
  path.d = "DESCRIPTION",
  dir.r = "R",
  dir.v = "vignettes",
  dir.t = "tests",
  extra.suggests = NULL,
  pkg_ignore = NULL,
  document = TRUE,
  normalize = TRUE,
  inside_rmd = NULL,
  must.exist = TRUE,
  check_if_suggests_is_installed = TRUE,
  update.config = FALSE,
  use.config = TRUE,
  path.c = "dev/config_attachment.yaml"
)
```

## Arguments

- path:

  path to the root of the package directory. Default to current
  directory.

- path.n:

  path to namespace file.

- path.d:

  path to description file.

- dir.r:

  path to directory with R scripts.

- dir.v:

  path to vignettes directory. Set to empty (dir.v = "") to ignore.

- dir.t:

  path to tests directory. Set to empty (dir.t = "") to ignore.

- extra.suggests:

  vector of other packages that should be added in Suggests (pkgdown,
  covr for instance)

- pkg_ignore:

  vector of packages names to ignore.

- document:

  Run function roxygenise of roxygen2 package

- normalize:

  Logical. Whether to normalize the DESCRIPTION file. See
  [`desc::desc_normalize()`](https://desc.r-lib.org/reference/desc_normalize.html)

- inside_rmd:

  Logical or `NULL`. Whether the function is being called from inside a
  knit session, in which case the actual purl step must be delegated to
  an external R process. When `NULL` (the default), this is
  auto-detected via `knitr::opts_knit$get("out.format")`.

- must.exist:

  Logical. If TRUE then an error is given if packages do not exist
  within installed packages. If NA, a warning.

- check_if_suggests_is_installed:

  Logical. Whether to require that packages in the Suggests section are
  installed.

- update.config:

  logical. Should the parameters used in this call be saved in the
  config file of the package

- use.config:

  logical. Should the command use the parameters from the config file to
  run

- path.c:

  character Path to the yaml config file where parameters are saved

## Value

Update DESCRIPTION file.

## Details

Your daily use is to run `att_amend_desc()`, as is. You will want to run
this function sometimes with some extra information like
`att_amend_desc(pkg_ignore = "x", update.config = TRUE)` if you have to
update the configuration file. Next time `att_amend_desc()` will use
these parameters from the configuration file directly.

## Examples

``` r

# Run on an external "dummypackage" as an example
# For your local use, you do not have to specify the `path` as below
# By default, `att_amend_desc()` will run on the current working directory

# Create a fake package for the example
tmpdir <- tempfile(pattern = "description")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
 recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")

# Update documentation and dependencies
att_amend_desc(path = dummypackage)
#> Saving attachment parameters to yaml config file
#> Updating dummypackage documentation
#> ℹ Setting Config/roxygen2/version to "8.0.0"
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.

# You can look at the content of this external package
#' # browseURL(dummypackage)

# Update the config file with extra parameters
# We recommend that you store this code in a file in your "dev/" directory
# to run it when needed
att_amend_desc(path = dummypackage, extra.suggests = "testthat", update.config = TRUE)
#> 'update.config' was set to TRUE, hence, 'use.config' was forced to FALSE
#> Saving attachment parameters to yaml config file
#> Updating dummypackage documentation
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.

# Next time, in your daily development
att_amend_desc(path = dummypackage)
#> Documentation parameters were restored from attachment config file.
#> Updating dummypackage documentation
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.

# Clean after examples
unlink(tmpdir, recursive = TRUE)
```
