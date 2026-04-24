# Look for functions called with `::` and library/requires in folder of scripts

Look for functions called with `::` and library/requires in folder of
scripts

## Usage

``` r
att_from_rscripts(
  path = "R",
  pattern = "*.[.](r|R)$",
  recursive = TRUE,
  folder_to_exclude = "renv",
  encoding = getOption("encoding")
)
```

## Arguments

- path:

  directory with R scripts inside or vector of R scripts

- pattern:

  pattern to detect R script files

- recursive:

  logical. Should the listing recurse into directories?

- folder_to_exclude:

  Folder to exclude during scan to detect packages. 'renv' by default.

- encoding:

  Encoding passed to
  [`readLines()`](https://rdrr.io/r/base/readLines.html) when reading
  `path`. Defaults to `getOption("encoding")` so the system locale is
  respected (important on Windows where scripts are often Latin-1 /
  Windows-1252).

## Value

vector of character of packages names found in the R script

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)

att_from_rscripts(path = file.path(dummypackage, "R"))
#> [1] "stats"
att_from_rscripts(path = list.files(file.path(dummypackage, "R"), full.names = TRUE))
#> [1] "stats"
```
