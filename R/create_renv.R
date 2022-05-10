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
#' @param dev_pkg Package development toolbox you need.
#' Use `NULL` for no extra packages.
#' @param folder_to_include Folder to scan to detect development packages
#' @param output Path and name of the file created, default is `./renv.lock`
#' @param install_if_missing Logical. Install missing packages. `TRUE` by default
#' @param document Logical. Whether to run [att_amend_desc()] before
#' detecting packages in DESCRIPTION.
#' @param ... Other arguments to pass to [renv::snapshot()]
#'
#' @return a renv.lock file
#'
#' @importFrom cli cat_bullet
#' @export
#'
#' @examples
#' \dontrun{
#' create_renv_for_dev()
#' create_renv_for_dev(dev_pkg = "attachment")
#' create_renv_for_prod()
#' }
create_renv_for_dev <- function(path = ".",
                                dev_pkg = c(
                                  "renv",
                                  "devtools",
                                  "roxygen2",
                                  "usethis",
                                  "pkgload",
                                  "testthat",
                                  "remotes",
                                  "covr",
                                  "attachment",
                                  "pak",
                                  "dockerfiler"
                                ),
                                folder_to_include = c("dev", "data-raw"),
                                output = "renv.lock",
                                install_if_missing = TRUE,
                                document = TRUE,
                                ...) {

  if (!requireNamespace("renv")) {
    stop("'renv' is required. Please install it before.")
  }

  path <- normalizePath(path)

  if (isTRUE(document)) {
    att_amend_desc(path)
  }

  pkg_list <-
    c(
      att_from_description(path = file.path(path, "DESCRIPTION")),
      dev_pkg
    )

  # Extra folders
  folder_to_include_relative <- folder_to_include
  folder_to_include <- file.path(path, folder_to_include)
  folder_exists <- dir.exists(folder_to_include)

  if (any(!folder_exists)) {
    message(
      "There is no directory named: ",
      paste(folder_to_include_relative[!folder_exists], collapse = ", "),
      ". This is removed from the exploration."
    )
  }

  if (any(folder_exists)) {
    folder_to_include <- folder_to_include[folder_exists]

    # folder_to_include <- folder_to_include[dir.exists(file.path(path, folder_to_include))]

    from_r_script <- att_from_rscripts(folder_to_include)
    from_rmd <- att_from_rmds(folder_to_include)

    pkg_list <- unique(c(pkg_list, from_r_script, from_rmd))
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
create_renv_for_prod <- function(path = ".", output = "renv.lock.prod", dev_pkg = "remotes", ...) {
  create_renv_for_dev(
    path = path,
    dev_pkg = dev_pkg,
    folder_to_include = NULL,
    output = output,
    ...
  )
}

cat_green_tick <- function(...) {
  cat_bullet(...,
             bullet = "tick",
             bullet_col = "green"
  )
}
