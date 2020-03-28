#' return package dependencies from NAMESPACE file
#'
#' @param path path to NAMESPACE file
#' @param document Run function roxygenise of roxygen2 package
#'
#' @return a vector
#' @export
#' @importFrom stringr str_match
#' @importFrom stats setNames na.omit
#' @importFrom utils read.table
#'
#' @examples
#' tmpdir <- tempdir()
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # browseURL(dummypackage)
#' att_from_namespace(path = file.path(dummypackage, "NAMESPACE"))

att_from_namespace <- function(path = "NAMESPACE", document = TRUE) {
  if (isTRUE(document)) {
    message("Updating ", basename(dirname(normalizePath(path))), " documentation")
    # devtools::document(dirname(path))
    roxygen2::roxygenise(dirname(normalizePath(path)), roclets = NULL)
  }
  base <- try(readLines(path), silent = TRUE)
  base <- try(base[!grepl("^#|^$", base)], silent = TRUE)
  # base <- try(read.table(path)[["V1"]], silent = TRUE)
  if (!isTRUE(inherits(base, "try-error"))) {
    out <- na.omit(unique(c(
      unique(str_match(base, "importFrom\\(([[:alnum:]\\.]+),.*")[, 2]),
      unique(str_match(base, "import\\(([[:alnum:]\\.]+).*")[, 2])
  )))
  } else {
    message("att_from_namespace() failed,",
    " package were not retrieved from NAMESPACE")
    out <- NULL
  }
  c(out, NULL)
}
