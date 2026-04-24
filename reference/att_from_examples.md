# Get all packages called in examples from R files

Get all packages called in examples from R files

## Usage

``` r
att_from_examples(dir.r = "R")
```

## Arguments

- dir.r:

  path to directory with R scripts.

## Value

Character vector of packages called with library or require.

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")

# browseURL(dummypackage)
att_from_examples(dir.r = file.path(dummypackage,"R"))
#> [1] "utils"   "stringr"
```
