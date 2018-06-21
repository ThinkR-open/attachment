#' Add packages to description
#'
#' @param path path to namespace file
#' @param path.d path to description file
#' @param path.v path to vignettes
#'
#' @importFrom desc description
#' @importFrom usethis use_package use_tidy_description
#'
#' @export
att_to_description <- function(path = "NAMESPACE", path.d = "DESCRIPTION",
                               path.v = "vignettes") {
  depends <- att_from_namespace(path)
  vg <- att_from_vignettes(path.v)
  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  suggests <- vg[!vg %in% c(depends, pkg_name)]

  suggest_orig <- desc$get("Suggests")
  if (dir.exists("tests") | grepl("testthat", suggest_orig)) {
    suggests_keep <- "testthat"
  } else {
    suggests_keep <- NULL
  }
  if (file.exists("codecov.yml") | grepl("covr", suggest_orig)) {
    suggests_keep <- c(suggests_keep, "covr")
  } else {
    suggests_keep <- NULL
  }

  desc$del("Imports")
  desc$del("Suggests")
  desc$write(file = "DESCRIPTION")

  # print(paste("Add:", paste(depends, collapse = ", "), "in Depends"))
  tmp <- lapply(depends, use_package)
  # print(paste("Add:", paste(suggests, collapse = ", "), "in Suggests (from vignettes)"))
  tmp <- lapply(c(suggests, suggests_keep), function(x) use_package(x, type = "Suggests"))
  use_tidy_description()
}
