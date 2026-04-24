# Amend DESCRIPTION with dependencies from imports and suggests package list

Amend DESCRIPTION with dependencies from imports and suggests package
list

## Usage

``` r
att_to_desc_from_is(
  path.d = "DESCRIPTION",
  imports = NULL,
  suggests = NULL,
  check_if_suggests_is_installed = TRUE,
  normalize = TRUE,
  must.exist = TRUE
)
```

## Arguments

- path.d:

  path to description file.

- imports:

  character vector of package names to add in Imports section

- suggests:

  character vector of package names to add in Suggests section

- check_if_suggests_is_installed:

  Logical. Whether to require that packages in the Suggests section are
  installed.

- normalize:

  Logical. Whether to normalize the DESCRIPTION file. See
  [`desc::desc_normalize()`](https://desc.r-lib.org/reference/desc_normalize.html)

- must.exist:

  Logical. If TRUE then an error is given if packages do not exist
  within installed packages. If NA, a warning.

## Value

Fill in Description file

## Details

`must.exist` is better set to `TRUE` during package development. This
stops the process when a package does not exists on your system. This
avoids check errors with typos in package names in DESCRIPTION. When
used in CI to discover dependencies, for a bookdown for instance, you
may want to set to `FALSE` (no message at all) or `NA` (warning for not
installed).

## Examples

``` r
tmpdir <- tempfile(pattern = "descfromis")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
 recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
imports = c("magrittr", "attachment"), suggests = c("knitr"))
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.
#> [-] 6 package(s) removed: stats, glue, rmarkdown, testthat, utils, stringr.
#> [+] 1 package(s) added: attachment.

# In combination with other functions
att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
imports = att_from_rscripts(file.path(dummypackage, "R")),
suggests = att_from_rmds(file.path(dummypackage, "vignettes")))
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.
#> [-] 2 package(s) removed: attachment, magrittr.
#> [+] 3 package(s) added: stats, glue, rmarkdown.

# Clean temp files after this example
unlink(tmpdir, recursive = TRUE)
```
