# install packages if missing

install packages if missing

## Usage

``` r
install_if_missing(to_be_installed, ...)
```

## Arguments

- to_be_installed:

  a character vector containing required packages names

- ...:

  Arguments to be passed to
  [`utils::install.packages()`](https://rdrr.io/r/utils/install.packages.html)

## Value

Used for side effect. Install missing packages from the character vector
input.

## Examples

``` r
if (FALSE) { # \dontrun{
# This will install packages on your system
install_if_missing(c("dplyr", "fcuk", "rusk"))
} # }
```
