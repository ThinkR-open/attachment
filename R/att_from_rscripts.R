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
  # Replace newlines `\n` by space
  file <- gsub("\\\\n", " ", file)

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
  out <- c(pkg_lib, pkg_points) %>% unique() %>% na.omit()
  attributes(out) <- NULL
  out[out != "base"]
}


#' Look for functions called with `::` and library/requires in folder of scripts
#'
#' @param path directory with R scripts inside or vector of R scripts
#' @param pattern pattern to detect R script files
#' @param recursive logical. Should the listing recurse into directories?
#' @param folder_to_exclude Folder to exclude during scan to detect packages. 'renv' by default.
#' @return vector of character of packages names found in the R script
#'
#' @export
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscripts(path = file.path(dummypackage, "R"))
#' att_from_rscripts(path = list.files(file.path(dummypackage, "R"), full.names = TRUE))

att_from_rscripts <- function(path = "R", pattern = "*.[.](r|R)$", recursive = TRUE, folder_to_exclude = "renv") {

  if (isTRUE(all(dir.exists(path)))) {
    all_f <- list.files(path, full.names = TRUE, pattern = pattern, recursive = recursive)
  } else if (isTRUE(all(file.exists(path)))) {
    all_f <- normalizePath(path[grepl(pattern, path)])
  } else {
    stop("Some files/directories do not exist")
  }

  if (!is.null(folder_to_exclude) && length(folder_to_exclude) > 0) {
    exclude_files <- unlist(lapply(folder_to_exclude, function(folder) {
      list.files(path = file.path(path, folder), full.names = TRUE, pattern = pattern, recursive = recursive)
    }))

    # Exclure les fichiers
    all_f <- setdiff(all_f, exclude_files)
  }


  lapply(all_f, att_from_rscript) %>%
    unlist() %>%
    unique() %>%
    na.omit()
}
