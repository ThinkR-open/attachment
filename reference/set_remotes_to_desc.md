# Add Remotes field to DESCRIPTION based on your local installation

Add Remotes field to DESCRIPTION based on your local installation

## Usage

``` r
set_remotes_to_desc(path.d = "DESCRIPTION", stop.local = FALSE, clean = TRUE)
```

## Arguments

- path.d:

  path to description file.

- stop.local:

  Logical. Whether to stop if package was installed from local source.
  Message otherwise.

- clean:

  Logical. Whether to clean all existing remotes before run.

## Value

Used for side effect. Adds Remotes field in DESCRIPTION file.

## Examples

``` r
tmpdir <- tempfile(pattern = "setremotes")
dir.create(tmpdir)
file.copy(system.file("dummypackage", package = "attachment"), tmpdir,
 recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")
# Add remotes field if there are Remotes locally
att_amend_desc(dummypackage) %>%
  set_remotes_to_desc()
#> Saving attachment parameters to yaml config file
#> Updating dummypackage documentation
#> ℹ Setting Config/roxygen2/version to "8.0.0"
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Writing NAMESPACE
#> ℹ Loading dummypackage
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.
#> There are no remote packages installed on your computer to add to description
#> NULL

# Clean temp files after this example
unlink(tmpdir, recursive = TRUE)

if (FALSE) { # \dontrun{
# For your current package
att_amend_desc() %>%
  set_remotes_to_desc()
} # }
```
