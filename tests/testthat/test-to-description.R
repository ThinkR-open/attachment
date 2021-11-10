# att_amend_desc ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_amend_desc(path = dummypackage)
desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
namespace_file <- readLines(file.path(tmpdir, "dummypackage", "NAMESPACE"))

test_that("att_amend_desc updates namespace", {
  expect_length(namespace_file, 4)
})

test_that("att_amend_desc updates description", {
  # person() can be 1 or 4 lines depending on {desc} version
  w.depends <- grep("Depends:", desc_file)
  expect_length(w.depends, 1)
  expect_equal(desc_file[w.depends + 1], "    R (>= 3.5.0)")
  expect_equal(desc_file[w.depends + 2], "Imports: ")
  expect_equal(desc_file[w.depends + 3], "    magrittr,")
  expect_equal(desc_file[w.depends + 4], "    stats")
  expect_equal(desc_file[w.depends + 5], "Suggests: ")
  expect_equal(desc_file[w.depends + 6], "    glue,")
  expect_equal(desc_file[w.depends + 7], "    knitr,")
  expect_equal(desc_file[w.depends + 8], "    rmarkdown,")
  expect_equal(desc_file[w.depends + 9], "    testthat")
  expect_equal(desc_file[w.depends + 10], "LinkingTo:" )
  expect_equal(desc_file[w.depends + 11], "    Rcpp")
  # base does not appear
  expect_false(all(grepl("base", desc_file)))
  # utils is removed
  expect_false(all(grepl("utils", desc_file)))
})
unlink(dummypackage, recursive = TRUE)

# att_to_desc_from_is ----
# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
                      imports = c("magrittr", "attachment"), suggests = c("knitr"))

desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))

test_that("att_to_desc_from_is updates description", {
  # person() can be 1 or 4 lines depending on {desc} version
  w.depends <- grep("Depends:", desc_file)
  expect_length(w.depends, 1)
  expect_equal(desc_file[w.depends], "Depends: ")
  expect_equal(desc_file[w.depends + 1], "    R (>= 3.5.0)")
  expect_equal(desc_file[w.depends + 2], "Imports: ")
  expect_equal(desc_file[w.depends + 3], "    attachment,")
  expect_equal(desc_file[w.depends + 4], "    magrittr")
  expect_equal(desc_file[w.depends + 5], "Suggests: ")
  expect_equal(desc_file[w.depends + 6], "    knitr")
  expect_equal(desc_file[w.depends + 7], "LinkingTo:" )
  expect_equal(desc_file[w.depends + 8], "    Rcpp")
})
unlink(dummypackage, recursive = TRUE)

# Test Deprecated ----
# suppressWarnings()
# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
suppressWarnings(att_to_description(path = dummypackage))
desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
namespace_file <- readLines(file.path(tmpdir, "dummypackage", "NAMESPACE"))

test_that("att_to_description still updates namespace", {
  expect_length(namespace_file, 4)
})
unlink(dummypackage, recursive = TRUE)


# Test extract Remotes ----
test_that("find_remotes works with no error", {
  # Cannot verify directly if this works because it depends on user installation
  # From CRAN or Github. At least there should be no error.
  expect_true(length(find_remotes("desc")) == 0 |
                          length(find_remotes("desc") == 1))
  # base package avoided
  expect_true(length(find_remotes("stats")) == 0)
})

