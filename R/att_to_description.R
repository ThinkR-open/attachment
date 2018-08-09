#' Add packages to description
#'
#' @param path path to namespace file.
#' @param path.d path to description file.
#' @param dir.r path to directory with R scripts.
#' @param dir.v path to vignettes directory. Set to empty (dir.v = "") to ignore.
#' @param extra.suggests vector of other packages that should be added in Suggests (pkgdown for instance)
#'
#' @inheritParams att_from_namespace
#' @importFrom desc description
#' @importFrom usethis use_package use_tidy_description
#'
#' @export
att_to_description <- function(path = "NAMESPACE", path.d = "DESCRIPTION",
                               dir.r = "R", dir.v = "vignettes",
                               extra.suggests = NULL,
                               document = TRUE) {
  if (!file.exists(path)) {
    stop(paste("There is no file named", path, "in the current directory"))
  }
  if (!file.exists(path.d)) {
    stop(paste("There is no file named", path.d, "in the current directory"))
  }
  if (!dir.exists(dir.r)) {
    stop(paste("There is no directory named", dir.r, "in the current directory"))
  }
  if (dir.v != "" & !dir.exists(dir.v)) {
    stop(paste("There is no directory named", dir.v, "in the current directory"))
  }

  depends <- c(att_from_namespace(path, document = document),
               att_from_rscripts(dir.r))


  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")

  if (dir.v != "") {
    vg <- att_from_rmds(dir.v)
    suggests <- vg[!vg %in% c(depends, pkg_name)]
  } else {
    suggests <- NULL
  }

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
  tmp <- lapply(unique(c(suggests, suggests_keep, extra.suggests)), function(x) use_package(x, type = "Suggests"))
  use_tidy_description()
}
