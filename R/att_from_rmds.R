#' Get all dependencies from a Rmd file
#'
#' @param path Path to a Rmd file
#' @param temp_dir Path to temporary script from purl vignette
#' @param warn -1 for quiet warnings with purl, 0 to see warnings
#'
#' @importFrom stringr str_extract
#' @importFrom knitr purl
#'
#' @examples
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmd(path = file.path(dummypackage,"vignettes/demo.Rmd"))
#'
#' @export
att_from_rmd <- function(path, temp_dir = tempdir(), warn = -1) {
  if (missing(path)) {stop("argument 'path' is missing, with no default")}
  r_file <- file.path(temp_dir, basename(gsub(".Rmd$", ".R", path)))

  # Purl in a new environment to avoid knit inside knit if function is inside Rmd file
  system(
    paste0(Sys.getenv("R_HOME"), '/bin/Rscript -e \'options(warn=', warn,
           ');invisible(knitr::purl("', path, '", output = "', r_file,
           '",documentation = 0, quiet = TRUE))\'')
  )

  # Add yaml to the file
  yaml <- c("\n# yaml to parse \n", paste(unlist(rmarkdown::yaml_front_matter(path)$output), "\n", collapse = "\n"))
  cat(yaml, file = r_file, append = TRUE)
  att_from_rscript(r_file)
}

#' Get all packages called in vignettes folder
#'
#' @param path path to directory with Rmds or vector of Rmd files
#' @param recursive logical. Should the listing recurse into directories?
#' @inheritParams att_from_rmd
#'
#' @return Character vector of packages called with library or require.
#' {knitr} and {rmarkdown} are added by default to allow building the vignettes
#'  if the directory contains "vignettes" in the path
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_rmds(path = file.path(dummypackage,"vignettes"))

#' @export
att_from_rmds <- function(path = "vignettes", recursive = TRUE, warn = -1) {

  if (isTRUE(all(dir.exists(path)))) {
    all_f <- list.files(path, full.names = TRUE, pattern = "*.Rmd$|*.rmd$",recursive = recursive)
  } else if (isTRUE(all(file.exists(path)))) {
    all_f <- normalizePath(path[grepl("*.Rmd$|*.rmd$", path)])
  } else {
    stop("Some file/directory do not exists")
  }

res <- lapply(all_f, function(x) att_from_rmd(x, , warn = warn)) %>%
    unlist() %>%
    unique() %>%
    na.omit()

  if (isTRUE(any(grepl("vignettes", path)))) {
    unique(c("knitr", "rmarkdown", res))
  } else {
    res
  }
}
