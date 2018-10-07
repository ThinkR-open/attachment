#' Create a dependencies.R in the `inst` folder
#'
#' @param path path to the DESCRIPTION file
#' @param field DESCRIPTION fied to parse, "Import" and "Depends" by default. Can add "Suggests"
#' @param to path to dependencies.R. "inst/dependencies.R" by default
#' @param open_file Logical. Open the file created in an editor.
#'
#' @export
#' @importFrom glue glue glue_collapse
#' @importFrom desc description
#'
#' @examples
#' \dontrun{
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#'
#' create_dependencies_file(file.path(dummypackage,"DESCRIPTION"))
#' }
create_dependencies_file <- function(path = "DESCRIPTION",
                                     field = c("Depends", "Imports"),
                                     to = "inst/dependencies.R",
                                     open_file = TRUE) {

  if (!dir.exists(dirname(to))) {
    dir.create(dir_to, recursive = TRUE, showWarnings = FALSE)
    dir_to <- normalizePath(dir_to)
  } else {
    dir_to <- normalizePath(dirname(to))
  }

  # get all packages
  ll <- att_from_description(path=path, field = field)
  # get pkg in remotes

  desc <- description$new(path)
  # Get previous dependencies in Description in case version is set
  # deps_orig <- desc$get_deps()
  remotes_orig <- desc$get_remotes()
  if (length(remotes_orig) != 0) {
    remotes_orig_pkg <- gsub("^.*/", "", remotes_orig)

    # Remove remotes from ll
    ll <- ll[!ll %in% remotes_orig_pkg]

    # Install script
    inst_remotes <- remotes_orig
    # _If no (), then github
    w.github <- !grepl("\\(", remotes_orig)
    inst_remotes[w.github] <- glue("remotes::install_github('{remotes_orig[w.github]}')")
    # _Others (WIP...)
    inst_remotes[!w.github] <- remotes_orig[!w.github]

    # Store content
    remotes_content <- paste("# Remotes ----",
                             "install.packages(\"remotes\")",
                             paste(inst_remotes, collapse = "\n"),
                             sep = "\n")
  } else {
    remotes_content <- "# No Remotes ----"
  }

  content <- glue::glue(
'*{remotes_content}*
# Attachments ----
to_install <- c("*{glue::glue_collapse(as.character(ll), sep="\\", \\"")}*")
  for (i in to_install) {
    message(paste("looking for ", i))
    if (!requireNamespace(i)) {
      message(paste("     installing", i))
      install.packages(i)
    }

  }', .open = "*{", .close = "}*")

  # file <- normalizePath(to, mustWork = FALSE)
  file <- file.path(dir_to, basename(to))
  file.create(file)
  cat(content, file = file)

  if (open_file) {
    utils::file.edit(file, editor = "internal")
  }
}
