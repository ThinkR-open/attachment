#' Add packages to description
#'
#' @param path path to the root of the package directory. Default to current directory.
#' @param path.n path to namespace file.
#' @param path.d path to description file.
#' @param dir.r path to directory with R scripts.
#' @param dir.v path to vignettes directory. Set to empty (dir.v = "") to ignore.
#' @param dir.t path to tests directory. Set to empty (dir.t = "") to ignore.
#' @param extra.suggests vector of other packages that should be added in Suggests (pkgdown, covr for instance)
#' @param pkg_ignore vector of packages names to ignore.
#'
#' @inheritParams att_from_namespace
#' @importFrom desc description
# @param add_version Logical. Do you want to add version number of packages to description
#'
#' @export
#' @examples
#' tmpdir <- tempdir()
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # browseURL(dummypackage)
#' att_to_description(path = dummypackage)

att_to_description <- function(path = ".",
                               path.n = "NAMESPACE",
                               path.d = "DESCRIPTION",
                               dir.r = "R",
                               dir.v = "vignettes",
                               dir.t = "tests",
                               extra.suggests = NULL,
                               pkg_ignore = NULL,
                               document = TRUE
) {

  if (path != ".") {
    old <- setwd(normalizePath(path))
    on.exit(setwd(old))
  }
  if (!file.exists(path.n)) {
    stop(paste("There is no file named path=", path.n, "in the current directory"))
  }
  if (!file.exists(path.d)) {
    stop(paste("There is no file named path.d =", path.d, "in the current directory"))
  }
  if (!all(dir.exists(dir.r))) {
    stop("One of directories in dir.r=", paste(dir.r, collapse = ", "), "does not exists in the current directory")
  }

  # Remove non-existing directories for Suggests
  dir.v.test <- dir.exists(dir.v)
  if (any(dir.v.test)) {
    if (any(!dir.v.test)) {
      message("There is no directory named: ",
              paste(dir.v[!dir.v.test], collapse = ", "),
              ". This is removed from the Suggests exploration")
    }
    dir.v <- dir.v[dir.v.test]
  } else {
    dir.v <- ""
  }

  # Remove non-existing directories for Suggests
  dir.t.test <- dir.exists(dir.t)
  if (any(dir.t.test)) {
    if (any(!dir.t.test)) {
      message("There is no directory named: ",
              paste(dir.t[!dir.t.test], collapse = ", "),
              ". This is removed from the Suggests exploration")
    }
    dir.t <- dir.t[dir.t.test]
  } else {
    dir.t <- ""
  }

  # Find dependencies in namespace and scripts
  depends <- unique(c(att_from_namespace(path.n, document = document),
                      att_from_rscripts(dir.r)))
  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  # Remove pkg name from depends
  depends <- depends[depends != pkg_name]

  # Get previous dependencies in Description in case version is set
  deps_desc <- desc$get_deps()
  deps_orig <- deps_desc[deps_desc$type != "Depends",]
  deps_depends_orig <- deps_desc[deps_desc$type == "Depends",]
  deps_linkingto_orig <- deps_desc[deps_desc$type == "LinkingTo",]

  remotes_orig <- desc$get_remotes()
  if (length(remotes_orig) != 0) {
    remotes_orig_pkg <- gsub("^.*/", "", remotes_orig)
  } else {
    remotes_orig_pkg <- NULL
  }

  suggests <- NULL
  # Get suggests in vignettes and remove if already in depends
  if (!grepl("^$|^\\s+$$", dir.v)) {
    vg <- att_from_rmds(dir.v)
    suggests <- c(suggests, vg[!vg %in% c(depends, pkg_name)])
  }

  # Get suggests in tests and remove if already in depends
  if (!grepl("^$|^\\s+$$", dir.t)) {
    tt <- att_from_rscripts(dir.t)
    suggests <- c(suggests, tt[!tt %in% c(depends, pkg_name)])
  }

  # Add suggests for tests and covr
  # suggests_orig <- desc$get("Suggests")
  # if (is.na(suggests_orig)) {
  #   suggests_orig <- NULL
  # }
  # suggests_keep <- NULL
  # if (file.exists("codecov.yml") | isTRUE(grepl("covr", suggests_orig))) {
  #   suggests_keep <- c(suggests_keep, "covr")
  # } else {
  #   suggests_keep <- c(suggests_keep, NULL)
  # }

  # If remotes: remove orig remotes not anymore in depends or suggests
  if (!is.null(remotes_orig_pkg)) {
    remotes_keep_pkg <- remotes_orig_pkg[remotes_orig_pkg %in% c(depends, suggests, extra.suggests)] #suggests_keep
    remotes_keep <- remotes_orig[remotes_orig_pkg %in% remotes_keep_pkg]
  } else {
    remotes_keep_pkg <- remotes_keep <- NULL
  }

  # Ignore packages
  if (!is.null(pkg_ignore)) {
    depends <- depends[!depends %in% pkg_ignore]
    suggests <- suggests[!suggests %in% pkg_ignore]
    # suggests_keep <- suggests_keep[!suggests_keep %in% pkg_ignore]
  }

  # Create new deps dataframe
  all_suggests <- unique(c(suggests, extra.suggests)) #suggests_keep
  all_packages <- c(depends, all_suggests)
  if (is.null(all_packages)) {all_packages <- character()}

  deps_new <- data.frame(
    type = c(rep("Imports", length(depends)), rep("Suggests", length(all_suggests))),
    package = all_packages, stringsAsFactors = FALSE) %>%
    merge(deps_orig[,c("package", "version")],
          by = "package", sort = TRUE, all.x = TRUE, all.y = FALSE) %>%
    .[,c("type", "package", "version")] %>%
    .[order(.$type, .$package), , drop = FALSE] %>%
    .[!duplicated(.$package),]

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
                " is(are) in category 'Depends'. Check your Description file",
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

  if (nrow(deps_linkingto_orig) != 0) {
    deps_linkingto <- deps_linkingto_orig
    message("Package(s) ",
            deps_linkingto$package,
            " is(are) in category 'LinkingTo'. Check your Description file",
            " to be sure it is really what you want."
    )
    deps_new <- rbind(deps_new, deps_linkingto)
  }

  deps_new$version[is.na(deps_new$version)] <- "*"

  # Compare old and new
  removed <- deps_desc$package[!deps_desc$package %in% deps_new$package]
  if (length(removed) > 0) {
    message("[-] ", length(removed), " package(s) removed: ",
            paste(removed, collapse = ", "), ".")
  }
  added <- deps_new$package[!deps_new$package %in% deps_desc$package]
  if (length(added) > 0) {
    message("[+] ", length(added), " package(s) added: ",
            paste(added, collapse = ", "), ".")
  }

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

