#' Get all dependencies from a Rmd file
#'
#' @param path Path to a Rmd file
#' @param temp_dir Path to temporary script from purl vignette
#'
#' @importFrom stringr str_extract
#'
#' @examples
#' \dontrun{
#' att_from_vignette("vignettes/my-vignette.Rmd")
#' }
att_from_rmd <- function(path, temp_dir = tempdir()) {
  file <- knitr::purl(path, output = paste0(tempfile(tmpdir = temp_dir), ".R"),
                      documentation = 0, quiet = TRUE)
  att_from_rscript(file)
}

#' Get all packages called in vignettes folder
#'
#' @param path path to directory with Rmds
#' @param recursive logical. Should the listing recurse into directories?
#'
#' @return Character vector of packages called with library or require.
#' {knitr} and {rmarkdown} are added by default to allow building the vignettes
#'  if the directory contains "vignettes" in the path
#'
#' @examples
#' \dontrun{
#' att_from_rmds("vignettes")
#' }
#' @export
att_from_rmds <- function(path = "vignettes",recursive = TRUE) {
  all_f <- list.files(path, full.names = TRUE, pattern = ".Rmd$",recursive = recursive)
  res <- lapply(all_f, att_from_rmd) %>%
    unlist() %>%
    unique() %>%
    na.omit()

  if (grepl("vignettes", path)) {
    c("knitr", "rmarkdown", res)
  } else {
    res
  }
}
