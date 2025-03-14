
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Coverage
status](https://codecov.io/gh/ThinkR-open/attachment/branch/main/graph/badge.svg)](https://app.codecov.io/github/ThinkR-open/attachment/tree/main)
[![CRAN
status](https://www.r-pkg.org/badges/version/attachment)](https://cran.r-project.org/package=attachment)
![downloads](http://cranlogs.r-pkg.org/badges/attachment)
[![R-CMD-check](https://github.com/ThinkR-open/attachment/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ThinkR-open/attachment/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ThinkR-open/attachment/graph/badge.svg)](https://app.codecov.io/gh/ThinkR-open/attachment)
<!-- badges: end -->

# attachment <img src="man/figures/logo.png" align="right" alt="" width="120" />

The goal of attachment is to help to deal with package dependencies
during package development. It also gives useful tools to install or
list missing packages used inside Rscripts or Rmds.

When building a package, we have to add `@importFrom` in our
documentation or `pkg::fun` in the R code. The most important is not to
forget to add the list of dependencies in the “Imports” or “Suggests”
package lists in the DESCRIPTION file.

Why do you have to repeat twice the same thing ?  
And what happens when you remove a dependency for one of your functions
? Do you really want to run a “Find in files” to verify that you do not
need this package anymore ?

Let {attachment} help you ! This reads your NAMESPACE, your functions in
R directory and your vignettes, then update the DESCRIPTION file
accordingly. Are you ready to be lazy ?

See full documentation realized using {pkgdown} at
<https://thinkr-open.github.io/attachment/>

## Installation

CRAN version

``` r
install.packages("attachment")
```

Development version

``` r
install.packages('attachment', repos = c('https://thinkr-open.r-universe.dev', 'https://cloud.r-project.org'))
```

## Declare all dependencies in DESCRIPTION during package development

What you really want is to fill and update your description file along
with the modifications of your documentation. Indeed, only the following
function will really be called. Use and abuse during the development of
your package !

``` r
attachment::att_amend_desc()
```

{attachment} detects all calls to `library(pkg)`, `@importFrom pkg fun`,
`pkg::fun()` in the different classical directories of your R package,
then list them in the correct “Imports” or “Suggests” category in the
DESCRIPTION file, according to their position in the package.

### Declare extra dependencies for extra uses

If you want to add extra packages like {pkgdown} or {covr} that are not
listed in any script in your package, a call for your development
packages would be:

``` r
attachment::att_amend_desc(extra.suggests = c("pkgdown", "covr"), update.config = TRUE)
```

Note the `update.config = TRUE` parameter that will save the parameters
used in the call of `att_amend_desc()` to the package configuration
file: “dev/config_attachment.yaml”.

If you run `att_amend_desc()` a second time afterwards, directly from
the console, it will use the last set of parameters extracted from the
configuration file.

Indeed, we recommend to store the complete command line in a
“dev/dev_history.R” file to update and run it when needed. If the
parameters do not change, you can run `attachment::att_amend_desc()`
directly in the console, wherever you are, it will use the configuration
file.

### Automatically fill the “Remotes” field

If you would like to detect the sources of your installations so that
you can add dependencies in the “Remotes” field of your DESCRIPTION
file, to mimic your local installation, you will use:

``` r
attachment::set_remotes_to_desc()
```

## Example on a fake package

``` r
# Copy example package in a temporary directory
tmpdir <- tempfile(pattern = "fakepkg")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
#> [1] TRUE
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)

# Fill the DESCRIPTION file automatically
# `inside_rmd` is specifically designed here to allow to run this command line in the "Readme.Rmd" file
desc_file <- attachment::att_amend_desc(path = dummypackage, inside_rmd = TRUE, update.config = TRUE)
#> 'update.config' was set to TRUE, hence, 'use.config' was forced to FALSE
#> Saving attachment parameters to yaml config file
#> Updating dummypackage documentation
#> Setting `RoxygenNote` to "7.3.2"
#> Writing 'NAMESPACE'
#> ℹ Loading dummypackage
#> Writing 'NAMESPACE'
#> ℹ Loading dummypackage
#> Package(s) Rcpp is(are) in category 'LinkingTo'. Check your Description file to be sure it is really what you want.

# Add Remotes if you have some installed
attachment::set_remotes_to_desc(path.d = desc_file)
#> There are no remote packages installed on your computer to add to description
#> NULL

# Clean state
unlink(tmpdir, recursive = TRUE)
```

## More on finding Remotes repositories (non installed from CRAN)

Find packages installed out of CRAN. This helps fill the “Remotes” field
in DESCRIPTION file with `set_remotes_to_desc()`.  
Behind the scene, it uses `find_remotes()`.

- See the examples below if {fusen} is installed from GitHub
  - Also works for GitLab, Bioconductor, Git, Local installations

``` r
# From GitHub
remotes::install_github("ThinkR-open/fusen",
                        quiet = TRUE, upgrade = "never")
attachment::find_remotes("fusen")
#> $fusen
#> [1] "ThinkR-open/fusen"
```

## Find and install missing dependencies required for your R scripts

To quickly install missing packages from a DESCRIPTION file, use:

``` r
attachment::install_from_description()
#> All required packages are installed
```

To quickly install missing packages needed to compile Rmd files or run R
scripts, use:

``` r
attachment::att_from_rmds(path = ".") %>% attachment::install_if_missing()

attachment::att_from_rscripts(path = ".") %>% attachment::install_if_missing()
```

Function `attachment::create_dependencies_file()` will create a
`dependencies.R` file in `inst/` directory. This R script contains the
procedure to quickly install missing dependencies:

``` r
# Remotes ----
# remotes::install_github("ThinkR-open/fcuk")
# Attachments ----
to_install <- c("covr", "desc", "devtools", "glue", "knitr", "magrittr", "rmarkdown", "stats", "stringr", "testthat", "utils")
for (i in to_install) {
  message(paste("looking for ", i))
  if (!requireNamespace(i)) {
    message(paste("     installing", i))
    install.packages(i)
  }
}
```

## Allow the CI to install all dependencies required for your bookdown, pagedown, quarto, …

If you write a {bookdown} and want to publish it on Github using GitHub
Actions or GitLab CI for instance, you will need a DESCRIPTION file with
list of dependencies just like for a package. In this case, you can use
the function to description from import/suggest:
`att_to_desc_from_is()`.

``` r
usethis::use_description()
# bookdown Imports are in Rmds
imports <- c("bookdown", attachment::att_from_rmds("."))
attachment::att_to_desc_from_is(path.d = "DESCRIPTION",
                                imports = imports, suggests = NULL)
```

Then, install dependencies with

``` r
remotes::install_deps()
```

## List packages required in any script or notebook

Of course, you can also use {attachment} out of a package to list all
package dependencies of R scripts using `att_from_rscripts()` or Rmd/qmd
files using `att_from_rmds()`.  
If you are running this inside a Rmd, you may need parameter
`inside_rmd = TRUE`.

``` r
library(attachment)
dummypackage <- system.file("dummypackage", package = "attachment")

att_from_rscripts(path = dummypackage)
#> [1] "stats"        "testthat"     "dummypackage"
att_from_rmds(path = file.path(dummypackage, "vignettes"), inside_rmd = TRUE)
#> [1] "knitr"     "rmarkdown" "glue"
```

## Vignettes included

Package {attachment} has vignettes to present the different functions
available. There is also a recommendation to have a `dev_history.R` in
the root directory of your package. (*Have a look at
[dev_history.R](https://github.com/ThinkR-open/attachment/blob/main/dev/dev_history.R)
in the present package*)

``` r
vignette("a-fill-pkg-description", package = "attachment")
vignette("b-bookdown-and-scripts", package = "attachment")
vignette("use_renv", package = "attachment")
vignette("create-dependencies-file", package = "attachment")
```

The vignettes are available on the {pkgdown} page, in the “Articles”
menu: <https://thinkr-open.github.io/attachment/>

## Code of Conduct

Please note that the attachment project is released with a [Contributor
Code of
Conduct](https://thinkr-open.github.io/attachment/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms
