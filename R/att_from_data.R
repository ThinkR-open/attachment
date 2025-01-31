#' Look for functions called in data loading code
#'
#' @param chr A character vector containing the code as a string. The code should follow the pattern used for loading data with `data()`, specifying the dataset and package.
#' @return A character vector containing the names of the packages from which datasets are being loaded.
#' @importFrom stringr str_extract_all
#' @export
#' @examples
#'
#' vec_char <- 'data("starwars", package = "dplyr")'
#' att_from_data(vec_char)
att_from_data <- function(chr) {
  pkg <-
    str_extract_all(
      chr,
      '(?<=data\\(\\".{1,100}\\"\\,\\s{0,5}package\\s{0,5}\\=\\s{0,5}\\\")[[:alnum:]\\.]+(?=\\\"\\))'
    ) %>%
    unlist()
  return(pkg)

}
