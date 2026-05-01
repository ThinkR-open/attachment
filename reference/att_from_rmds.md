# Get all packages called in vignettes folder

Get all packages called in vignettes folder

## Usage

``` r
att_from_rmds(
  path = "vignettes",
  pattern = "*.[.](Rmd|rmd|qmd)$",
  recursive = TRUE,
  warn = -1,
  inside_rmd = FALSE,
  inline = TRUE,
  folder_to_exclude = "renv"
)

att_from_qmds(
  path = "vignettes",
  pattern = "*.[.](Rmd|rmd|qmd)$",
  recursive = TRUE,
  warn = -1,
  inside_rmd = FALSE,
  inline = TRUE,
  folder_to_exclude = "renv"
)
```

## Arguments

- path:

  path to directory with Rmds or vector of Rmd files

- pattern:

  pattern to detect Rmd files

- recursive:

  logical. Should the listing recurse into directories?

- warn:

  -1 for quiet warnings with purl, 0 to see warnings

- inside_rmd:

  Logical. Whether function is run inside a Rmd, in case this must be
  executed in an external R session

- inline:

  Logical. Default TRUE. Whether to explore inline code for
  dependencies.

- folder_to_exclude:

  Folder to exclude during scan to detect packages 'renv' by default

## Value

Character vector of packages called with library or require. *knitr* and
*rmarkdown* are added by default to allow building the vignettes if the
directory contains "vignettes" in the path

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)
att_from_rmds(path = file.path(dummypackage,"vignettes"))
#> [1] "knitr"     "rmarkdown" "glue"     
```
