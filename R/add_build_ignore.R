#' Add files to Rbuildignore
#'
#' @param x vector of filenames
#' @param directory path where to Rbuildignore should be written
#' @noRd
add_build_ignore <- function(x, directory = ".") {
  build_file <- file.path(directory, ".Rbuildignore")

  if (!file.exists(build_file)) {
    writeLines("", build_file)
  }

  build_ignore <- readLines(build_file)

  to_ignore <- paste0("^", gsub("[.]", "\\\\.", x), "$")

  to_ignore <- to_ignore[!to_ignore %in% build_ignore]

  if (length(to_ignore) != 0) {
    writeLines(enc2utf8(c(build_ignore, to_ignore)), build_file)
  }
}
