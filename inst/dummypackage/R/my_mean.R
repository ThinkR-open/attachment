#' my_mean
#'
#' @param x a vector
#'
#' @export
#' @importFrom magrittr %>%
my_mean <- function(x){
  x <- x %>% stats::na.omit()
  1+1
  sum(x)/base::length(x)
}
