#' Proposes values for Remotes field for DESCRIPTION file based on your installation
#'
#' @param pkg Character. Packages to test for potential non-CRAN installation
#'
#' @return
#' List of all non-CRAN packages and code to add in Remotes field in DESCRIPTION.
#' NULL otherwise.
#' @importFrom utils packageDescription
#' @export
#'
#' @examples
#' # Find from vector of packages
#' find_remotes(pkg = c("attachment", "desc", "glue"))
#'
#' # Find from Description file
#' dummypackage <- system.file("dummypackage", package = "attachment")
#' att_from_description(
#' path = file.path(dummypackage, "DESCRIPTION")) |>
#' find_remotes()
#'
#' \dontrun{
#' # For the current package directory
#' att_from_description() |> find_remotes()
#' }
#'
#' \donttest{
#' # For a specific package name
#' find_remotes("attachment")
#'
#' # Find remotes from all installed packages
#' find_remotes(list.dirs(.libPaths(), full.names = FALSE, recursive = FALSE))
#' }
find_remotes <- function(pkg) {

  pkgdesc <- lapply(pkg, function(x) {
    packageDescription(x)
  }) %>%
    setNames(pkg)

  # Keep only thos that are packages
  w.notpkg <- which(unlist(lapply(pkgdesc, function(x) all(is.na(x)))))
  if (length(w.notpkg) != 0) {
      message(glue::glue_collapse(names(pkgdesc)[w.notpkg], sep = ", ", last = " & "),
              ifelse(length(w.notpkg) == 1,
                     " does not seem to be a package. It is removed from exploration.",
                     " do not seem to be packages. They are removed from exploration."
              )
      )
    pkgdesc <- pkgdesc[-w.notpkg]
    if (length(pkgdesc) == 0) {return(NULL)}
  }

  extract_pkg_info(pkgdesc)
}

#' Add Remotes field to DESCRIPTION based on your local installation
#'
#' @param stop.local Logical. Whether to stop if package was installed from local source.
#' Message otherwise.
#' @param clean Logical. Whether to clean all existing remotes before run.
#' @inheritParams att_to_desc_from_is
#'
#' @return Used for side effect. Adds Remotes field in DESCRIPTION file.
#' @export
#' @examples
#' tmpdir <- tempfile(pattern = "setremotes")
#' dir.create(tmpdir)
#' file.copy(system.file("dummypackage", package = "attachment"), tmpdir,
#'  recursive = TRUE)
#' dummypackage <- file.path(tmpdir, "dummypackage")
#' # Add remotes field if there are Remotes locally
#' att_amend_desc(dummypackage) |>
#'   set_remotes_to_desc()
#'
#' # Clean temp files after this example
#' unlink(tmpdir, recursive = TRUE)
#'
#' \dontrun{
#' # For your current package
#' att_amend_desc() |>
#'   set_remotes_to_desc()
#' }
set_remotes_to_desc <- function(path.d = "DESCRIPTION", stop.local = FALSE,
                                clean = TRUE) {
  pkgs <- att_from_description(path.d)
  remotes <- find_remotes(pkgs)
  if (is.null(remotes)) {
    message("There are no remote packages installed on your computer to add to description")
    return(NULL)
  } else {
    internal_remotes_to_desc(remotes, path.d, stop.local, clean)
  }
}

#' (internal) Add Remotes field to DESCRIPTION based on your local installation
#'
#' @inheritParams att_from_description
#'
#' @importFrom desc description
#' @noRd
internal_remotes_to_desc <- function(remotes, path.d = "DESCRIPTION",
                                     stop.local = FALSE, clean = TRUE) {
  desc <- description$new(path.d)

  if (!isTRUE(clean)) {
    remotes_orig <- desc$get_remotes()
    names(remotes_orig) <- basename(gsub("^.*/|[.]git", "", remotes_orig))
    new_remotes <- c(
      remotes_orig,
      remotes
    )
  } else if (is.null(remotes) & isTRUE(clean)) {
    desc$clear_remotes()
    # Write Description file
    desc$write(file = path.d)
    message("Remotes were cleaned, no new remote to add.")
    return(NULL)
  } else {
    new_remotes <- remotes
  }
  are.na <- which(unlist(lapply(new_remotes, is.na)))
  pkgs_names <- names(new_remotes[are.na])

  if (length(pkgs_names) != 0) {
    plural <- ifelse(length(pkgs_names) > 1, TRUE, FALSE)
    msg <-
      glue::glue(
        "Package{ifelse(plural, 's', '')} {pkgs} {ifelse(plural, 'were', 'was')} probably installed from source locally.
             Please re-install {ifelse(plural, 'them', 'it')} from CRAN or remote repository if Remotes field is needed.",
        pkgs = glue::glue_collapse(glue("'{pkgs_names}'"), sep = ", ", last = " & ")
      )

    if (isTRUE(stop.local)) {
      stop(msg)
    } else {
      message(msg)
    }
    new_remotes <- new_remotes[-are.na]
  }

  w.unique <- !duplicated(names(new_remotes))
  new_remotes <- unlist(new_remotes)[w.unique]
  new_remotes <- new_remotes[sort(names(new_remotes))]

  if (length(new_remotes) != 0) {
    desc$set_remotes(new_remotes)
    # Write Description file
    desc$write(file = path.d)
    # Message
    plural <- ifelse(length(new_remotes) > 1, TRUE, FALSE)
    message(
      glue::glue(
        "Remotes for {pkgs} {ifelse(plural, 'were', 'was')} added to DESCRIPTION.",
        pkgs = glue::glue_collapse(glue("'{names(new_remotes)}'"), sep = ", ", last = " & ")
      )
    )
  }
}

