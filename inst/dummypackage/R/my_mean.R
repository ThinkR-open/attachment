#' my_mean
#'
#' @param x a vector
#'
#' @export
#' @importFrom magrittr %>%
#' @examples
#' # example code
#' library(utils)
my_mean <- function(x){
  x <- x %>% stats::na.omit()
  1+1
  sum(x)/base::length(x)
}
