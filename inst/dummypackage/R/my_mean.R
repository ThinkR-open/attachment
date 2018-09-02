
#' my_mean
#'
#' @param x a vector
#'
#' @export
#' @importFrom utils na.omit
#' @importFrom magrittr %>% 
my_mean <- function(x){
  x <- x %>% na.omit()
  sum(x)/length(x)
}