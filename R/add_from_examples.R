#' Get all packages called in examples from R files
#'
#' @param dir.r path to directory with R scripts.
#'
#' @return Character vector of packages called with library or require.
#'
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#'
#' # browseURL(dummypackage)
#' att_from_examples(dir.r = file.path(dummypackage,"R"))

#' @export
att_from_examples <- function(dir.r = "R") {
  rfiles <- list.files(dir.r, full.names = TRUE)

  roxy_file <- tempfile("roxy.examples", fileext = ".R")

  all_examples <- unlist(lapply(rfiles, function(the_file) {
    file_roxytags <- roxygen2::parse_file(the_file)
    res <- unlist(
      lapply(file_roxytags,
             function(x) roxygen2::block_get_tag_value(block = x, tag = "examples"))
    )
    res
  }))
  # Clean \dontrun and \donttest, and replace with '{' on next line
  all_examples_clean <-
    gsub(pattern = "\\\\dontrun\\s*\\{|\\\\donttest\\s*\\{", replacement = "#ICI\n{", x = all_examples)
  cat(all_examples_clean, file = roxy_file, sep = "\n")
  all_deps_examples <- attachment::att_from_rscript(roxy_file)
  file.remove(roxy_file)
  return(all_deps_examples)
}
