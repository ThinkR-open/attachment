#' Get all dependencies from a Rmd file
#'
#' @param path Path to a Rmd file
#' @param temp_dir Path to temporary script from purl vignette
#' @param warn -1 for quiet warnings with purl, 0 to see warnings
#' @param inside_rmd Logical. Whether function is run inside a Rmd,
#'  in case this must be executed in an external R session
#' @param inline Logical. Default TRUE. Whether to explore inline code for dependencies.
#' @inheritParams knitr::purl
#'
#' @importFrom stringr str_extract
#' @importFrom knitr purl
#'
#' @return vector of character of packages names found in the Rmd
#'
#' @examples
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmd(path = file.path(dummypackage,"vignettes/demo.Rmd"))
#'
#' @export
att_from_rmd <- function(path, temp_dir = tempdir(), warn = -1,
                         encoding = getOption("encoding"),
                         inside_rmd = FALSE, inline = TRUE) {
  if (missing(path)) {stop("argument 'path' is missing, with no default")}

  op <- options(knitr.purl.inline = inline)
  on.exit(options(op))

  r_file <- normalizePath(file.path(temp_dir, basename(gsub("[.]([[:alnum:]])*$", ".R", path))), mustWork = FALSE, winslash = "\\")
  path <- normalizePath(path, winslash = "\\")

  # Need an external script to run on windows because of \\ path
  runR <- tempfile(fileext = "run.R")

  cat(
    paste0('warn_user <- getOption("warn");',
           'options(warn=', warn, ');',
           'invisible(knitr::purl("', gsub("\\", "\\\\", path, fixed = TRUE), '"',
           ', output = "', gsub("\\", "\\\\", r_file, fixed = TRUE), '"',
           ', encoding = "', encoding, '"',
           ', documentation = 0, quiet = TRUE));',
           'options(warn=warn_user)'
    )
    , file = runR)


  if (isTRUE(inside_rmd)) {
    # Purl in a new environment to avoid knit inside knit if function is inside Rmd file
    file <- system(
      paste(normalizePath(file.path(Sys.getenv("R_HOME"), "bin", "Rscript"), mustWork = FALSE), runR)
    )
  } else {
    source(runR)
  }

  # Add yaml to the file
  the_outputs <- rmarkdown::yaml_front_matter(path)$output
  if (is.null(names(the_outputs))) {
    yaml_pkg <- unlist(the_outputs)
  } else {
    yaml_pkg <- names(the_outputs)
  }
  yaml <- c("\n# yaml to parse \n",
            paste(yaml_pkg, "\n"))
  cat(yaml, file = r_file, append = TRUE)
  res <- att_from_rscript(r_file)

  # clean tempdir
  file.remove(runR)
  file.remove(r_file)

  return(res)
}

#' Get all packages called in vignettes folder
#'
#' @param path path to directory with Rmds or vector of Rmd files
#' @param pattern pattern to detect Rmd files
#' @param recursive logical. Should the listing recurse into directories?
#' @param folder_to_exclude Folder to exclude during scan to detect packages 'renv' by default
#' @inheritParams att_from_rmd
#'
#' @return Character vector of packages called with library or require.
#' \emph{knitr} and \emph{rmarkdown} are added by default to allow building the vignettes
#'  if the directory contains "vignettes" in the path
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmds(path = file.path(dummypackage,"vignettes"))

#' @export
att_from_rmds <- function(path = "vignettes",
                          pattern = "*.[.](Rmd|rmd|qmd)$",
                          recursive = TRUE, warn = -1,
                          inside_rmd = FALSE, inline = TRUE,folder_to_exclude = "renv") {

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



  res <- lapply(all_f,
                function(x) att_from_rmd(
                  x, warn = warn,
                  inside_rmd = inside_rmd, inline = inline)
  ) %>%
    unlist() %>%
    unique() %>%
    na.omit()

  if (isTRUE(any(grepl("vignettes", path)))) {
    unique(c("knitr", "rmarkdown", res))
  } else {
    res
  }
}

#' @rdname att_from_rmds
#' @export
att_from_qmds <- att_from_rmds

#' @rdname att_from_rmd
#' @export
att_from_qmd <- att_from_rmd

