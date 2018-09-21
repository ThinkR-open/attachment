#' Look for functions called with `::` and library/requires in one script
#'
#' @param path path to R script file
#'
#' @return a vector
#' @export
#'
#' @details
#' Calls from pkg::fun in roxygen skeleton and comments are ignored
#'
#' @examples
#' \dontrun{
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))
#' }
att_from_rscript <- function(path) {

  # tmp <- tempfile(fileext = '.R')
  # writeLines(as.character(parse(path)), tmp)

  f <- as.character(parse(path))

  pkg_points <- f %>%
           .[grep("^#", ., invert = TRUE)] %>%
      stringr::str_extract_all("[[:alnum:]\\.]+(?=::)") %>%
      unlist()

  w.lib <- grep("library|require", f)
  if (length(w.lib) != 0) {
    pkg_lib <- f[w.lib] %>%
      str_extract("(?<=library\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=require\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=requireNamespace\\()[[:alnum:]\\.\\\"]+(?=\\))")%>%
      str_replace_all("\\\"$|^\\\"","")
  } else {
    pkg_lib <- NA
  }
  pkg_lib
 out <- c(pkg_lib, pkg_points) %>% unique() %>% na.omit()
 attributes(out)<-NULL
 out
}


#' Look for functions called with `::` and library/requires in folder of scripts
#'
#' @param path directory with R scripts inside
#' @param pattern pattern to detect R script files
#' @param recursive logical. Should the listing recurse into directories?
#'
#' @export
#' @examples
#'
#' \dontrun{
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscripts(path = dummypackage)
#' }

att_from_rscripts <- function(path = "R",pattern = "*.(r|R)$",recursive=TRUE) {
  all_f <- list.files(path, full.names = TRUE,pattern = pattern,recursive = recursive)
  lapply(all_f, att_from_rscript) %>%
    unlist() %>%
    unique() %>%
    na.omit()
}
