# Look for functions called with `::` and library/requires in one script

Look for functions called with `::` and library/requires in one script

## Usage

``` r
att_from_rscript(path)
```

## Arguments

- path:

  path to R script file

## Value

a vector

## Details

Calls from pkg::fun in roxygen skeleton and comments are ignored

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)

att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))
#> [1] "stats"
```
