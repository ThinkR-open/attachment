#' Look for functions called with `::`
#'
#' @param path path of the directory with R scripts
#'
#' @return a vector
#' @export
#'
#' @details
#' Calls from pkg::fun in roxygen skeleton are ignored
#'
#' @examples
#' \dontrun{
#' att_from_functions()
#' }
att_from_functions <- function(path = "R") {
  files <- list.files(path, full.names = TRUE)
  lapply(files, function(f) readLines(f) %>%
           .[grep("^#'", ., invert = TRUE)] %>%
      stringr::str_extract_all("[[:alnum:]\\.]+(?=::)") %>%
      unlist() %>% unique()
  ) %>% unlist()
}
