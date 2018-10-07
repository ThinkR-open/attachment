#' Get all dependencies from a Rmd file
#'
#' @param path Path to a Rmd file
#' @param temp_dir Path to temporary script from purl vignette
#'
#' @importFrom stringr str_extract
#'
#' @examples
#' \dontrun{
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmd(path = file.path(dummypackage,"vignettes/demo.Rmd"))
#'
#' }
#' @export
att_from_rmd <- function(path, temp_dir = tempdir()) {
  file <- knitr::purl(path, output = paste0(tempfile(tmpdir = temp_dir), ".R"),
                      documentation = 0, quiet = TRUE)
  att_from_rscript(file)
}

#' Get all packages called in vignettes folder
#'
#' @param path path to directory with Rmds or vector of Rmd files
#' @param recursive logical. Should the listing recurse into directories?
#'
#' @return Character vector of packages called with library or require.
#' {knitr} and {rmarkdown} are added by default to allow building the vignettes
#'  if the directory contains "vignettes" in the path
#'
#' @examples
#' \dontrun{
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmds(path = file.path(dummypackage,"vignettes"))
#' }
#' @export
att_from_rmds <- function(path = "vignettes",recursive = TRUE) {

  if (isTRUE(all(dir.exists(path)))) {
    all_f <- list.files(path, full.names = TRUE, pattern = "*.Rmd$|*.rmd$",recursive = recursive)
  } else if (isTRUE(all(file.exists(path)))) {
    all_f <- normalizePath(path[grepl("*.Rmd$|*.rmd$", path)])
  } else {
    stop("Some file/directory do not exists")
  }

res <- lapply(all_f, att_from_rmd) %>%
    unlist() %>%
    unique() %>%
    na.omit()

  if (isTRUE(any(grepl("vignettes", path)))) {
    unique(c("knitr", "rmarkdown", res))
  } else {
    res
  }
}
