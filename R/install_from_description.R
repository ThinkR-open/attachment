#' Install missing package from DESCRIPTION
#'
#' @param path path to the DESCRIPTION file
#' @param field DESCRIPTION fied to parse, Import and Depends by default
#' @param ...  Arguments to be passed to \code{\link[utils]{install.packages}}
#' @importFrom  utils install.packages
#' @export
#'
#' @examples
#' \dontrun{
#' install_from_description()
#' }
install_from_description <- function(path = "DESCRIPTION", field = c("Depends", "Imports", "Suggests"),...) {

  to_be_installed <- att_from_description(path = path,field = field)
  install_if_missing(to_be_installed = to_be_installed,...)
}

#' install  packages if missing
#'
#' @param to_be_installed a character vector containing required packages names
#'
#' @export
#'
install_if_missing <- function(to_be_installed,...){
  already_installed <- names(utils::installed.packages()[,'Package'])
  will_be_installed <- setdiff(to_be_installed, already_installed)
  if ( length(will_be_installed) == 0){
    cat("All required packages are installed")
    return(invisible(NULL))
  }
  cat("Installation of :", will_be_installed)

  utils::install.packages(will_be_installed,...)

}
