# Deprecated functions

List of functions deprecated. They will be removed in a future release.

## Usage

``` r
att_to_description(
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
  inside_rmd = FALSE
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

  Logical. Whether function is run inside a Rmd, in case this must be
  executed in an external R session

## Value

List of functions used for deprecation side effects. Output depends on
the deprecated function.

## Details

|  |  |
|----|----|
| `att_to_description` | is now called `att_amend_desc` so that it is the first function proposed when using auto-completion |
