#' my_mean
#'
#' @param x a vector
#'
#' @export
#' @importFrom utils na.omit
#' @importFrom magrittr %>%
my_mean <- function(x){
  x <- x %>% utils::na.omit()
  1+1
  sum(x)/length(x)
}
