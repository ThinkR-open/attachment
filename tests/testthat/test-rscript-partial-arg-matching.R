# R MATCHES A NAMED ARGUMENT BY PREFIX, NOT BY STRING EQUALITY.
#
# For a named argument that is not an exact formal, R looks for a prefix that is
# unambiguous among the formals the call has not matched yet. Neither `library()`
# nor `require()` has a `...`, and only `character.only` starts with "char", so
# `library(pkgvar, char = TRUE)` runs with character.only effectively TRUE.
#
# Matching the flag by string equality therefore misses the abbreviated spelling
# and reads the variable's own symbol as the package name, which is the very
# defect of #143. And matching the `package` argument by string equality misses
# `library(pack = "jsonlite")`, a real dependency, the same cause turned the other
# way round.

pkgs_of <- function(lines) {
  script <- tempfile(fileext = ".R")
  writeLines(lines, script)

  return(att_from_rscript(path = script))
}

test_that("an abbreviated character.only is honoured, whatever the abbreviation", {
  for (flag in c("character.only", "character.onl", "character", "char", "c")) {
    res <- pkgs_of(sprintf("library(pkgvar, %s = TRUE)", flag))
    expect_false("pkgvar" %in% res, info = flag)
  }
})

test_that("an abbreviated character.only is honoured on require() too", {
  for (flag in c("character.only", "character.o", "char", "c")) {
    res <- pkgs_of(sprintf("require(pkgvar, %s = TRUE)", flag))
    expect_false("pkgvar" %in% res, info = flag)
  }
})

test_that("an abbreviated character.only set to FALSE still reads the symbol", {
  res <- pkgs_of("library(findme1, char = FALSE)")

  expect_true("findme1" %in% res)
})

test_that("an abbreviated package argument is matched", {
  expect_true("jsonlite" %in% pkgs_of('library(pack = "jsonlite")'))
  expect_true("jsonlite" %in% pkgs_of('require(packa = "jsonlite")'))
  expect_true("jsonlite" %in% pkgs_of('requireNamespace(pack = "jsonlite", quietly = TRUE)'))
  expect_true("jsonlite" %in% pkgs_of('loadNamespace(pac = "jsonlite")'))
})

test_that("an abbreviated ns argument of getFromNamespace is matched", {
  expect_true("jsonlite" %in% pkgs_of('getFromNamespace("f", n = "jsonlite")'))
})

test_that("an ambiguous prefix is not matched, and nothing crashes", {
  # `library()` has both `package` and `pos`, so "p" names neither. R would stop
  # on this call; the parser must simply decline to guess.
  expect_silent(res <- pkgs_of('library(pkgvar, p = TRUE)'))

  expect_true(is.character(res))
})

test_that("the exact spellings keep working", {
  expect_false("pkgvar" %in% pkgs_of("library(pkgvar, character.only = TRUE)"))
  expect_true("jsonlite" %in% pkgs_of('library(package = "jsonlite")'))
  expect_true("jsonlite" %in% pkgs_of('requireNamespace(package = "jsonlite", quietly = TRUE)'))
  expect_true("findme1" %in% pkgs_of("library(findme1)"))
  expect_true("findme2" %in% pkgs_of("require(findme2)"))
  expect_false("pkg" %in% pkgs_of("requireNamespace(pkg, quietly = TRUE)"))
})

test_that("the formals come from the running R, not from a table written here", {
  f <- pkg_intro_formals("library")

  expect_identical(f, names(formals(base::library)))
  expect_true("character.only" %in% f)
})

test_that("an unknown call yields no formals, so no partial matching is attempted", {
  expect_identical(pkg_intro_formals("il.n.existe.pas"), character(0))
  expect_true(is.na(match_named_arg(
    c("", "cha"), arg_name = "character.only", formals_names = character(0)
  )))
})

test_that("a formal placed after ... is matched by its exact name only", {
  # R's own rule, not a precaution: anything shorter falls into the dots.
  # `requireNamespace()` is `(package, ..., quietly)` on current R.
  f <- pkg_intro_formals("requireNamespace")
  skip_if_not("..." %in% f, "this R has no ... in requireNamespace()")

  expect_gt(match("quietly", table = f), match("...", table = f))
  expect_true(is.na(match_named_arg(
    c("", "quiet"), arg_name = "quietly", formals_names = f
  )))
  expect_equal(
    match_named_arg(c("", "quietly"), arg_name = "quietly", formals_names = f),
    2L
  )
  # `package` sits before the dots, so it does abbreviate.
  expect_equal(
    match_named_arg(c("pack"), arg_name = "package", formals_names = f), 1L
  )
})
