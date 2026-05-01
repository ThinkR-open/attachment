#' Get all packages called in examples from R files
#'
#' @param dir.r path to directory with R scripts.
#' @param encoding Encoding passed to [readLines()] when reading source files.
#'  Defaults to `getOption("encoding")` so the system locale is respected,
#'  matching [att_from_rscript()].
#'
#' @return Character vector of packages called with library or require.
#' @examples
#' dummypackage <- system.file("dummypackage",package = "attachment")
#'
#' # browseURL(dummypackage)
#' att_from_examples(dir.r = file.path(dummypackage,"R"))

#' @export
att_from_examples <- function(dir.r = "R", encoding = getOption("encoding")) {
  rfiles <- list.files(dir.r, full.names = TRUE, pattern = "\\.r$", ignore.case = TRUE,recursive = FALSE)

  roxy_file <- tempfile("roxy.examples", fileext = ".R")

  # Extract @examples / @examplesIf blocks via regex on the source instead of
  # roxygen2::parse_file(). parse_file() unconditionally evaluates inline R
  # found in roxygen markdown (e.g. `@param x \`r helper("x")\``), and the
  # evaluation env defaults to baseenv() outside a full roxygenise() context,
  # which makes any package-local helper unresolvable (issue #135).
  all_examples <- unlist(lapply(rfiles, extract_examples_lines, encoding = encoding))
  # Clean \dontrun and \donttest, and replace with '{' on next line
  all_examples_clean <-
    gsub(pattern = "\\\\dontrun\\s*\\{|\\\\donttest\\s*\\{", replacement = "#ICI\n{", x = all_examples)

# Clean escape characters
  all_examples_clean <- gsub(pattern = "\\\\", replacement = "", x = all_examples_clean)

  cat(all_examples_clean, file = roxy_file, sep = "\n")

  all_deps_examples_data <- attachment::att_from_data(all_examples_clean)

  all_deps_examples <- attachment::att_from_rscript(roxy_file)

  file.remove(roxy_file)

  all_deps <- unique(c(all_deps_examples, all_deps_examples_data))

  return(all_deps)
}

# Extract @examples / @examplesIf blocks from a single R source file, returning
# the example code with the leading `#' ` removed. Mirrors the relevant subset
# of roxygen2::parse_file() + block_get_tag_value(tag = "examples") behaviour
# without triggering inline R evaluation of @param markdown.
extract_examples_lines <- function(rfile, encoding = getOption("encoding")) {
  lines <- tryCatch(
    readLines(rfile, warn = FALSE, encoding = encoding),
    error = function(e) {
      warning(
        sprintf("Could not read R script '%s': %s", rfile, conditionMessage(e)),
        call. = FALSE
      )
      character(0)
    }
  )
  if (length(lines) == 0) return(character(0))

  is_roxy <- grepl("^\\s*#'", lines)
  is_tag  <- grepl("^\\s*#'\\s*@", lines)
  is_example_tag <- grepl("^\\s*#'\\s*@examples(If)?\\b", lines)

  out <- character()
  in_example <- FALSE
  for (i in seq_along(lines)) {
    if (is_example_tag[i]) {
      in_example <- TRUE
      first_payload <- sub("^\\s*#'\\s*@examplesIf\\s*", "", lines[i])
      first_payload <- sub("^\\s*#'\\s*@examples\\s*", "", first_payload)
      if (nzchar(first_payload)) {
        out <- c(out, first_payload)
      }
      next
    }
    if (in_example) {
      if (!is_roxy[i] || is_tag[i]) {
        in_example <- FALSE
        next
      }
      out <- c(out, sub("^\\s*#'\\s?", "", lines[i]))
    }
  }
  out
}
