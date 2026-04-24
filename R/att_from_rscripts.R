#' Look for functions called with `::` and library/requires in one script
#'
#' @param path path to R script file
#' @param encoding Encoding passed to [readLines()] when reading `path`. Defaults
#'  to `getOption("encoding")` so the system locale is respected (important on
#'  Windows where scripts are often Latin-1 / Windows-1252).
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
#' Named arguments such as `library(package = "pkg")` are supported, as are
#' fully-qualified forms like `base::library(pkg)` or
#' `methods::getFromNamespace(fn, "pkg")`.
#' Introspection helpers such as `packageVersion()`, `getNamespace()`,
#' `asNamespace()`, and `attachNamespace()` are **not** treated as dependency
#' introducers, because they are commonly used for version or feature checks
#' on packages that may or may not be required at runtime.
#'
#' If the file cannot be parsed as valid R (syntax error, corrupt encoding,
#' etc.), the function falls back to a regex-based detector and emits a
#' `warning()` naming the file so users can investigate.
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))

att_from_rscript <- function(path, encoding = getOption("encoding")) {

  lines <- tryCatch(
    readLines(path, warn = FALSE, encoding = encoding),
    error = function(e) {
      warning(
        sprintf("Could not read R script '%s': %s", path, conditionMessage(e)),
        call. = FALSE
      )
      character(0)
    }
  )
  if (length(lines) == 0) return(character(0))

  out <- tryCatch(
    parse_pkgs_from_r_code(lines),
    error = function(e) {
      warning(
        sprintf(
          "Could not parse R script '%s' as valid R code (%s); falling back to text-based detection, which may return false positives.",
          path, conditionMessage(e)
        ),
        call. = FALSE
      )
      legacy_pkgs_from_r_code(lines)
    }
  )
  out <- unique(stats::na.omit(out))
  out <- out[nzchar(out) & out != "base"]
  attributes(out) <- NULL
  out
}

# Known dependency-introducing function calls and where the package arg lives.
# Each entry: `arg_name` = canonical named arg, `arg_index` = positional fallback.
# Kept intentionally narrow: only calls that *load/attach* a package are treated
# as introducing a dependency. `packageVersion()`, `getNamespace()`, and friends
# are often used for feature-detection and should not silently expand Imports.
pkg_intro_calls <- list(
  library          = list(arg_name = "package", arg_index = 1L),
  require          = list(arg_name = "package", arg_index = 1L),
  requireNamespace = list(arg_name = "package", arg_index = 1L),
  loadNamespace    = list(arg_name = "package", arg_index = 1L),
  use              = list(arg_name = "package", arg_index = 1L),
  getFromNamespace = list(arg_name = "ns",      arg_index = 2L)
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

is_empty_symbol <- function(x) {
  is.symbol(x) && !nzchar(as.character(x))
}

# Skip "empty" AST nodes such as the first subscript in `x[, 1]` or the
# missing `else` branch of `if (cond) a`. The element is received as a
# function argument (never bound to a local), which avoids triggering
# "argument is missing, with no default" errors on empty-symbol values.
walk_elem <- function(el, walker) {
  if (is.null(el) || is_empty_symbol(el)) return(invisible())
  walker(el)
}

parse_pkgs_from_r_code <- function(lines) {
  exprs <- parse(text = lines, keep.source = FALSE)
  pkgs <- character(0)

  walk <- function(x) {
    if (is_empty_symbol(x) || is.null(x)) return(invisible())
    if (is.call(x)) {
      head <- x[[1]]
      if (is.call(head) && length(head) >= 2) {
        op <- tryCatch(as.character(head[[1]]), error = function(e) "")
        if (length(op) == 1 && op %in% c("::", ":::")) {
          ns <- tryCatch(as.character(head[[2]]), error = function(e) NA_character_)
          if (!is.na(ns) && nzchar(ns)) pkgs[[length(pkgs) + 1L]] <<- ns
          # Also honour fully-qualified dependency-introducing calls such as
          # `base::library(pkg)`, `base::require(pkg)`, `methods::getFromNamespace(fn, "pkg")`.
          fn_name <- tryCatch(as.character(head[[3]]), error = function(e) NA_character_)
          if (length(fn_name) == 1 && !is.na(fn_name) &&
              fn_name %in% names(pkg_intro_calls)) {
            spec <- pkg_intro_calls[[fn_name]]
            call_args <- as.list(x)[-1]
            arg <- match_call_arg(call_args, spec$arg_name, spec$arg_index)
            pkg <- arg_as_string(arg)
            if (!is.na(pkg) && nzchar(pkg)) pkgs[[length(pkgs) + 1L]] <<- pkg
          }
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
      args <- as.list(x)[-1]
      for (i in seq_along(args)) walk_elem(args[[i]], walk)
      if (is.call(head)) walk(head)
    } else if (is.expression(x) || is.pairlist(x)) {
      xs <- as.list(x)
      for (i in seq_along(xs)) walk_elem(xs[[i]], walk)
    }
  }

  exprs_list <- as.list(exprs)
  for (i in seq_along(exprs_list)) walk(exprs_list[[i]])
  unique(pkgs)
}

# Fallback used only when parse() fails on the input (e.g. non-R snippets).
# Keeps the historical regex-based behaviour so we never silently drop a file.
# Character class includes `_` so that package names like `my_pkg` are not
# truncated to `pkg` — CRAN forbids `_` but many dev / GitHub packages use it.
legacy_pkgs_from_r_code <- function(lines) {
  file <- gsub("\\\\n", " ", lines)
  file <- file[grep("^\\s*#", file, invert = TRUE)]
  pkg_points <- unlist(str_extract_all(file, "[[:alnum:]\\._]+(?=::)"))
  w.lib <- grep("library|require", file)
  if (length(w.lib)) {
    pkg_lib <- file[w.lib]
    pkg_lib <- unlist(str_extract_all(
      pkg_lib,
      "(?<=library\\()[[:alnum:]\\._\\\"]+(?=\\))|(?<=require\\()[[:alnum:]\\._\\\"]+(?=\\))|(?<=requireNamespace\\()[[:alnum:]\\._\\\"]+(?=\\))"
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
#' @inheritParams att_from_rscript
#' @return vector of character of packages names found in the R script
#'
#' @export
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' att_from_rscripts(path = file.path(dummypackage, "R"))
#' att_from_rscripts(path = list.files(file.path(dummypackage, "R"), full.names = TRUE))

att_from_rscripts <- function(path = "R", pattern = "*.[.](r|R)$", recursive = TRUE,
                              folder_to_exclude = "renv",
                              encoding = getOption("encoding")) {

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


  lapply(all_f, att_from_rscript, encoding = encoding) %>%
    unlist() %>%
    unique() %>%
    na.omit()
}
