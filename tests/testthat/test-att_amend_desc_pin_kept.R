# A HAND-SET VERSION IS NEVER LOST (issue #139).
#
# `att_amend_desc()` rebuilds the dependency list from what the scan detects, so a
# package that no scanned source mentions used to be dropped, and its version
# constraint with it. A pin is written by a person and the scan has no opinion on
# it, so the entry is now kept as declared.
#
# Two situations reached that loss, and one rule closes both: the package is not
# detected at all, or it sits in `pkg_ignore`. The second was the worse of the two,
# since `pkg_ignore` means "do not infer this from code" and used to mean "delete
# what I wrote by hand".
#
# A BARE ENTRY STILL GOES. Nothing is lost when there is no constraint to lose,
# and `pkg_ignore` has to stay usable for cleaning a wrong entry out.

copy_dummy_kept <- function() {
  tmpdir <- tempfile("dummypinkept")
  dir.create(tmpdir)
  file.copy(
    system.file("dummypackage", package = "attachment"), tmpdir, recursive = TRUE
  )

  return(file.path(tmpdir, "dummypackage"))
}

amend_kept <- function(path, ...) {
  sorties <- character(0)
  withCallingHandlers(
    suppressWarnings(att_amend_desc(
      path = path,
      document = FALSE,
      must.exist = FALSE,
      check_if_suggests_is_installed = FALSE,
      use.config = FALSE,
      ...
    )),
    message = function(m) {
      sorties <<- c(sorties, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )

  return(sorties)
}

ligne_de <- function(path, paquet) {
  deps <- desc::desc_get_deps(file.path(path, "DESCRIPTION"))

  return(deps[deps$package == paquet, ])
}

poser <- function(path, paquet, type, version) {
  d <- desc::desc(file = file.path(path, "DESCRIPTION"))
  d$set_dep(paquet, type = type, version = version)
  d$write()

  return(invisible(NULL))
}

test_that("a pinned package the scan does not find is kept, with its type and version", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = ">= 1.0.0")

  amend_kept(pkg)
  ligne <- ligne_de(pkg, "clipr")

  expect_equal(nrow(ligne), 1L)
  expect_equal(ligne$type, "Imports")
  expect_equal(ligne$version, ">= 1.0.0")
})

test_that("a pinned package in pkg_ignore is kept too", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = ">= 1.0.0")

  amend_kept(pkg, pkg_ignore = "clipr")
  ligne <- ligne_de(pkg, "clipr")

  expect_equal(nrow(ligne), 1L)
  expect_equal(ligne$version, ">= 1.0.0")
})

test_that("a pinned Suggests the scan does not find keeps its own type", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Suggests", version = ">= 1.0.0")

  amend_kept(pkg)
  ligne <- ligne_de(pkg, "clipr")

  expect_equal(nrow(ligne), 1L)
  expect_equal(ligne$type, "Suggests")
  expect_equal(ligne$version, ">= 1.0.0")
})

test_that("keeping a pin is announced, and says how to let it go", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = ">= 1.0.0")

  sorties <- amend_kept(pkg)
  tout <- paste(sorties, collapse = "\n")

  expect_match(tout, "clipr (>= 1.0.0)", fixed = TRUE)
  expect_match(tout, "kept", fixed = TRUE)
  # And it is not announced as a removal any more.
  expect_false(grepl("[-] 1 package(s) removed: clipr", tout, fixed = TRUE))
})

test_that("a bare entry the scan does not find is still removed", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = "*")

  sorties <- amend_kept(pkg)

  expect_equal(nrow(ligne_de(pkg, "clipr")), 0L)
  expect_false(grepl("kept", paste(sorties, collapse = "\n"), fixed = TRUE))
})

test_that("a bare entry in pkg_ignore is still removed, so pkg_ignore stays usable", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = "*")

  amend_kept(pkg, pkg_ignore = "clipr")

  expect_equal(nrow(ligne_de(pkg, "clipr")), 0L)
})

test_that("a pinned package the scan does find is untouched, and nothing is announced", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  writeLines(
    text = "#' @export\nuse_fake <- function() {\n  fakepkg::run()\n}",
    con = file.path(pkg, "R", "fun_kept.R")
  )
  poser(pkg, "fakepkg", type = "Imports", version = ">= 2.0.0")

  sorties <- amend_kept(pkg)

  expect_equal(ligne_de(pkg, "fakepkg")$version, ">= 2.0.0")
  expect_false(grepl("kept", paste(sorties, collapse = "\n"), fixed = TRUE))
})

