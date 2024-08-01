#' Amend DESCRIPTION with dependencies read from package code parsing
#'
#' Amend package DESCRIPTION file with the list of dependencies extracted from
#' R, examples, tests, vignettes files.
#' att_to_desc_from_pkg() is an alias of att_amend_desc(),
#' for the correspondence with [att_to_desc_from_is()].
#'
#' @param path path to the root of the package directory. Default to current directory.
#' @param path.n path to namespace file.
#' @param dir.r path to directory with R scripts.
#' @param dir.v path to vignettes directory. Set to empty (dir.v = "") to ignore.
#' @param dir.t path to tests directory. Set to empty (dir.t = "") to ignore.
#' @param extra.suggests vector of other packages that should be added in Suggests (pkgdown, covr for instance)
#' @param pkg_ignore vector of packages names to ignore.
#' @param update.config logical. Should the parameters used in this call be saved in the config file of the package
#' @param use.config logical. Should the command use the parameters from the config file to run
#' @param path.c character Path to the yaml config file where parameters are saved
#'
#' @inheritParams att_from_namespace
#' @inheritParams att_to_desc_from_is
#' @inheritParams att_from_rmds
#' @inheritParams att_from_examples
#'
#' @importFrom desc description
#'
#' @return Update DESCRIPTION file.
#'
#' @details
#'
#' Your daily use is to run `att_amend_desc()`, as is.
#' You will want to run this function sometimes with some extra information like
#' `att_amend_desc(pkg_ignore = "x", update.config = TRUE)` if you have to update
#' the configuration file.
#' Next time `att_amend_desc()` will use these parameters from the configuration
#' file directly.
#'
#'
#' @export
#' @examples
#'
#' # Run on an external "dummypackage" as an example
#' # For your local use, you do not have to specify the `path` as below
#' # By default, `att_amend_desc()` will run on the current working directory
#'
#' # Create a fake package for the example
#' tmpdir <- tempfile(pattern = "description")
#' dir.create(tmpdir)
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#'
#' # Update documentation and dependencies
#' att_amend_desc(path = dummypackage)
#'
#' # You can look at the content of this external package
#' #' # browseURL(dummypackage)
#'
#' # Update the config file with extra parameters
#' # We recommend that you store this code in a file in your "dev/" directory
#' # to run it when needed
#' att_amend_desc(path = dummypackage, extra.suggests = "testthat", update.config = TRUE)
#'
#' # Next time, in your daily development
#' att_amend_desc(path = dummypackage)
#'
#' # Clean after examples
#' unlink(tmpdir, recursive = TRUE)

att_amend_desc <- function(path = ".",
                           path.n = "NAMESPACE",
                           path.d = "DESCRIPTION",
                           dir.r = "R",
                           dir.v = "vignettes",
                           dir.t = "tests",
                           extra.suggests = NULL,
                           pkg_ignore = NULL,
                           document = TRUE,
                           normalize = TRUE,
                           inside_rmd = FALSE,
                           must.exist = TRUE,
                           check_if_suggests_is_installed = TRUE,
                           update.config = FALSE,
                           use.config = TRUE,
                           path.c = "dev/config_attachment.yaml"
) {

  if (path != ".") {
    old <- setwd(normalizePath(path))
    on.exit(setwd(old))
  }



  path <- normalizePath(path)

  # decide whether to use or update config file ----
  if (isTRUE(update.config) & isTRUE(use.config)) {
    use.config <- FALSE
    message("'update.config' was set to TRUE, hence, 'use.config' was forced to FALSE")
  }

  # extract all current parameter values - ignore config parameters - save also default
  att_params <- names(formals(att_amend_desc))
  att_params <- att_params[!att_params %in% c("path", "update.config", "use.config", "path.c")]
  local_att_params <- mget(att_params)

  params_to_load <- compare_inputs_load_or_save(
    path.c = path.c,
    local_att_params = local_att_params,
    use.config = use.config,
    update.config = update.config)

  if (!is.null(params_to_load)) {
    for (param_name in names(params_to_load)){
      assign(param_name, params_to_load[[param_name]])
    }
    message(c("Documentation parameters were restored from attachment config file."))
  }

  # Save all open files ----
  save_all()

  # Update description ----
  if (!file.exists(path.d)) {
    x3 <- description$new("!new")
    x3$set("Package", basename(path))
    x3$write("DESCRIPTION")
    message("An new path.d =", path.d, " was added to the directory. ",
            "Please fill it. ",
            "\nNext time, you may want to use 'usethis::use_description()'")
  }
  if (path.d == "DESCRIPTION") {path.d <- file.path(normalizePath(path), path.d)}

  # Remove non-existing directories in path.n for Imports
  if (!file.exists(path.n)) {
    if (isTRUE(document)) {
      roxygen2::roxygenise(path, roclets = NULL)
      path.n <- file.path(path, "NAMESPACE")
      message("A new path.n =", path.n, " was added to the directory. ")
    } else {
      message("There is no directory named: ",
              path.n,
              ". This is removed from the Imports exploration")
      path.n <- ""
    }
  }

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
    # imports <- unique(c(imports, att_from_rmds(dir.r, inside_rmd = inside_rmd)))
  }

  # Suggests ----
  suggests <- NULL

  # Get suggests in examples and remove if already in imports
  if (dir.r != "") {
    ex <- att_from_examples(dir.r = dir.r)
    suggests <- c(suggests, ex[!ex %in% imports])
  }

  # Get suggests in vignettes and remove if already in imports
  if (!grepl("^$|^\\s+$$", dir.v)) {
    vg <- att_from_rmds(dir.v, inside_rmd = inside_rmd)
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

  # Ignore `base` from imports and suggests
  imports <- imports[imports != "base"]
  suggests <- suggests[suggests != "base"]

  # Build DESCRIPTION ----
  att_to_desc_from_is(path.d, imports, suggests, normalize, must.exist, check_if_suggests_is_installed = check_if_suggests_is_installed)
}

