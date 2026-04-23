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
#' Uses the R parser to walk the syntax tree so that occurrences of `pkg::fun`
#' or `library()/require()/requireNamespace()/loadNamespace()/use()/getFromNamespace()`
#' inside string literals or comments are ignored.
#' Named arguments such as `library(package = "pkg")` are supported.
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))

att_from_rscript <- function(path) {

  lines <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(e) character(0)
  )
  if (length(lines) == 0) return(character(0))

  out <- tryCatch(
    parse_pkgs_from_r_code(lines),
    error = function(e) legacy_pkgs_from_r_code(lines)
  )
  out <- unique(stats::na.omit(out))
  out <- out[nzchar(out) & out != "base"]
  attributes(out) <- NULL
  out
}

# Known dependency-introducing function calls and where the package arg lives.
# Each entry: `arg_name` = canonical named arg, `arg_index` = positional fallback.
pkg_intro_calls <- list(
  library          = list(arg_name = "package", arg_index = 1L),
  require          = list(arg_name = "package", arg_index = 1L),
  requireNamespace = list(arg_name = "package", arg_index = 1L),
  loadNamespace    = list(arg_name = "package", arg_index = 1L),
  attachNamespace  = list(arg_name = "ns",      arg_index = 1L),
  use              = list(arg_name = "package", arg_index = 1L),
  getFromNamespace = list(arg_name = "ns",      arg_index = 2L),
  getNamespace     = list(arg_name = "name",    arg_index = 1L),
  asNamespace      = list(arg_name = "ns",      arg_index = 1L),
  packageVersion   = list(arg_name = "pkg",     arg_index = 1L)
)

match_call_arg <- function(call_args, arg_name, arg_index) {
  if (length(call_args) == 0) return(NULL)
  nms <- names(call_args)
  if (is.null(nms)) nms <- rep("", length(call_args))
  hit <- which(nms == arg_name)
  if (length(hit) > 0) return(call_args[[hit[1]]])
  positional <- call_args[nms == ""]
  if (length(positional) >= arg_index) return(positional[[arg_index]])
  NULL
}

arg_as_string <- function(arg) {
  if (is.null(arg)) return(NA_character_)
  if (is.character(arg) && length(arg) == 1) return(arg)
  if (is.name(arg) || is.symbol(arg)) return(as.character(arg))
  NA_character_
}

parse_pkgs_from_r_code <- function(lines) {
  exprs <- parse(text = lines, keep.source = FALSE)
  pkgs <- character(0)

  walk <- function(x) {
    if (is.call(x)) {
      head <- x[[1]]
      if (is.call(head) && length(head) >= 2) {
        op <- tryCatch(as.character(head[[1]]), error = function(e) "")
        if (length(op) == 1 && op %in% c("::", ":::")) {
          ns <- tryCatch(as.character(head[[2]]), error = function(e) NA_character_)
          if (!is.na(ns) && nzchar(ns)) pkgs[[length(pkgs) + 1L]] <<- ns
        }
      } else if (is.name(head)) {
        fn <- as.character(head)
        if (fn %in% c("::", ":::")) {
          if (length(x) >= 2) {
            ns <- tryCatch(as.character(x[[2]]), error = function(e) NA_character_)
            if (!is.na(ns) && nzchar(ns)) pkgs[[length(pkgs) + 1L]] <<- ns
          }
        } else if (fn %in% names(pkg_intro_calls)) {
          spec <- pkg_intro_calls[[fn]]
          call_args <- as.list(x)[-1]
          arg <- match_call_arg(call_args, spec$arg_name, spec$arg_index)
          pkg <- arg_as_string(arg)
          if (!is.na(pkg) && nzchar(pkg)) pkgs[[length(pkgs) + 1L]] <<- pkg
        }
      }
      for (el in as.list(x)[-1]) {
        if (!missing(el) && !is.null(el)) walk(el)
      }
      if (is.call(head)) walk(head)
    } else if (is.expression(x) || is.pairlist(x)) {
      for (el in as.list(x)) walk(el)
    }
  }

  for (e in as.list(exprs)) walk(e)
  unique(pkgs)
}

# Fallback used only when parse() fails on the input (e.g. non-R snippets).
# Keeps the historical regex-based behaviour so we never silently drop a file.
legacy_pkgs_from_r_code <- function(lines) {
  file <- gsub("\\\\n", " ", lines)
  file <- file[grep("^\\s*#", file, invert = TRUE)]
  pkg_points <- unlist(str_extract_all(file, "[[:alnum:]\\.]+(?=::)"))
  w.lib <- grep("library|require", file)
  if (length(w.lib)) {
    pkg_lib <- file[w.lib]
    pkg_lib <- unlist(str_extract_all(
      pkg_lib,
      "(?<=library\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=require\\()[[:alnum:]\\.\\\"]+(?=\\))|(?<=requireNamespace\\()[[:alnum:]\\.\\\"]+(?=\\))"
    ))
    pkg_lib <- str_replace_all(pkg_lib, "\\\"$|^\\\"", "")
  } else {
    pkg_lib <- character(0)
  }
  unique(c(pkg_lib, pkg_points))
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
