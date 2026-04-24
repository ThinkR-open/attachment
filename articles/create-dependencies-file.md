# Create dependencies file

``` r
library(attachment)
```

## Write instructions to install all dependencies from a “DESCRIPTION” file

[`create_dependencies_file()`](https://thinkr-open.github.io/attachment/reference/create_dependencies_file.md)
creates “inst/dependencies.R” file with the instructions to install all
dependencies listed in your “DESCRIPTION”. This accounts for the
“Remotes” field and write instructions accordingly.

Use `create_dependencies_file(to = NULL)` to only retrieve the output as
a list of character and not save a “inst/dependencies.R” file in your
project. This can be used in a `Readme.Rmd` file for instance, to get
the full list of each dependency to install and how, from any
“DESCRIPTION” file.

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
