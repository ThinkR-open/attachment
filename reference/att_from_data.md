# Look for functions called in data loading code

Look for functions called in data loading code

## Usage

``` r
att_from_data(chr)
```

## Arguments

- chr:

  A character vector containing the code as a string. The code should
  follow the pattern used for loading data with
  [`data()`](https://rdrr.io/r/utils/data.html), specifying the dataset
  and package.

## Value

A character vector containing the names of the packages from which
datasets are being loaded.

## Examples

``` r
vec_char <- 'data("starwars", package = "dplyr")'
att_from_data(vec_char)
#> [1] "dplyr"
```
