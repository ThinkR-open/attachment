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
  deps_desc <- desc$get_deps()
  deps_orig <- deps_desc[deps_desc$type != "Depends",]
  deps_depends_orig <- deps_desc[deps_desc$type == "Depends",]

  remotes_orig <- desc$get_remotes()
  if (length(remotes_orig) != 0) {
    remotes_orig_pkg <- gsub("^.*/", "", remotes_orig)
  } else {
    remotes_orig_pkg <- NULL
  }

  # Get suggests in vignettes and remove if already in depends
  if (!grepl("^$|^\\s+$$", dir.v)) {
    vg <- att_from_rmds(dir.v)
    suggests <- vg[!vg %in% c(depends, pkg_name)]
  } else {
    suggests <- NULL
  }

  # Add suggests for tests and covr
  suggests_orig <- desc$get("Suggests")
  if (is.na(suggests_orig)) {
    suggests_orig <- NULL
  }
  suggests_keep <- NULL
  if (dir.exists("tests") | isTRUE(grepl("testthat", suggests_orig))) {
    suggests_keep <- c(suggests_keep, "testthat")
  } else {
    suggests_keep <- c(suggests_keep, NULL)
  }
  if (file.exists("codecov.yml") | isTRUE(grepl("covr", suggests_orig))) {
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
  all_suggests <- c(suggests, suggests_keep, extra.suggests)
  deps_new <- data.frame(
    type = c(rep("Imports", length(depends)), rep("Suggests", length(all_suggests))),
    package = c(depends, all_suggests), stringsAsFactors = FALSE) %>%
    merge(deps_orig[,c("package", "version")],
          by = "package", sort = TRUE, all.x = TRUE, all.y = FALSE) %>%
    .[,c("type", "package", "version")] %>%
    .[order(.$type, .$package), , drop = FALSE]

  # Test if package had Depends category
  if (nrow(deps_depends_orig) != 0) {
    # _Keep depends to specific R version (added below to be first)
    R_depends <- deps_depends_orig[deps_depends_orig$package == "R",]

    # _Test if other Depends still in dependencies
    Other_depends <- deps_depends_orig[deps_depends_orig$package != "R",] %>%
      .[order(.$package),]
    if (nrow(Other_depends) != 0) {
      Other_depends_keep <- Other_depends[Other_depends$package %in% deps_new$package, ]
      if (length(Other_depends_keep) != 0) {
        message("Package(s) ",
                Other_depends_keep$package,
                " is(are) in category Depends. Check your Description file",
                " to be sure it is really what you want."
        )
        # If in Depends, not in Imports
        deps_new <- rbind(Other_depends_keep,
                          deps_new[-which(deps_new$package %in% Other_depends_keep$package),])
      }
    }

    if (nrow(R_depends) != 0) {
      deps_new <- rbind(R_depends, deps_new)
    }
  }

  deps_new$version[is.na(deps_new$version)] <- "*"

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

