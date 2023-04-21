extra_dev_pkg <- c(
  "renv", "fusen", "devtools",
  "roxygen2", "usethis", "pkgload",
  "testthat", "remotes", "covr",
  "attachment", "pak", "dockerfiler",
  "pkgdown"
)

#' Create reproducible environments for your R projects with {renv}
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Tool to create and maintain renv.lock files.
#' The idea is to have 2 distinct files, one for development and the other for deployment.
#' Indeed, although packages like {attachment} or {pkgload} must be installed to develop,
#' they are not necessary in your project, package or Shiny application.
#'
#'
#' @param path Path to your current package source folder
#' @param dev_pkg Vector of packages you need for development. Use `_default`
#' (with underscore before to avoid confusing with a package name), to
#' use the default list. Use `NULL` for no extra package.
#' Use `attachment:::extra_dev_pkg` for the list.
#' @param folder_to_include Folder to scan to detect development packages
#' @param output Path and name of the file created, default is `./renv.lock`
#' @param install_if_missing Logical. Install missing packages. `TRUE` by default
#' @param document Logical. Whether to run [att_amend_desc()] before
#' detecting packages in DESCRIPTION.
#' @param pkg_ignore Vector of packages to ignore from being discovered in your files.
#' This does not prevent them to be in "renv.lock" if they are recursive dependencies.
#' @inheritParams att_to_desc_from_is
#' @param ... Other arguments to pass to [renv::snapshot()]
#'
#' @return a renv.lock file
#'
#'
#' @importFrom cli cat_bullet
#' @export
#'
#' @examples
#' \dontrun{
#' # Writes a renv.lock a file in the user directory
#' create_renv_for_dev()
#' create_renv_for_dev(dev_pkg = "attachment")
#' create_renv_for_prod()
#' }
create_renv_for_dev <- function(path = ".",
                                dev_pkg = "_default",
                                folder_to_include = c("dev", "data-raw"),
                                output = "renv.lock",
                                install_if_missing = TRUE,
                                document = TRUE,
                                pkg_ignore = NULL,
                                check_if_suggests_is_installed = TRUE,
                                ...) {

  if (!requireNamespace("renv")) {
    stop("'renv' is required. Please install it before.")
  }

  path <- normalizePath(path)

  if (!is.null(dev_pkg) && "_default" %in% dev_pkg) {
    cli::cli_alert_info(
      paste('`dev_pkg = _default` includes: ',
            paste(extra_dev_pkg, collapse = ", ")))
    dev_pkg <- c(extra_dev_pkg, dev_pkg[dev_pkg != "_default"])
  }

  if (isTRUE(document)) {
    # Use a temporary config_file for renv
    config_file <- file.path(path, "dev", "config_attachment.yaml")
    if (file.exists(config_file)) {
      yaml_params <- load_att_params(path_to_yaml = config_file)
      yaml_params[["check_if_suggests_is_installed"]] <- check_if_suggests_is_installed
      yamlfile <- tempfile(fileext = ".yaml")
      save_att_params(path_to_yaml = yamlfile, param_list = yaml_params)
      att_amend_desc(path,
                     use.config = TRUE,
                     path.c = yamlfile)
    } else {
      att_amend_desc(path,
                     check_if_suggests_is_installed = check_if_suggests_is_installed,
                     use.config = FALSE)
    }
  }

  if ( isTRUE(check_if_suggests_is_installed)){

  fields <- c("Depends", "Imports", "Suggests")

  } else {

  fields <- c("Depends", "Imports")

  }

  pkg_list <- unique(
    c(
      att_from_description(path = file.path(path, "DESCRIPTION"),field = fields),
      dev_pkg
    )
  )

  # Extra folders
  folder_to_include_relative <- folder_to_include
  folder_to_include <- file.path(path, folder_to_include)
  folder_exists <- dir.exists(folder_to_include)

  if (any(!folder_exists)) {
    cli::cli_alert_info(
      paste(
        "There is no directory named: ",
        paste(folder_to_include_relative[!folder_exists], collapse = ", "),
        ". This is removed from the exploration."
      )
    )
  }

  if (any(folder_exists)) {
    folder_to_include <- folder_to_include[folder_exists]

    # folder_to_include <- folder_to_include[dir.exists(file.path(path, folder_to_include))]

    from_r_script <- att_from_rscripts(folder_to_include)
    from_rmd <- att_from_rmds(folder_to_include)

    pkg_list <- unique(c(pkg_list, from_r_script, from_rmd))
  }

  # Ignore
  if (!is.null(pkg_ignore)) {
    pkg_list <- pkg_list[!pkg_list %in% pkg_ignore]
  }

  # Install
  if (install_if_missing) {
    install_if_missing(pkg_list)
  }

  cli::cat_bullet(
    sprintf("create renv.lock at %s", output),
    bullet = "tick",
    bullet_col = "green"
  )

  renv::snapshot(
    packages = pkg_list,
    lockfile = output,
    prompt = FALSE,
    ...
    # type = "packages"
  )


  if (!file.exists(output)) {
    stop("error during renv.lock creation")
  }

  output
}

#' @export
#' @rdname create_renv_for_dev
create_renv_for_prod <- function(path = ".",
                                 output = "renv.lock.prod",
                                 dev_pkg = "remotes",
                                 check_if_suggests_is_installed = FALSE,
                                 ...) {
  create_renv_for_dev(
    path = path,
    dev_pkg = dev_pkg,
    folder_to_include = NULL,
    output = output,
    check_if_suggests_is_installed = check_if_suggests_is_installed,
    ...
  )
}

