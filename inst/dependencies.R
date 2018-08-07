to_install <- c("desc","devtools","glue","knitr","magrittr","stats","stringr","usethis","utils")
for (i in to_install) {
  message(paste("looking for ", i))
  if (!requireNamespace(i)) {
    message(paste("     installing", i))
    install.packages(i)
  }

}