#' return package dependencies from NAMESPACE file
#'
#' @param path path to NAMESPACE file
#' @param document Run function document of devtools package
#'
#' @return a vector
#' @export
#' @importFrom stringr str_match
#' @importFrom stats setNames na.omit
#' @importFrom utils read.table
#' @examples
#' \dontrun{
#'
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_from_namespace(path = file.path(dummypackage,"NAMESPACE"))
#'
#' }
att_from_namespace <- function(path = "NAMESPACE", document = TRUE) {
  if (isTRUE(document)) {
    devtools::document(".")
  }
  base <- read.table(path)[["V1"]]



  out <- na.omit(unique(c(
    unique(str_match(base, "importFrom\\(([[:alnum:]\\.]+),.*")[, 2]),
    unique(str_match(base, "import\\(([[:alnum:]\\.]+).*")[, 2])
  )))
  c(out,NULL)
}
