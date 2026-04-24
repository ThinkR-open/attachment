# Create the list of instructions to install dependencies from a DESCRIPTION file

Outputs the list of instructions and a "dependencies.R" file with
instructions in the "inst/" directory

## Usage

``` r
create_dependencies_file(
  path = "DESCRIPTION",
  field = c("Depends", "Imports"),
  to = "inst/dependencies.R",
  open_file = TRUE,
  ignore_base = TRUE,
  install_only_if_missing = FALSE
)
```

## Arguments

- path:

  path to the DESCRIPTION file

- field:

  DESCRIPTION field to parse, "Import" and "Depends" by default. Can add
  "Suggests"

- to:

  path where to save the dependencies file. Set to "inst/dependencies.R"
  by default. Set to `NULL` if you do not want the file, but only the
  instructions as a list of character.

- open_file:

  Logical. Open the file created in an editor

- ignore_base:

  Logical. Whether to ignore package coming with base, as they cannot be
  installed (default TRUE)

- install_only_if_missing:

  Logical Modify the installation instructions to check, beforehand, if
  the packages are missing . (default FALSE)

## Value

List of R instructions to install all dependencies from a DESCRIPTION
file. Side effect: creates a R file containing these instructions.

## Examples

``` r
# Create a fake package
tmpdir <- tempfile(pattern = "depsfile")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
          recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")

# Create the dependencies commands but no file
create_dependencies_file(
  path = file.path(dummypackage,"DESCRIPTION"),
  to = NULL,
  open_file = FALSE)
#> $remotes_content
#> [1] "# No Remotes ----"
#> 
#> $attachment_content
#> # Attachments ----
#> to_install <- c("magrittr")
#>   for (i in to_install) {
#>     message(paste("looking for ", i))
#>     if (!requireNamespace(i, quietly = TRUE)) {
#>       message(paste("     installing", i))
#>       install.packages(i)
#>     }
#>   }
#> 
#> 

# Create the dependencies files in the package
create_dependencies_file(
  path = file.path(dummypackage,"DESCRIPTION"),
  to = file.path(dummypackage, "inst/dependencies.R"),
  open_file = FALSE)
list.files(file.path(dummypackage, "inst"))
#> [1] "dependencies.R"
# browseURL(dummypackage)

# Clean temp files after this example
unlink(tmpdir, recursive = TRUE)
```
