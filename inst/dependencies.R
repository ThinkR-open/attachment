# No Remotes ----
# Attachments ----
to_install <- c("desc", "glue", "knitr", "magrittr", "rmarkdown", "roxygen2", "stringr", "testthat")
  for (i in to_install) {
    message(paste("looking for ", i))
    if (!requireNamespace(i)) {
      message(paste("     installing", i))
      install.packages(i)
    }
  }

