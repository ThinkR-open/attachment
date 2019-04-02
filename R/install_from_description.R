#' Install missing package from DESCRIPTION
#'
#' @param path path to the DESCRIPTION file
#' @param field DESCRIPTION fields to parse, "Depends", "Imports", "Suggests" by default
#' @param ...  Arguments to be passed to \code{\link[utils]{install.packages}}
#' @export
#'
#' @examples
#' \dontrun{
#' dummypackage <- system.file("dummypackage", package = "attachment")
#' # browseURL(dummypackage)
#'
#' install_from_description(path = file.path(dummypackage,"DESCRIPTION"))
#' }

install_from_description <- function(path = "DESCRIPTION", field = c("Depends", "Imports", "Suggests"), ...) {

  to_be_installed <- att_from_description(path = path, field = field)
  install_if_missing(to_be_installed = to_be_installed, ...)
}

#' install  packages if missing
#'
#' @param to_be_installed a character vector containing required packages names
#' @param ...  Arguments to be passed to \code{\link[utils]{install.packages}}
#'
#' @importFrom utils install.packages
#'
#' @export
#' @examples
#' \dontrun{
#' install_if_missing(c("dplyr","fcuk","rusk"))
#' }
#'
install_if_missing <- function(to_be_installed, ...) {
  already_installed <- basename(try(find.package(to_be_installed), silent = TRUE))
  will_be_installed <- setdiff(to_be_installed, already_installed)

  if ( length(will_be_installed) == 0 ) {
    cat("All required packages are installed")
    return(invisible(NULL))
  }
  cat("Installation of: ", will_be_installed)

  install.packages(will_be_installed, ...)
}