#' Internal. Core of find_remotes separated for unit tests
#' @param pkgdesc Named list of PackageDescriptions
#' @noRd
extract_pkg_info <- function(pkgdesc) {
  is_cran <- lapply(pkgdesc, function(x) {
    (!is.null(x[["Repository"]]) && !grepl("r-universe", x[["Repository"]])) |
      (!is.null(x[["Priority"]]) && x[["Priority"]] == "base")
  }) %>% unlist()

  pkg_not_cran <- names(is_cran[!is_cran])
  # cran_pkg <- names(cran_or_not[!cran_or_not])

  if (length(pkg_not_cran) == 0) {
    return(NULL)
  } else {
    guess_repo <- lapply(pkg_not_cran, function(x) {
      desc <- pkgdesc[[x]]
      if (!is.null(desc[["Repository"]]) && grepl("r-universe", desc[["Repository"]])) {
        # For when {remotes} and/or {pak} can read universe from Remotes: field ?
        # paste0("universe::", gsub(".r-universe.dev", "", desc[["Repository"]]), "/", desc[["Package"]])
        setNames(NA, paste0("r-universe: need to set options to repos=\"", desc[["Repository"]], "\""))
      } else if (!is.null(desc$RemoteType) && desc$RemoteType == "github") {

        attachment::complete_remote_branch(
          remote = paste(desc$RemoteUsername, desc$RemoteRepo, sep = "/"),
          remoteref = desc$RemoteRef
        )

      } else if (!is.null(desc$RemoteType) && desc$RemoteType %in% c("gitlab", "bitbucket")) {

        attachment::complete_remote_branch(remote = paste0(
          desc$RemoteType,
          "::",
          paste(desc$RemoteUsername, desc$RemoteRepo, sep = "/")
        ),
        remoteref = desc$RemoteRef)

      } else if (!is.null(desc$RemoteType) && desc$RemoteType == "local" && !is.null(desc$RemoteUrl)  && is.null(desc$RemoteHost)) {

        attachment::complete_remote_branch(
          remote = paste0(desc$RemoteType, "::", desc$RemoteUrl),
          remoteref = desc$RemoteRef
        )

      } else if (!is.null(desc$RemoteType) &&
                 !(desc$RemoteType %in% c("github","gitlab","bitbucket","local")) &&
                 grepl("git",x = desc$RemoteType) ){

        attachment::complete_remote_branch(remote = paste0("git::", desc$RemoteUrl),
                               remoteref = desc$RemoteRef)

      } else if (is.null(desc$RemoteType) && isTRUE(grepl("bioconductor",x = desc$URL))) {
        biocversion <-  desc$git_branch %>%
          gsub(pattern = "RELEASE_", replacement = "") %>%
          gsub(pattern = "_", replacement = ".")
        paste0("bioc::",biocversion,"/",desc$Package)
      } else if (!is.null(desc$RemoteType) && !is.null(desc$RemoteHost)) {
        c("Maybe ?" = paste0(desc$RemoteType, "::", desc$RemoteHost, ":",
                                     paste(desc$RemoteUsername, desc$RemoteRepo, sep = "/")))
      } else {
        c("local maybe ?" = NA)
      }
    }) %>%
      setNames(pkg_not_cran)
  }
  guess_repo

}


#' Construct a Remote Branch Reference String
#'
#' This function constructs a reference string for a remote branch in a version control system like Git.
#' It returns a formatted string combining the remote name and a specified branch or reference.
#'
#' @param remote A character string representing the name of the remote repository (e.g., `"origin"`).
#' @param remoteref A character string representing the branch or reference within the remote repository.
#'        Default is `"HEAD"`.
#'
#' @return A character string. If `remoteref` is `"HEAD"`, it returns just the `remote` string. If
#'         `remoteref` is not `"HEAD"`, it returns a string in the format `"remote@remoteref"`.
#' @keywords internal
#' @export
complete_remote_branch <- function(remote, remoteref = "HEAD"){

  if (isTRUE(remoteref != "HEAD")) {
    return(
      paste(remote, remoteref, sep = "@")
    )
  } else {
    return(remote)
  }

}
