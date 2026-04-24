# Proposes values for Remotes field for DESCRIPTION file based on your installation

Proposes values for Remotes field for DESCRIPTION file based on your
installation

## Usage

``` r
find_remotes(pkg)
```

## Arguments

- pkg:

  Character. Packages to test for potential non-CRAN installation

## Value

List of all non-CRAN packages and code to add in Remotes field in
DESCRIPTION. NULL otherwise.

## Examples

``` r
# Find from vector of packages
find_remotes(pkg = c("attachment", "desc", "glue"))
#> $attachment
#> local maybe ? 
#>            NA 
#> 

# Find from Description file
dummypackage <- system.file("dummypackage", package = "attachment")
att_from_description(
path = file.path(dummypackage, "DESCRIPTION")) %>%
find_remotes()
#> NULL

if (FALSE) { # \dontrun{
# For the current package directory
att_from_description() %>% find_remotes()
} # }

# \donttest{
# For a specific package name
find_remotes("attachment")
#> $attachment
#> local maybe ? 
#>            NA 
#> 

# Find remotes from all installed packages
find_remotes(list.dirs(.libPaths(), full.names = FALSE, recursive = FALSE))
#> Warning: DESCRIPTION file of package '_cache' is missing or broken
#> _cache does not seem to be a package. It is removed from exploration.
#> $attachment
#> local maybe ? 
#>            NA 
#> 
#> $pak
#> local maybe ? 
#>            NA 
#> 
#> $thinkrtemplate
#> [1] "ThinkR-open/thinkrtemplate"
#> 
#> $translations
#> local maybe ? 
#>            NA 
#> 
# }
```
