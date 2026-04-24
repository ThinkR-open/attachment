# Install missing package from DESCRIPTION

Install missing package from DESCRIPTION

## Usage

``` r
install_from_description(
  path = "DESCRIPTION",
  field = c("Depends", "Imports", "Suggests"),
  ...
)
```

## Arguments

- path:

  path to the DESCRIPTION file

- field:

  DESCRIPTION fields to parse, "Depends", "Imports", "Suggests" by
  default

- ...:

  Arguments to be passed to
  [`utils::install.packages()`](https://rdrr.io/r/utils/install.packages.html)

## Value

Used for side effect. Installs R packages from DESCRIPTION file if
missing.

## Examples

``` r
if (FALSE) { # \dontrun{
# This will install packages on your system
dummypackage <- system.file("dummypackage", package = "attachment")
# browseURL(dummypackage)

install_from_description(path = file.path(dummypackage, "DESCRIPTION"))
} # }
```
