# Get all packages called in examples from R files

Get all packages called in examples from R files

## Usage

``` r
att_from_examples(dir.r = "R", encoding = getOption("encoding"))
```

## Arguments

- dir.r:

  path to directory with R scripts.

- encoding:

  Encoding passed to
  [`readLines()`](https://rdrr.io/r/base/readLines.html) when reading
  source files. Defaults to `getOption("encoding")` so the system locale
  is respected, matching
  [`att_from_rscript()`](https://thinkr-open.github.io/attachment/reference/att_from_rscript.md).

## Value

Character vector of packages called with library or require.

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")

# browseURL(dummypackage)
att_from_examples(dir.r = file.path(dummypackage,"R"))
#> [1] "utils"   "stringr"
```
