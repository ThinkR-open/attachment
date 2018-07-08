## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(attachment)

## ---- eval=FALSE---------------------------------------------------------
#  att_from_namespace()

## ---- eval=FALSE---------------------------------------------------------
#  att_from_functions()

## ---- eval=FALSE---------------------------------------------------------
#  att_from_vignettes()

## ---- eval=FALSE---------------------------------------------------------
#  att_to_description()

## ---- eval=FALSE---------------------------------------------------------
#  create_dependencies_file()

## ---- eval=FALSE---------------------------------------------------------
#  to_install <- c("desc","devtools","magrittr","stats","stringr","usethis","utils")
#  for (i in to_install) {
#    message(paste("looking for ", i))
#    if (!requireNamespace(i)) {
#      message(paste("     installing", i))
#      install.packages(i)
#    }
#  
#  }

