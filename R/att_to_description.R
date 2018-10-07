#' Add packages to description
#'
#' @param path path to namespace file.
#' @param path.d path to description file.
#' @param dir.r path to directory with R scripts.
#' @param dir.v path to vignettes directory. Set to empty (dir.v = "") to ignore.
#' @param extra.suggests vector of other packages that should be added in Suggests (pkgdown for instance)
#'
#' @param pkg_ignore vector of packages to ignore.
#' @inheritParams att_from_namespace
#' @importFrom desc description
# @param add_version Logical. Do you want to add version number of packages to description
#'
#'
#' @export
#' @examples
#'
#' \dontrun{
#' dummypackage <- system.file("dummypackage",package = "attachment")
#' # browseURL(dummypackage)
#' att_to_description(path = file.path(dummypackage,"NAMESPACE"),
#' path.d = file.path(dummypackage,"DESCRIPTION"),
#' dir.r = file.path(dummypackage,"R"),
#' dir.v = file.path(dummypackage,"vignettes")
#' )
#' }
  att_to_description <- function(path = "NAMESPACE", path.d = "DESCRIPTION",
                                 dir.r = "R", dir.v = "vignettes",
                                 extra.suggests = NULL,
                                 pkg_ignore = NULL,
                                 document = TRUE
                                 ) {
  if (!file.exists(path)) {
    stop(paste("There is no file named path=", path, "in the current directory"))
  }
  if (!file.exists(path.d)) {
    stop(paste("There is no file named path.d =", path.d, "in the current directory"))
  }
  if (!dir.exists(dir.r)) {
    stop(paste("There is no directory named dir.r=", dir.r, "in the current directory"))
  }
  if (dir.v != "" & !dir.exists(dir.v)) {
    stop(paste("There is no directory named dir.v=", dir.v, "in the current directory"))
  }

  # Find dependencies in namespace and scripts
  depends <- unique(c(att_from_namespace(path, document = document),
               att_from_rscripts(dir.r)))


  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  # Get previous dependencies in Description in case version is set
  deps_orig <- desc$get_deps()
  remotes_orig <- desc$get_remotes()
  if (length(remotes_orig) != 0) {
    remotes_orig_pkg <- gsub("^.*/", "", remotes_orig)
  } else {
    remotes_orig_pkg <- NULL
  }

  # Get suggests in vignettes and remove if already in depends
  if (dir.v != "") {
    vg <- att_from_rmds(dir.v)
    suggests <- vg[!vg %in% c(depends, pkg_name)]
  } else {
    suggests <- NULL
  }

  # Add suggests for tests and covr
  suggests_orig <- desc$get("Suggests")
  suggests_keep <- NULL
  if (dir.exists("tests") | grepl("testthat", suggests_orig)) {
    suggests_keep <- c(suggests_keep, "testthat")
  } else {
    suggests_keep <- c(suggests_keep, NULL)
  }
  if (file.exists("codecov.yml") | grepl("covr", suggests_orig)) {
    suggests_keep <- c(suggests_keep, "covr")
  } else {
    suggests_keep <- c(suggests_keep, NULL)
  }

  # If remotes: remove orig remotes not anymore in depends or suggests
  if (!is.null(remotes_orig_pkg)) {
    remotes_keep_pkg <- remotes_orig_pkg[remotes_orig_pkg %in% c(depends, suggests, suggests_keep, extra.suggests)]
    remotes_keep <- remotes_orig[remotes_orig_pkg %in% remotes_keep_pkg]
  } else {
    remotes_keep_pkg <- remotes_keep <- NULL
  }

  # Ignore packages
  if (!is.null(pkg_ignore)) {
    depends <- depends[!depends %in% pkg_ignore]
    suggests <- suggests[!suggests %in% pkg_ignore]
    suggests_keep <- suggests_keep[!suggests_keep %in% pkg_ignore]
    extra.suggests <- extra.suggests[!extra.suggests %in% pkg_ignore]
  }

  # Create new deps dataframe
  deps_new <- data.frame(type = "Imports", package = depends, stringsAsFactors = FALSE) %>%
    rbind(data.frame(type = "Suggests", package = unique(c(suggests, suggests_keep, extra.suggests)),
                     stringsAsFactors = FALSE)) %>%
  # deps_new <- deps_new[order(deps_new$type, deps_new$package), , drop = FALSE]
    merge(deps_orig, by = c("type", "package"), sort = TRUE, all.x = TRUE, all.y = FALSE)

  deps_new$version[is.na(deps_new$version)] <- "*"
  # deps_new <- deps_new[order(deps_new$type, deps_new$package),]


  # desc$del("Imports")
  # desc$del("Suggests")
  # desc$write(file = path.d)
  # tmp <- lapply(depends, function(x) devtools::use_package(x, type = "Imports",pkg = dirname(path.d)))
  # tmp <- lapply(unique(c(suggests, suggests_keep, extra.suggests)), function(x) devtools::use_package(x, type = "Suggests",pkg = dirname(path.d)))

  # Deal with remotes
  # desc <- description$new(path.d)
  # desc
  # deps <- desc$get_deps()
  # deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  # deps_orig

  # Remove previous deps
  desc$del_deps()
  # Set new deps
  desc$set_deps(deps_new)

  # remotes <- desc$get_remotes()
  if (length(remotes_keep) != 0) {
    desc$set_remotes(sort(remotes_keep))
  }
  # Reorder sections
  desc$normalize()
  # Write Description file
  desc$write(file = path.d)

}

