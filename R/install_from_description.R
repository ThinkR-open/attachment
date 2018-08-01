#' Install missing package from DESCRIPTION
#'
#' @param path path to the DESCRIPTION file
#' @param field DESCRIPTION fied to parse, Import and Depends by default
#' @param ...  Arguments to be passed to \code{\link[utils]{install.packages}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' install_from_description()
#' }
install_from_description <- function(path = "DESCRIPTION", field = c("Depends", "Imports", "Suggests"),...) {

  to_be_installed <- att_from_description(path = path,field = field)
  already_installed <- names(utils::installed.packages()[,'Package'])
  will_be_installed <- setdiff(to_be_installed, already_installed)
  if ( length(will_be_installed) == 0){
    cat("All required packages are installed")
    return(invisible(NULL))
  }
  cat("Installation of :", will_be_installed)

  utils::install.packages(will_be_installed,...)
}
