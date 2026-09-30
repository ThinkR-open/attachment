# A VARIABLE IS NOT A PACKAGE NAME ----
#
# `requireNamespace()`, `loadNamespace()` and the `ns` argument of
# `getFromNamespace()` take a character string, evaluated as usual: a bare
# symbol there can only be a variable holding the name, never the name itself.
# `requireNamespace(jsonlite)` is an error in R, not a dependency declaration.
#
# `library()` and `require()` do compute on the unevaluated expression, so a
# symbol IS the package name there, except when the caller passes
# `character.only = TRUE`, which states the opposite.
#
# A name invented from a loop variable travels all the way into DESCRIPTION,
# where `renv` and `pak` then stop on a package that cannot exist (#143).

pkgs_from_lines <- function(lines) {
  script <- tempfile(fileext = ".R")
  writeLines(lines, script)

  return(att_from_rscript(path = script))
}

test_that("requireNamespace() through a variable declares nothing", {
  res <- pkgs_from_lines(c(
    'for (pkg in c("callr", "jsonlite")) {',
    '  if (!requireNamespace(pkg, quietly = TRUE)) stop("missing")',
    "}"
  ))

  expect_false("pkg" %in% res)
})

test_that("requireNamespace() on a string literal still declares the package", {
  res <- pkgs_from_lines('requireNamespace("jsonlite", quietly = TRUE)')

  expect_true("jsonlite" %in% res)
})

test_that("an anonymous function argument is not a package name", {
  res <- pkgs_from_lines(
    "vapply(tools, function(tool) requireNamespace(tool, quietly = TRUE), logical(1))"
  )

  expect_false("tool" %in% res)
})

test_that("loadNamespace() through a variable declares nothing, a literal does", {
  expect_false("some_name" %in% pkgs_from_lines("loadNamespace(some_name)"))
  expect_true("jsonlite" %in% pkgs_from_lines('loadNamespace("jsonlite")'))
})

test_that("the ns argument of getFromNamespace() through a variable declares nothing", {
  expect_false("some_ns" %in% pkgs_from_lines('getFromNamespace("f", ns = some_ns)'))
  expect_true("jsonlite" %in% pkgs_from_lines('getFromNamespace("f", ns = "jsonlite")'))
})

test_that("character.only = TRUE means the first argument is a variable", {
  expect_false("some_name" %in% pkgs_from_lines(
    "library(some_name, character.only = TRUE)"
  ))
  expect_false("some_name" %in% pkgs_from_lines(
    "require(some_name, character.only = TRUE)"
  ))
  expect_true("jsonlite" %in% pkgs_from_lines(
    'library("jsonlite", character.only = TRUE)'
  ))
})

test_that("library() and require() still read a bare symbol as the package", {
  res <- pkgs_from_lines(c("library(findme1)", "require(findme2)"))

  expect_true(all(c("findme1", "findme2") %in% res))
})

test_that("a guard written with a variable leaves no invented package behind", {
  res <- pkgs_from_lines(c(
    'for (paquet in c("callr", "jsonlite")) {',
    "  if (isFALSE(requireNamespace(paquet, quietly = TRUE))) {",
    '    return(list(raison = sprintf("paquet {%s} non installe", paquet)))',
    "  }",
    "}",
    "outils <- c(\"findme1\", \"findme2\")",
    "absents <- outils[!vapply(",
    "  outils,",
    "  function(outil) { requireNamespace(outil, quietly = TRUE) },",
    "  logical(1)",
    ")]"
  ))

  expect_equal(intersect(c("paquet", "outil"), res), character(0))
})
