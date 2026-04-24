# Return all package dependencies from current package

Return all package dependencies from current package

## Usage

``` r
att_from_description(
  path = "DESCRIPTION",
  dput = FALSE,
  field = c("Depends", "Imports", "Suggests")
)
```

## Arguments

- path:

  path to the DESCRIPTION file

- dput:

  if FALSE return a vector instead of dput output

- field:

  DESCRIPTION field to parse, Import, Suggests and Depends by default

## Value

A character vector with packages names

## Examples

``` r
dummypackage <- system.file("dummypackage", package = "attachment")
# browseURL(dummypackage)
att_from_description(path = file.path(dummypackage, "DESCRIPTION"))
#> [1] "glue"      "knitr"     "magrittr"  "rmarkdown" "stats"     "stringr"  
#> [7] "testthat"  "utils"    
```
