#' @importFrom available valid_package_name
only_valid_package_name <- function(vec){
  vec[sapply(vec,valid_package_name)]
}
