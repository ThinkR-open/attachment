# WHICH TYPE WINS WHEN TWO ROWS PIN THE SAME PACKAGE.
#
# `deps_orig` keeps every type but Depends, so Enhances and LinkingTo rows sit in
# it too. Ordering the tie-break on the type *alphabetically* puts "Enhances"
# and "LinkingTo" ahead of "Imports", and an Enhances pin then overrides the
# Imports one. The result is a constraint the maintainer never wrote for that
# type, and strengthening a bound that way can make the package uninstallable.
#
# The precedence is semantic, not alphabetical: Imports is the strongest
# statement a package can make about a dependency it actually uses, so it wins.

copy_dummy_types <- function() {
  tmpdir <- tempfile("dummytypes")
  dir.create(tmpdir)
  file.copy(
    system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE
  )

  return(file.path(tmpdir, "dummypackage"))
}

amend_quietly <- function(path) {
  suppressMessages(suppressWarnings(att_amend_desc(
    path = path,
    document = FALSE,
    must.exist = FALSE,
    check_if_suggests_is_installed = FALSE,
    use.config = FALSE
  )))

  return(invisible(NULL))
}

# `fakepkg` is called in R/, so the scan classifies it under Imports whatever
# DESCRIPTION says. Only the version is in play.
pin_two_types <- function(path, other_type, other_version) {
  writeLines(
    text = "#' @export\nuse_fake <- function() {\n  fakepkg::run()\n}",
    con = file.path(path, "R", "fun_pin_types.R")
  )
  d <- desc::desc(file = file.path(path, "DESCRIPTION"))
  d$set_dep("fakepkg", type = "Imports", version = ">= 2.0.0")
  d$set_dep("fakepkg", type = other_type, version = other_version)
  d$write()

  return(invisible(NULL))
}

fakepkg_row <- function(path) {
  deps <- desc::desc_get_deps(file.path(path, "DESCRIPTION"))

  return(deps[deps$package == "fakepkg", ])
}

test_that("an Enhances pin does not override the Imports pin", {
  dummypackage <- copy_dummy_types()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)
  pin_two_types(dummypackage, other_type = "Enhances", other_version = ">= 9.9.9")

  amend_quietly(dummypackage)
  row <- fakepkg_row(dummypackage)

  expect_equal(nrow(row), 1L)
  expect_equal(row$type, "Imports")
  expect_equal(row$version, ">= 2.0.0")
})

test_that("a LinkingTo pin does not override the Imports pin", {
  dummypackage <- copy_dummy_types()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)
  pin_two_types(dummypackage, other_type = "LinkingTo", other_version = ">= 9.9.9")

  amend_quietly(dummypackage)
  row <- fakepkg_row(dummypackage)

  # LinkingTo is re-appended by the Depends/LinkingTo handling further down, so
  # the package legitimately keeps two rows here. The Imports one is what this
  # test is about: its hand-set bound must be the one it came in with.
  imports_row <- row[row$type == "Imports", ]
  expect_equal(nrow(imports_row), 1L)
  expect_equal(imports_row$version, ">= 2.0.0")
})

test_that("a Suggests pin still loses to the Imports pin", {
  dummypackage <- copy_dummy_types()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)
  pin_two_types(dummypackage, other_type = "Suggests", other_version = ">= 9.9.9")

  amend_quietly(dummypackage)
  row <- fakepkg_row(dummypackage)

  expect_equal(nrow(row), 1L)
  expect_equal(row$type, "Imports")
  expect_equal(row$version, ">= 2.0.0")
})

test_that("an explicit version still beats a bare * whatever the types", {
  dummypackage <- copy_dummy_types()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)
  writeLines(
    text = "#' @export\nuse_fake <- function() {\n  fakepkg::run()\n}",
    con = file.path(dummypackage, "R", "fun_pin_types.R")
  )
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("fakepkg", type = "Imports", version = "*")
  d$set_dep("fakepkg", type = "Suggests", version = ">= 3.0.0")
  d$write()

  amend_quietly(dummypackage)
  row <- fakepkg_row(dummypackage)

  expect_equal(nrow(row), 1L)
  expect_equal(row$version, ">= 3.0.0")
})
