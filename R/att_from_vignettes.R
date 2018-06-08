#' Get all dependencies from a vignette
#'
#' @param path Path to a vignette
#'
#' @importFrom stringr str_extract
#'
#' @examples
#' \dontrun{
#' att_from_vignette("vignettes/my-vignette.Rmd")
#' }
att_from_vignette <- function(path) {
  f <- readLines(path)
  w.lib <- grep("library|require", f)
  if (length(w.lib) != 0) {
    res <- f[w.lib] %>%
      str_extract("(?<=library\\().*(?=\\))|(?<=require\\().*(?=\\))") %>%
      unique() %>%
      na.omit()
  } else {
    res <- NA
  }
  res
}

#' Get all packages called in vignettes
#'
#' @param path path to vignettes directory
#'
#' @examples
#' \dontrun{
#' att_from_vignettes("vignettes")
#' }
#' @export
att_from_vignettes <- function(path = "vignettes") {
  all_f <- file.path(path, list.files(path))
  lapply(all_f, att_from_vignette) %>%
    unlist() %>%
    unique() %>%
    na.omit()
}