test_that("widening dir.r keeps the pin as a real dependency, with nothing announced", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  dir.create(file.path(pkg, "inst"), showWarnings = FALSE)
  writeLines("clipr::write_clip('x')", file.path(pkg, "inst", "main.R"))
  poser(pkg, "clipr", type = "Imports", version = ">= 1.0.0")

  sorties <- amend_kept(pkg, dir.r = c("R", "inst"))

  expect_equal(ligne_de(pkg, "clipr")$version, ">= 1.0.0")
  expect_false(grepl("kept", paste(sorties, collapse = "\n"), fixed = TRUE))
})

# LES GARANTIES REPRISES DE L'ANCIEN CONTRAT.
#
# Le message d'aujourd'hui annoncait un retrait ; il annonce desormais une
# conservation. Les trois proprietes etablies alors valent toujours, et elles sont
# rejouees ici contre le nouveau contrat : un paquet compte et nomme une seule fois
# meme sous deux types, la version montree est celle que la precedence garde, et le
# bloc sort sur les trois lignes que la vignette documente.

pin_deux_types <- function(path, v_imports, v_suggests) {
  d <- desc::desc(file = file.path(path, "DESCRIPTION"))
  d$set_dep("clipr", type = "Imports", version = v_imports)
  d$set_dep("clipr", type = "Suggests", version = v_suggests)
  d$write()

  return(invisible(NULL))
}

test_that("a package pinned under two types is counted and named once", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  pin_deux_types(pkg, v_imports = ">= 1.0.0", v_suggests = ">= 0.5.0")

  sorties <- paste(amend_kept(pkg), collapse = "\n")
  ligne <- grep("kept though", strsplit(sorties, "\n")[[1]], value = TRUE)[1]

  expect_match(ligne, "[=] 1 package(s) kept though", fixed = TRUE)
  expect_equal(
    lengths(regmatches(ligne, gregexpr("clipr", ligne, fixed = TRUE))), 1L
  )
  expect_equal(nrow(ligne_de(pkg, "clipr")), 1L)
})

test_that("the version kept for a multi-type pin is the one precedence keeps", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  pin_deux_types(pkg, v_imports = ">= 1.0.0", v_suggests = ">= 0.5.0")

  sorties <- paste(amend_kept(pkg), collapse = "\n")

  expect_match(sorties, "clipr (>= 1.0.0)", fixed = TRUE)
  expect_false(grepl(">= 0.5.0", sorties, fixed = TRUE))
  expect_equal(ligne_de(pkg, "clipr")$version, ">= 1.0.0")
})

test_that("the removal line names a bare package once even when two types list it", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  # Sans version, donc rien a conserver : le paquet part, et le comptage par
  # paquet plutot que par ligne reste exige.
  pin_deux_types(pkg, v_imports = "*", v_suggests = "*")

  sorties <- paste(amend_kept(pkg), collapse = "\n")
  ligne <- grep("package(s) removed", strsplit(sorties, "\n")[[1]],
                value = TRUE, fixed = TRUE)[1]

  expect_match(ligne, "[-] 1 package(s) removed: clipr.", fixed = TRUE)
  expect_equal(nrow(ligne_de(pkg, "clipr")), 0L)
})

test_that("the kept-pin guidance is emitted on the three documented lines", {
  pkg <- copy_dummy_kept()
  on.exit(unlink(dirname(pkg), recursive = TRUE), add = TRUE)
  poser(pkg, "clipr", type = "Imports", version = ">= 1.0.0")

  sorties <- paste(amend_kept(pkg), collapse = "\n")
  lignes <- strsplit(sorties, "\n")[[1]]
  debut <- grep("kept though", lignes)[1]
  bloc <- lignes[debut + 0:2]

  expect_match(
    bloc[1],
    "[=] 1 package(s) kept though no scanned source mentions them, because DESCRIPTION pins a version: clipr (>= 1.0.0).",
    fixed = TRUE
  )
  expect_identical(
    bloc[2],
    "    Add the directory where they are used to `dir.r` if they are used,"
  )
  expect_identical(bloc[3], "    or drop the version constraint to let them go.")
})
