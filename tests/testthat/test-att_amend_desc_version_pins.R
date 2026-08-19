# Version constraints already set in DESCRIPTION must survive att_amend_desc(),
# and dir.r must accept several directories (issues #139 and #140).

copy_dummy <- function() {
  tmpdir <- tempfile("dummypins")
  dir.create(tmpdir)
  file.copy(system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE)
  file.path(tmpdir, "dummypackage")
}

test_that("att_amend_desc keeps a hand-set version when the package also sits under another type (#140)", {
  dummypackage <- copy_dummy()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # `glue` is detected as a Suggests dependency in dummypackage. Pin it in Imports by hand so
  # it appears under two types in DESCRIPTION before the amend.
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("glue", type = "Imports", version = ">= 1.2.0")
  d$write()

  att_amend_desc(
    path = dummypackage,
    document = FALSE,
    check_if_suggests_is_installed = FALSE,
    use.config = FALSE
  )

  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  glue_row <- deps[deps$package == "glue", ]

  expect_equal(nrow(glue_row), 1L)
  # glue is used from a Suggests location, so the scan moves it there; the
  # hand-set version must follow it rather than being reset to "*".
  expect_equal(glue_row$type, "Suggests")
  expect_equal(glue_row$version, ">= 1.2.0")
})

test_that("att_amend_desc keeps the Imports-side version when both types carry different pins (#140)", {
  dummypackage <- copy_dummy()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # A different explicit constraint under each type. Collapsing to one row forces
  # a choice: the Imports-side constraint wins, whatever the row order.
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("glue", type = "Imports", version = ">= 1.2.0")
  d$set_dep("glue", type = "Suggests", version = ">= 9.9.9")
  d$write()

  att_amend_desc(
    path = dummypackage,
    document = FALSE,
    check_if_suggests_is_installed = FALSE,
    use.config = FALSE
  )

  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  glue_row <- deps[deps$package == "glue", ]

  expect_equal(nrow(glue_row), 1L)
  expect_equal(glue_row$version, ">= 1.2.0")
})

test_that("att_amend_desc resolves an Imports/Suggests conflict to Imports, keeping the version (#140)", {
  dummypackage <- copy_dummy()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # `fakepkg` is really used in R/ code, so the scan classifies it as an Imports dependency.
  r_file <- file.path(dummypackage, "R", "fun_pin.R")
  writeLines(
    text = "#' @export\nuse_fake <- function() {\n  fakepkg::run()\n}",
    con = r_file
  )
  # DESCRIPTION carries it under both types: pinned Imports and bare Suggests.
  d <- desc::desc(file = file.path(dummypackage, "DESCRIPTION"))
  d$set_dep("fakepkg", type = "Imports", version = ">= 2.0.0")
  d$set_dep("fakepkg", type = "Suggests", version = "*")
  d$write()

  att_amend_desc(
    path = dummypackage,
    document = FALSE,
    must.exist = FALSE,
    check_if_suggests_is_installed = FALSE,
    use.config = FALSE
  )

  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  fake_row <- deps[deps$package == "fakepkg", ]

  expect_equal(nrow(fake_row), 1L)
  expect_equal(fake_row$type, "Imports")
  expect_equal(fake_row$version, ">= 2.0.0")
})

test_that("att_amend_desc accepts several directories in dir.r (#139)", {
  dummypackage <- copy_dummy()
  on.exit(unlink(dirname(dummypackage), recursive = TRUE), add = TRUE)

  # A runtime dependency used only outside the default scan (here inst/).
  dir.create(file.path(dummypackage, "inst"), showWarnings = FALSE)
  writeLines("clipr::write_clip('x')", file.path(dummypackage, "inst", "main.R"))

  expect_no_error(
    att_amend_desc(
      path = dummypackage,
      dir.r = c("R", "inst"),
      document = FALSE,
      must.exist = FALSE,
      check_if_suggests_is_installed = FALSE,
      use.config = FALSE
    )
  )

  deps <- desc::desc_get_deps(file.path(dummypackage, "DESCRIPTION"))
  expect_true("clipr" %in% deps$package)
})
