# from https://github.com/r-lib/devtools/blob/main/R/save-all.R
#' Save all documents in an active IDE session.
#'
#' Helper function wrapping IDE-specific calls to save all documents in the
#' active session. In this form, callers of `save_all()` don't need to
#' execute any IDE-specific code. This function can be extended to include
#' other IDE implementations of their equivalent
#' `rstudioapi::documentSaveAll()` methods.
#' @return NULL
#' @noRd
save_all <- function() {
  if (requireNamespace("rstudioapi") && rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }
}
