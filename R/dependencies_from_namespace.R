#' return package dependencies from NAMESPACE file
#'
#' @param path path to NAMESPACE file
#'
#' @return a vector
#' @export
#' @importFrom stringr str_match
#' @importFrom stats setNames
#' @importFrom utils read.table
#' @examples
#' \dontrun{
#' dependencies_from_namespace()
#' }
dependencies_from_namespace <- function(path="NAMESPACE"){

  base <- read.table(path)[["V1"]]

  unique(c(unique(str_match(base,"importFrom\\(([[:alnum:]]+),.*")[,2]),
           unique(str_match(base,"import\\(([[:alnum:]]+).*")[,2])))
}

