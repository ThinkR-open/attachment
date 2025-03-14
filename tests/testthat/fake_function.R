#' fake function

#' @param x a value

#' @importFrom magrittr %>%
#' @examples
#' library(magrittr)
#' \dontrun{
#' fakepkg::fun()
#' }
#' @export
my_length <- function(x) {
  x %>% length()
}