#' @rdname att_amend_desc
#' @export
att_to_desc_from_pkg <- att_amend_desc

#' Amend DESCRIPTION with dependencies from imports and suggests package list
#'
#' @param path.d path to description file.
#' @param imports character vector of package names to add in Imports section
#' @param suggests character vector of package names to add in Suggests section
#' @param check_if_suggests_is_installed Logical. Whether to require that packages in the Suggests section are installed.
#' @param normalize Logical. Whether to normalize the DESCRIPTION file. See [desc::desc_normalize()]
#' @param must.exist Logical. If TRUE then an error is given if packages do not exist
#' within installed packages. If NA, a warning.
#'
#' @importFrom desc description
#' @importFrom glue glue glue_collapse
#'
#' @export
#'
#' @return Fill in Description file
#'
#' @details
#' `must.exist` is better set to `TRUE` during package development.
#' This stops the process when a package does not exists on your system.
#' This avoids check errors with typos in package names in DESCRIPTION.
#' When used in CI to discover dependencies, for a bookdown for instance,
#' you may want to set to `FALSE` (no message at all) or `NA` (warning for not installed).
#'
#' @examples
#' tmpdir <- tempfile(pattern = "descfromis")
#' dir.create(tmpdir)
#' file.copy(system.file("dummypackage",package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # browseURL(dummypackage)
#' att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
#' imports = c("magrittr", "attachment"), suggests = c("knitr"))
#'
#' # In combination with other functions
#' att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
#' imports = att_from_rscripts(file.path(dummypackage, "R")),
#' suggests = att_from_rmds(file.path(dummypackage, "vignettes")))
#'
#' # Clean temp files after this example
#' unlink(tmpdir, recursive = TRUE)

att_to_desc_from_is <- function(path.d = "DESCRIPTION", imports = NULL,
                                suggests = NULL, check_if_suggests_is_installed = TRUE, normalize = TRUE,
                                must.exist = TRUE) {

  if (!file.exists(path.d)) {
    x3 <- description$new("!new")
    if (path.d == "DESCRIPTION") {path.d <- file.path(normalizePath("."), path.d)}
    x3$set("Package", basename(dirname(path.d)))
    x3$write(path.d)
    message("An new path.d =", path.d, " was added to the directory. ",
            "Please fill it. ",
            "\nNext time, you may want to use 'usethis::use_description()'")
  }

  desc <- description$new(path.d)
  pkg_name <- desc$get("Package")
  # Remove pkg name from imports
  imports <- imports[imports != pkg_name]
  # Remove pkg name from suggests
  suggests <- suggests[suggests != pkg_name]
  # check that packages are installed

  # rlang::check_installed("pkg")
  # imports
  check_installed <- c(imports)
  if (check_if_suggests_is_installed){
    check_installed <- c(check_installed, suggests)
  }
  suppressWarnings(
    res <- vapply(
      check_installed, FUN = requireNamespace,
      FUN.VALUE = logical(1), quietly = TRUE)
  )
  missing_packages <- names(res[!res])

  if (length(missing_packages) > 0) {
    if (length(missing_packages) == 1) {
      msg <-
        glue::glue(
          "The package {missing_packages} is missing or misspelled.
             Please correct your typo or install it."
        )
    } else {
      msg <-
        glue::glue(
          "Packages {pkgs} are missing or misspelled.
             Please correct your typos or do the proper installations.",
          pkgs = glue::glue_collapse(missing_packages, sep = ", ", last = " & ")
        )
    }
    if (isTRUE(must.exist)) {
      stop(msg)
    } else if (is.na(must.exist)) {
      warning(msg)
    }
  }

  # Get previous dependencies in Description in case version is set
  deps_desc <- desc$get_deps()
  deps_orig <- deps_desc[deps_desc$type != "Depends",]
  deps_depends_orig <- deps_desc[deps_desc$type == "Depends",]
  deps_linkingto_orig <- deps_desc[deps_desc$type == "LinkingTo",]

  remotes_orig <- desc$get_remotes()
  if (length(remotes_orig) != 0) {
    remotes_orig_pkg <- gsub("^.*/|[.]git|@.*$", "", remotes_orig)
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
  if (isTRUE(normalize)) {
    desc$normalize()
  }
  # Write Description file
  desc$write(file = path.d)

  return(invisible(path.d))
}

