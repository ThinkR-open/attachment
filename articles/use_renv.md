# Use {renv} with developers tools

``` r

library(attachment)
```

[`create_renv_for_dev()`](https://thinkr-open.github.io/attachment/reference/create_renv_for_dev.md)
and
[`create_renv_for_prod()`](https://thinkr-open.github.io/attachment/reference/create_renv_for_dev.md)
functions create `renv.lock` files based on development projects.

## Create reproducible environments for your R projects with {renv}

Tool to create and maintain “renv.lock” files. The idea is to have 2
distinct files, one for development and the other for deployment.
Indeed, although package like {attachment}, {fusen} or {pkgload} must be
installed to develop, they are not necessary in your project, package or
Shiny application.

Hence, create and update your “renv.lock” file in the development
project with everything needed to work in the same conditions between
collaborators and allow Continuous Integration to work properly.  
This currently includes:

    #>  [1] "renv"        "fusen"       "devtools"    "roxygen2"    "usethis"    
    #>  [6] "pkgload"     "testthat"    "remotes"     "covr"        "attachment" 
    #> [11] "pak"         "dockerfiler" "pkgdown"

And thus, run
[`create_renv_for_dev()`](https://thinkr-open.github.io/attachment/reference/create_renv_for_dev.md)
before sending your commit to your remote git server. Use `_default`
(with underscore), to use the default list.

``` r

create_renv_for_dev() # with all default above
create_renv_for_dev(dev_pkg = "attachment") # with {attachment} only
create_renv_for_dev(dev_pkg = c("_default", "DT")) # for all default and {DT}
```

Later on, if you want to create a R project that can use your package
developed with {renv}, run
[`create_renv_for_prod()`](https://thinkr-open.github.io/attachment/reference/create_renv_for_dev.md).  
Indeed, your users only need to install packages listed in your
“DESCRIPTION” file, with the same packages versions you used during
development.

``` r

create_renv_for_prod(output = "renv.lock.prod")
```
