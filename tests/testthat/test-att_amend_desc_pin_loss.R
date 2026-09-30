# A HAND-SET VERSION MUST NOT GO WITHOUT A WORD (issue #139).
#
# `att_amend_desc()` rebuilds the dependency list from what the scan detects, so
# a package pinned in DESCRIPTION but never called in the scanned sources is
# dropped, and its constraint with it. The existing `[-] N package(s) removed`
# line names the package, never the fact that a constraint went with it, so a
# load-bearing `pkgA (>= 1.2.0)` disappears inside a list of ordinary removals.
#
# Widening `dir.r` is the way to keep such a dependency (see `dir.r`), but it
# takes a maintainer who knows. This message is for the one who does not, and it
# covers what `dir.r` cannot reach at all: packages referenced only by string,
# build-only pins, anything the scan has no way to see.

copy_dummy_pin <- function() {
  tmpdir <- tempfile("dummypinloss")
  dir.create(tmpdir)
  file.copy(
    system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE
  )

  return(file.path(tmpdir, "dummypackage"))
}

amend_messages <- function(path) {
  sorties <- character(0)
  withCallingHandlers(
    suppressWarnings(att_amend_desc(
      path = path,
      document = FALSE,
      must.exist = FALSE,
      check_if_suggests_is_installed = FALSE,
      use.config = FALSE
    )),
    message = function(m) {
      sorties <<- c(sorties, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )

  return(paste(sorties, collapse = "\n"))
}

test_that("dropping a package that carried a hand-set version says so, with the constraint", {
  dummypackage <- copy_dummy_pin()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # Pinned by hand, called from nowhere the scan looks.
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("clipr", type = "Imports", version = ">= 1.0.0")
  d$write()

  sorties <- amend_messages(dummypackage)

  expect_match(sorties, "clipr (>= 1.0.0)", fixed = TRUE)
  expect_match(sorties, "version constraint", fixed = TRUE)
})

test_that("dropping a package that carried no version stays on the plain removal line", {
  dummypackage <- copy_dummy_pin()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("clipr", type = "Imports", version = "*")
  d$write()

  sorties <- amend_messages(dummypackage)

  expect_match(sorties, "clipr", fixed = TRUE)
  expect_false(grepl("version constraint", sorties, fixed = TRUE))
})

test_that("a pinned package that the scan still detects raises nothing", {
  dummypackage <- copy_dummy_pin()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  writeLines(
    text = "#' @export\nuse_fake <- function() {\n  fakepkg::run()\n}",
    con = file.path(dummypackage, "R", "fun_kept.R")
  )
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("fakepkg", type = "Imports", version = ">= 2.0.0")
  d$write()

  sorties <- amend_messages(dummypackage)

  expect_false(grepl("version constraint", sorties, fixed = TRUE))
  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  expect_equal(deps$version[deps$package == "fakepkg"], ">= 2.0.0")
})

test_that("widening dir.r keeps the pin, and then there is nothing to report", {
  dummypackage <- copy_dummy_pin()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  dir.create(file.path(dummypackage, "inst"), showWarnings = FALSE)
  writeLines("clipr::write_clip('x')", file.path(dummypackage, "inst", "main.R"))
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("clipr", type = "Imports", version = ">= 1.0.0")
  d$write()

  sorties <- character(0)
  withCallingHandlers(
    suppressWarnings(att_amend_desc(
      path = dummypackage,
      dir.r = c("R", "inst"),
      document = FALSE,
      must.exist = FALSE,
      check_if_suggests_is_installed = FALSE,
      use.config = FALSE
    )),
    message = function(m) {
      sorties <<- c(sorties, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )

  expect_false(grepl("version constraint", paste(sorties, collapse = "\n"), fixed = TRUE))
  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  expect_equal(deps$version[deps$package == "clipr"], ">= 1.0.0")
})
