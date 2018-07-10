#' Add packages to description
#'
#' @param path path to namespace file
#' @param path.d path to description file
#' @param dir.r path to directory with R scripts
#' @param dir.v path to vignettes directory
#'
#' @inheritParams att_from_namespace
#' @importFrom desc description
#' @importFrom usethis use_package use_tidy_description
#'
#' @export
att_to_description <- function(path = "NAMESPACE", path.d = "DESCRIPTION",
                               dir.r = "R", dir.v = "vignettes",
                               document = TRUE) {
  depends <- c(att_from_namespace(path, document = document),
               att_from_rscripts(dir.r))

  vg <- att_from_rmds(dir.v)

  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  suggests <- vg[!vg %in% c(depends, pkg_name)]

  suggests_orig <- desc$get("Suggests")
  if (dir.exists("tests") | grepl("testthat", suggests_orig)) {
    suggests_keep <- "testthat"
  } else {
    suggests_keep <- NULL
  }
  if (file.exists("codecov.yml") | grepl("covr", suggests_orig)) {
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
