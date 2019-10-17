#' Amend DESCRIPTION with dependencies read from package code parsing
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
#'
#' @return Update DESCRIPTION file.
#' att_to_desc_from_pkg(), att_amend_desc() are aliases
#'
#' @export
#' @examples
#' tmpdir <- tempdir()
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # browseURL(dummypackage)
#' att_amend_desc(path = dummypackage)

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
  # if (!file.exists(path.n)) {
  #   stop(paste("There is no file named path=", path.n, "in the current directory"))
  # }
  if (!file.exists(path.d)) {
    stop(paste("There is no file named path.d =", path.d, "in the current directory"))
  }
  # if (!is.null(dir.r) & !all(dir.exists(dir.r))) {
  #   stop("One of directories in dir.r=", paste(dir.r, collapse = ", "), "does not exists in the current directory")
  # }

  # Remove non-existing directories in dir.r for Imports
  dir.r.test <- dir.exists(dir.r)
  if (any(dir.r.test)) {
    if (any(!dir.r.test)) {
      message("There is no directory named: ",
              paste(dir.r[!dir.r.test], collapse = ", "),
              ". This is removed from the Imports exploration")
    }
    dir.r <- dir.r[dir.r.test]
  } else {
    dir.r <- ""
  }

  # Remove non-existing directories in path.n for Imports
  path.n.test <- file.exists(path.n)
  if (any(path.n.test)) {
    if (any(!path.n.test)) {
      message("There is no directory named: ",
              paste(path.n[!path.n.test], collapse = ", "),
              ". This is removed from the Imports exploration")
    }
    path.n <- path.n[path.n.test]
  } else {
    path.n <- ""
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

  # Imports ----
  # Find dependencies in namespace and scripts
  imports <- NULL
  if (path.n != "") {
    imports <- unique(c(imports, att_from_namespace(path.n, document = document)))
  }
  if (dir.r != "") {
    # Look for R scripts
    imports <- unique(c(imports, att_from_rscripts(dir.r)))
    # Look for Rmd, in case in a bookdown
    # imports <- unique(c(imports, att_from_rmds(dir.r)))
  }

  # Suggests ----
  suggests <- NULL
  # Get suggests in vignettes and remove if already in imports
  if (!grepl("^$|^\\s+$$", dir.v)) {
    vg <- att_from_rmds(dir.v)
    suggests <- c(suggests, vg[!vg %in% imports])
  }

  # Get suggests in tests and remove if already in imports
  if (!grepl("^$|^\\s+$$", dir.t)) {
    tt <- att_from_rscripts(dir.t)
    suggests <- c(suggests, tt[!tt %in% imports])
  }

  # Ignore packages ----
  if (!is.null(pkg_ignore)) {
    imports <- imports[!imports %in% pkg_ignore]
    suggests <- suggests[!suggests %in% pkg_ignore]
    # suggests_keep <- suggests_keep[!suggests_keep %in% pkg_ignore]
  }
  if (!is.null(extra.suggests)) {
    suggests <- unique(c(suggests, extra.suggests))
  }

  # Build DESCRIPTION ----
  att_to_desc_from_is(path.d, imports, suggests)
}

#' @rdname att_to_description
#' @export
att_to_desc_from_pkg <- att_to_description

#' @rdname att_to_description
#' @export
att_amend_desc <- att_to_description

#' Amend DESCRIPTION with dependencies from imports and suggests package list
#'
#' @param path.d path to description file.
#' @param imports character vector of package names to add in Imports section
#' @param suggests character vector of package names to add in Suggests section
#'
#' @importFrom desc description
#'
#' @export
#'
#' @return Fill in Description file
#'
#' @examples
#' tmpdir <- tempdir()
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # browseURL(dummypackage)
#' att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
#' imports = c("fcuk", "attachment"), suggests = c("knitr"))
#' # In combination with other functions
#' att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
#' imports = att_from_rscripts(file.path(dummypackage, ".R")),
#' suggests = att_from_rmds(file.path(dummypackage, "vignettes")))

att_to_desc_from_is <- function(path.d = "DESCRIPTION", imports = NULL, suggests = NULL) {

  if (!file.exists(path.d)) {
    stop(paste("There is no file named path.d =", path.d, "in the current directory"))
  }

  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  # Remove pkg name from imports
  imports <- imports[imports != pkg_name]
  # Remove pkg name from suggests
  suggests <- suggests[suggests != pkg_name]

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

  # If remotes: remove orig remotes not anymore in imports or suggests
  if (!is.null(remotes_orig_pkg)) {
    remotes_keep_pkg <- remotes_orig_pkg[remotes_orig_pkg %in% c(imports, suggests)] #suggests_keep
    remotes_keep <- remotes_orig[remotes_orig_pkg %in% remotes_keep_pkg]
  } else {
    remotes_keep_pkg <- remotes_keep <- NULL
  }

  # Create new deps dataframe
  all_packages <- c(imports, suggests)
  if (is.null(all_packages)) {all_packages <- character()}

  deps_new <- data.frame(
    type = c(rep("Imports", length(imports)), rep("Suggests", length(suggests))),
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
                paste(Other_depends_keep$package, collapse = ", "),
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