# Test core of find_remotes ----
test_that("extract_pkg_info extracts code", {
  # Github
  fake_desc_github <- list(
    list(
      RemoteType = "github",
      RemoteHost = "api.github.com",
      RemoteRepo = "golem",
      RemoteUsername = "ThinkR-open"
    )
  ) %>% setNames("golem")
  expect_equal(extract_pkg_info(fake_desc_github)[["golem"]], "thinkr-open/golem")

  # GitLab
  # Sys.setenv(GITLAB_PAT = "xxxxxxxxxxxxxxxx")
  # remotes::gitlab_pat(FALSE)
  # remotes::install_gitlab("statnmap/fakepkg")
  fake_desc_gitlab <- list(
    list(
      RemoteType = "gitlab",
      RemoteHost = "gitlab.com",
      RemoteRepo = "fakepkg",
      RemoteUsername = "statnmap"
    )
  ) %>% setNames("fakepkg")
  expect_equal(extract_pkg_info(fake_desc_gitlab)[["fakepkg"]], "gitlab::statnmap/fakepkg")

  # Other installations
  fake_desc_local <- list(
    list(
      RemoteType = NULL,
      RemoteHost = NULL,
      RemoteRepo = NULL,
      RemoteUsername = NULL
    )
  ) %>% setNames("fakenull")

  expect_true(is.na(extract_pkg_info(fake_desc_local)[["fakenull"]]))
  expect_equal(names(extract_pkg_info(fake_desc_local)[["fakenull"]]), "local maybe ?")

  # Test internal_remotes_to_desc ----
  tmpdir <- tempdir()
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")

  path.d <- file.path(dummypackage, "DESCRIPTION")
  cat("Remotes:\n    thinkr-open/attachment", append = TRUE,
      file = path.d)

  remotes <- c(
    extract_pkg_info(fake_desc_github),
    extract_pkg_info(fake_desc_gitlab),
    extract_pkg_info(fake_desc_local)
  )

  expect_error(
    internal_remotes_to_desc(remotes, path.d = path.d, stop_local = TRUE),
    "installed from source locally"
  )

  expect_message(
    expect_message(
      internal_remotes_to_desc(remotes, path.d = path.d, stop_local = FALSE),
      "installed from source locally"
    ),
    "Remotes for attachment, golem & fakepkg were added to DESCRIPTION."
  )

  new_desc <- readLines(path.d)

  w.remotes <- grep('Remotes:', new_desc)
  expect_length(w.remotes, 1)
  expect_equal(new_desc[w.remotes + 1], "    thinkr-open/attachment,")
  expect_equal(new_desc[w.remotes + 2], "    thinkr-open/golem,")
  expect_equal(new_desc[w.remotes + 3], "    gitlab::statnmap/fakepkg")

  unlink(dummypackage, recursive = TRUE)
})

# test set_remotes_to_desc ----
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")

test_that("set_remotes_to_desc return nothing if local installs", {

  skip_on_cran()
  # We do not know whether some packages are installed manually from source on CRAN

    pkgs <- att_amend_desc(dummypackage) %>%
      att_from_description()
    remotes <- find_remotes(pkgs)

    desc_file <- file.path(dummypackage, "DESCRIPTION")

    if (is.null(remotes)) {
      # Do not test if some are compiled locally
      expect_message(
        set_remotes_to_desc(desc_file),
        "no remote packages installed"
      )
    } else {
      pkgnames <- glue::glue_collapse(names(remotes), sep = ", ", last = " & ")
      nona <- unlist(lapply(remotes, is.na))
      expect_message(
        set_remotes_to_desc(desc_file),
        paste("Remotes for", pkgnames[nona])
      )
    }

    # Add attachment in DESCRIPTION as should be local installed
    desc_lines <- readLines(desc_file)
    desc_lines[desc_lines == "Suggests: "] <- "Suggests: \n    attachment,"
    writeLines(desc_lines, con = desc_file)

    expect_message(
      set_remotes_to_desc(desc_file),
      "Package attachment was probably installed from source locally"
    )
})

# Test missing DESCRIPTION works ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
file.remove(file.path(dummypackage, "DESCRIPTION"))
test_that("Works with missing DESCRIPTION", {
  expect_false(file.exists(file.path(dummypackage, "DESCRIPTION")))
  expect_message(att_amend_desc(path = dummypackage), "use_description")
  expect_true(file.exists(file.path(dummypackage, "DESCRIPTION")))
  desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
  expect_true(grepl("dummypackage", desc_file[1]))
  expect_false(any(grepl("dummypackage", desc_file[-1])))

  file.remove(file.path(dummypackage, "DESCRIPTION"))
  expect_false(file.exists(file.path(dummypackage, "DESCRIPTION")))
  expect_message(att_to_desc_from_is(path = file.path(dummypackage, "DESCRIPTION"),
                                     imports = c("magrittr")), "use_description")
  expect_true(file.exists(file.path(dummypackage, "DESCRIPTION")))
  desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))
  expect_true(grepl("dummypackage", desc_file[1]))
  expect_false(any(grepl("dummypackage", desc_file[-1])))
})

# Test missing NAMESPACE works ----
# Copy package in a temporary directory
tmpdir <- tempfile("dummy")
dir.create(tmpdir)
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
file.remove(file.path(dummypackage, "NAMESPACE"))
test_that("Works with missing DESCRIPTION", {
  expect_false(file.exists(file.path(dummypackage, "NAMESPACE")))
  expect_error(att_from_namespace(file.path(dummypackage, "NAMESPACE")), "attachment::att_amend_desc()")

  expect_message(att_amend_desc(path = dummypackage, document = FALSE),
                 "no directory named: NAMESPACE")
  expect_false(file.exists(file.path(dummypackage, "NAMESPACE")))

  expect_message(att_amend_desc(path = dummypackage), "new path.n")
  expect_true(file.exists(file.path(dummypackage, "NAMESPACE")))

})
