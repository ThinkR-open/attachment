#' Create a dependencies.R in the `inst` folder
#'
#' @param path path to the DESCRIPTION file
#' @param field DESCRIPTION fied to parse, Import and Depends by default
#' @param to path to dependencies.R "inst/dependencies.R" by default
#'
#' @export
#'
#' @examples
#' \dontrun{
#' create_dependencies_file()
#' }
create_dependencies_file <- function(path = "DESCRIPTION",
                                     field = c("Depends", "Imports"),
                                     to = "inst/dependencies.R") {

  dir.create(dirname(to),recursive = TRUE,showWarnings = FALSE)

  ll <- att_from_description()
content<-  glue::glue('to_install <- c("*{collapse(as.character(ll),sep="\\",\\"")}*")
  for (i in to_install) {
    message(paste("looking for ", i))
    if (!requireNamespace(i)) {
      message(paste("     installing", i))
      install.packages(i)
    }

  }',.open="*{",.close="}*" )



file <- normalizePath(to,mustWork = FALSE)
file.create(file)
cat(content,file = file)

utils::file.edit(file, editor = "internal")


}
