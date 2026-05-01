# Get all dependencies from a Rmd file

Get all dependencies from a Rmd file

## Usage

``` r
att_from_rmd(
  path,
  temp_dir = tempdir(),
  warn = -1,
  encoding = getOption("encoding"),
  inside_rmd = FALSE,
  inline = TRUE
)

att_from_qmd(
  path,
  temp_dir = tempdir(),
  warn = -1,
  encoding = getOption("encoding"),
  inside_rmd = FALSE,
  inline = TRUE
)
```

## Arguments

- path:

  Path to a Rmd file

- temp_dir:

  Path to temporary script from purl vignette

- warn:

  -1 for quiet warnings with purl, 0 to see warnings

- encoding:

  Encoding of the input file; always assumed to be UTF-8 (i.e., this
  argument is effectively ignored).

- inside_rmd:

  Logical. Whether function is run inside a Rmd, in case this must be
  executed in an external R session

- inline:

  Logical. Default TRUE. Whether to explore inline code for
  dependencies.

## Value

vector of character of packages names found in the Rmd

## Examples

``` r

dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)
att_from_rmd(path = file.path(dummypackage,"vignettes/demo.Rmd"))
#> [1] "glue"      "knitr"     "rmarkdown"
```
