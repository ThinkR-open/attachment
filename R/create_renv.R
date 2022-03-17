#' create reproducible environments for your R projects with {renv}
#'
#' Tool to create and maintain renv.lock files.
#' The idea is to have 2 distinct files, one for development and the other for deployment.
#' Indeed, although package like {attachment} or {pkgload} must be installed to develop,
#' they are not necessary in your package/application.
#'
#'
#' @param path path to your current package source folder
#' @param dev_pkg package developpement toolbox you need
#' @param folder_to_include folder to scan to detect developpment package
#' @param output path and name of the file created, default is `./renv.lock`
#' @param install_if_missing boolean install missing packages. `TRUE` by default
#'
#' @return a renv.lock file
#' @export
#' @importFrom renv snapshot
#' @importFrom cli cat_bullet
#' @examples
#' \dontrun{
#' create_renv_for_dev()
#' create_renv_for_dev(dev_pkg = "attachment")
#' }
create_renv_for_dev <- function(path=".",
                                dev_pkg = c("renv","devtools", "roxygen2", "usethis", "pkgload",
                                            "testthat","remotes", "covr", "attachment","pak","dockerfiler"),
                                folder_to_include = c("dev/","data-raw/"),
                                output = "renv.lock",
                                install_if_missing = TRUE
){


  folder_to_include <- folder_to_include[dir.exists(file.path(path, folder_to_include))]


  from_r_script <-
    unlist(lapply(
      file.path(path, folder_to_include),
      attachment::att_from_rscripts
    ))


  from_rmd <-
    unlist(lapply(
      file.path(path, folder_to_include),
      attachment::att_from_rmds
    ))

  pkg_list <- c(
    attachment::att_from_description(path = file.path(path,"DESCRIPTION")),
    from_r_script,from_rmd,
    dev_pkg
  )

  if (install_if_missing) {
    attachment::install_if_missing(pkg_list)
  }

  cli::cat_bullet(
    sprintf("create renv.lock at %s",output),
    bullet = "tick",
    bullet_col = "green"
  )

print(pkg_list)
# browser()


# debugonce(renv::snapshot)
  renv::snapshot(packages = pkg_list,lockfile = output,prompt = FALSE,type="packages")
# renv:::renv_activate_prompt("snapshot", library=NULL, prompt =FALSE, project=NULL)
#   renv:::renv_lockfile_create(packages = pkg_list,type="packages", project=NULL)
#   alt <- new <- renv_lockfile_create(project, libpaths, type,
#                                      packages)
  output

}

#' @export
#' @rdname create_renv_for_dev
create_renv_for_prod <-function(path=".",output = "renv.lock.prod"){
  create_renv_for_dev(path = path,dev_pkg = "remotes",folder_to_include=NULL,output = output)
}




cat_green_tick <- function(...) {
  cat_bullet(
    ...,
    bullet = "tick",
    bullet_col = "green"
  )
}
