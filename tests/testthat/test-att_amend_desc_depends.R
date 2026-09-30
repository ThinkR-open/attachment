# A NON-R Depends ENTRY MUST NOT TAKE THE WHOLE DESCRIPTION WITH IT (issue #146).
#
# `length()` on a data frame is its column count, so the guard around the Depends
# block was true even with zero rows kept. The branch then ran on an empty frame,
# and `deps_new[-which(<nothing>), ]` kept nothing: negative indexing by an empty
# index vector is the empty selection, not the complement. Every dependency but
# the ones re-appended below was written out of DESCRIPTION, silently.

copy_dummy_depends <- function() {
  tmpdir <- tempfile("dummydepends")
  dir.create(tmpdir)
  file.copy(
    system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE
  )

  return(file.path(tmpdir, "dummypackage"))
}

amend_capturing <- function(path) {
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

  return(sorties)
}

paquets_de <- function(path) {
  return(desc::desc_get_deps(file.path(path, "DESCRIPTION"))$package)
}

test_that("a Depends entry the scan no longer finds does not take the others with it", {
  dummypackage <- copy_dummy_depends()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("somedep", type = "Depends")
  d$write()
  avant <- paquets_de(dummypackage)

  amend_capturing(dummypackage)
  apres <- paquets_de(dummypackage)

  # `somedep` is not used anywhere, so it goes. Everything the scan does find
  # stays, which is the whole point.
  expect_false("somedep" %in% apres)
  for (garde in c("glue", "magrittr", "stringr", "knitr", "testthat")) {
    expect_true(garde %in% apres, info = garde)
  }
  expect_gt(length(apres), length(avant) - 3L)
})

test_that("nothing is announced as being in Depends when nothing is", {
  dummypackage <- copy_dummy_depends()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("somedep", type = "Depends")
  d$write()

  sorties <- amend_capturing(dummypackage)
  depends <- grep("category 'Depends'", sorties, value = TRUE, fixed = TRUE)

  # The empty list in `Package(s)  is(are) in category 'Depends'` was the only
  # visible trace of the bug.
  expect_length(depends, 0L)
})

test_that("a Depends entry the scan does find is kept there, and announced", {
  dummypackage <- copy_dummy_depends()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # `glue` is really used by the dummypackage, so moving it to Depends by hand
  # exercises the branch with a row in it.
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$del_dep("glue")
  d$set_dep("glue", type = "Depends")
  d$write()

  sorties <- amend_capturing(dummypackage)
  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  glue_row <- deps[deps$package == "glue", ]

  expect_equal(nrow(glue_row), 1L)
  expect_equal(glue_row$type, "Depends")
  expect_true(any(grepl("glue", sorties, fixed = TRUE)))
  # And the rest of the file is untouched by that branch.
  expect_true(all(c("magrittr", "stringr") %in% deps$package))
})

test_that("a package with no Depends at all is unaffected", {
  dummypackage <- copy_dummy_depends()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$del_dep("R")
  d$write()

  amend_capturing(dummypackage)
  apres <- paquets_de(dummypackage)

  expect_true(all(c("glue", "magrittr", "stringr", "knitr") %in% apres))
})
