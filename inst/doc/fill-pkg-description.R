## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(attachment)

## ---- eval=FALSE---------------------------------------------------------
#  att_to_description()

## ---- eval=FALSE---------------------------------------------------------
#  att_from_namespace()

## ---- eval=FALSE---------------------------------------------------------
#  att_from_rscripts()

## ---- eval=FALSE---------------------------------------------------------
#  att_from_rmds()

## ---- eval=FALSE---------------------------------------------------------
#  create_dependencies_file()

## ---- eval=FALSE---------------------------------------------------------
#  # No Remotes ----
#  # remotes::install_github("ThinkR-open/fcuk")
#  # Attachments ----
#  to_install <- c("covr", "desc", "devtools", "glue", "knitr", "magrittr", "rmarkdown", "stats", "stringr", "testthat", "utils")
#  for (i in to_install) {
#    message(paste("looking for ", i))
#    if (!requireNamespace(i)) {
#      message(paste("     installing", i))
#      install.packages(i)
#    }
#  }

## ---- eval=FALSE---------------------------------------------------------
#  dummypackage <- system.file("dummypackage", package = "attachment")
#  
#  att_from_rscripts(path = dummypackage)
#  att_from_rmds(path = file.path(dummypackage,"vignettes"))

