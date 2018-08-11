
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis build status](https://travis-ci.org/ThinkR-open/attachment.svg?branch=master)](https://travis-ci.org/ThinkR-open/attachment)

<img src="https://raw.githubusercontent.com/ThinkR-open/attachment/master/img/attachment-hex-thinkr.png" width=250px>

attachment
==========

The goal of attachment is to help to deal with package dependencies during package development. It also give usefull tools to install or list missing packages used inside Rscripts or Rmds.

When building a package, we have to add `@importFrom` in our documentation or `pkg::fun` in the R code. The most important is not to forget to add the list of dependencies in the "Imports" or "Suggests" package lists in the DESCRIPTION file.

Why do you have to repeat twice the same thing ?
And what happens when you remove a dependency for one of your functions ? Do you really want to run a "Find in files" to verify that you do not need this package anymore ?

Let {attachment} help you ! This reads your NAMESPACE, your functions in R directory and your vignettes, then update the DESCRIPTION file accordingly. Are you ready to be lazy ?

Installation
------------

``` r
# install.packages("devtools")
devtools::install_github("ThinkR-open/attachment")
```

Use package {attachment}
------------------------

``` r
library(attachment)
```

What you really want is to fill and update your description file along with the modifications of your documentation. Indeed, only the following function will really be called. Use and abuse during the development of your package !

``` r
attachment::att_to_description()
```

To quickly install missing packages from a DESCRIPTION file, use :

``` r
attachment::install_from_description()
```

To quickly install missing packages needed to compile Rmd files or run Rscripts, use :

``` r
attachment::att_from_rmds(path = ".") %>% attachment::install_if_missing()
attachment::att_from_rscripts(path = ".") %>% attachment::install_if_missing()
```

The `attachment::create_dependencies_file()` instruction will create a `dependencies.R` file in `inst/` this script contain the procedure to quickly install missing dependencies :

``` r
to_install <- c("desc","devtools","glue","knitr","magrittr","stats","stringr","usethis","utils")
for (i in to_install) {
  message(paste("looking for ", i))
  if (!requireNamespace(i)) {
    message(paste("     installing", i))
    install.packages(i)
  }

}
```

Of course, you can also use {attachment} out of a package to list all package dependencies of R scripts using `att_from_rscripts` or Rmd files using `att_from_rmds`.

Vignette
--------

Package {attachment} has a vignette to present the different functions available. There is also a recommandation to have a `devstuff_history.R` in the root directory of your package. (*Have a look at [devstuff\_history.R](https://github.com/ThinkR-open/attachment/blob/master/devstuff_history.R) in the present package*)

``` r
vignette("fill-pkg-description", package = "attachment")
```

See full documentation realised using {pkgdown} at <https://thinkr-open.github.io/attachment/>

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
