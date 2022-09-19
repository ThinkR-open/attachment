#' Deprecated functions
#'
#' @description
#' List of functions deprecated. They will be removed in a future release.
#'
#'
#' @name attachment-deprecated
#' @keywords internal
#' @return List of functions used for deprecation side effects.
#' Output depends on the deprecated function.
#' @section Details:
#' \tabular{rl}{
#'    `att_to_description` \tab is now called `att_amend_desc`
#'    so that it is the first function proposed when using auto-completion\cr
#' }
NULL

#' @rdname attachment-deprecated
#' @export
#' @inheritParams att_amend_desc
att_to_description <- function(path = ".",
                               path.n = "NAMESPACE",
                               path.d = "DESCRIPTION",
                               dir.r = "R",
                               dir.v = "vignettes",
                               dir.t = "tests",
                               extra.suggests = NULL,
                               pkg_ignore = NULL,
                               document = TRUE,
                               normalize = TRUE,
                               inside_rmd = FALSE) {
  .Deprecated("att_amend_desc")
  att_amend_desc(path = path,
                 path.n = path.n,
                 path.d = path.d,
                 dir.r = dir.r,
                 dir.v = dir.v,
                 dir.t = dir.t,
                 extra.suggests = extra.suggests,
                 pkg_ignore = pkg_ignore,
                 document = document,
                 normalize = normalize,
                 inside_rmd = inside_rmd)
}
