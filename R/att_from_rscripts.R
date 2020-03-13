#' Look for functions called with `::` and library/requires in one script
#'
#' @param path path to R script file
#'
#' @importFrom stringr str_extract_all str_replace_all
#'
#' @return a vector
#' @export
#'
#' @details
#' Calls from pkg::fun in roxygen skeleton and comments are ignored
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))

att_from_rscript <- function(path) {

  file <- as.character(parse(path))

  pkg_points <- file %>%
    .[grep("^#", ., invert = TRUE)] %>%
    str_extract_all("[[:alnum:]\\.]+(?=::)") %>%
    unlist()

  w.lib <- grep("library|require", file)
  if (length(w.lib) != 0) {
    pkg_lib <- file[w.lib] %>%
      str_extract_all("(?<=library\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=require\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=requireNamespace\\()[[:alnum:]\\.\\\"]+(?=\\))") %>%
      unlist() %>%
      str_replace_all("\\\"$|^\\\"","")
  } else {
    pkg_lib <- NA
  }
  pkg_lib
  out <- c(pkg_lib, pkg_points) %>% unique() %>% na.omit()
  attributes(out) <- NULL
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
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscripts(path = dummypackage)

att_from_rscripts <- function(path = "R", pattern = "*.[.](r|R)$", recursive = TRUE) {
  all_f <- list.files(path, full.names = TRUE, pattern = pattern, recursive = recursive)
  lapply(all_f, att_from_rscript) %>%
    unlist() %>%
    unique() %>%
    na.omit()
}
