# Get all packages called in vignettes folder

Get all packages called in vignettes folder

## Usage

``` r
att_from_rmds(
  path = "vignettes",
  pattern = "*.[.](Rmd|rmd|qmd)$",
  recursive = TRUE,
  warn = -1,
  inside_rmd = NULL,
  inline = TRUE,
  folder_to_exclude = "renv"
)

att_from_qmds(
  path = "vignettes",
  pattern = "*.[.](Rmd|rmd|qmd)$",
  recursive = TRUE,
  warn = -1,
  inside_rmd = NULL,
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

  Logical or `NULL`. Whether the function is being called from inside a
  knit session, in which case the actual purl step must be delegated to
  an external R process. When `NULL` (the default), this is
  auto-detected via `knitr::opts_knit$get("out.format")`.

- inline:

  Logical. Default TRUE. Whether to explore inline code for
  dependencies.

- folder_to_exclude:

  Folder to exclude during scan to detect packages 'renv' by default

## Value

Character vector of packages called with library or require. When the
directory contains "vignettes" in its path, `knitr` is always added and
the vignette engine is inferred from the files actually present:
`rmarkdown` is added when `.Rmd` files are found, `quarto` when `.qmd`
files are found (both when the directory mixes the two). If the
directory is empty, `rmarkdown` is added as a safe default.

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)
att_from_rmds(path = file.path(dummypackage,"vignettes"))
#> [1] "knitr"     "rmarkdown" "glue"     
```
