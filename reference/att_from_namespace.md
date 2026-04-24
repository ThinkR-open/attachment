# return package dependencies from NAMESPACE file

return package dependencies from NAMESPACE file

## Usage

``` r
att_from_namespace(path = "NAMESPACE", document = TRUE, clean = TRUE)
```

## Arguments

- path:

  path to NAMESPACE file

- document:

  Run function roxygenise of roxygen2 package

- clean:

  Logical. Whether to remove the original NAMESPACE before updating

## Value

a vector

## Examples

``` r
tmpdir <- tempfile(pattern = "namespace")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
 recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_from_namespace(path = file.path(dummypackage, "NAMESPACE"))
#> Updating dummypackage documentation
#> ℹ Setting RoxygenNote to "7.3.3"
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> [1] "magrittr"

# Clean temp files after this example
unlink(tmpdir, recursive = TRUE)
```
