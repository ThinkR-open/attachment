
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
      RemoteRepo = "fusen",
      RemoteUsername = "ThinkR-open"
    )
  ) %>% setNames("fusen")
  expect_equal(extract_pkg_info(fake_desc_github)[["fusen"]], "thinkr-open/fusen")

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
  cat("Remotes:\n    thinkr-open/attachment\n", append = TRUE,
      file = path.d)

  remotes <- c(
    extract_pkg_info(fake_desc_github),
    extract_pkg_info(fake_desc_gitlab),
    extract_pkg_info(fake_desc_local)
  )

  expect_error(
    internal_remotes_to_desc(remotes, path.d = path.d, stop.local = TRUE),
    "installed from source locally"
  )

  expect_message(
    expect_message(
      internal_remotes_to_desc(remotes, path.d = path.d,
                               stop.local = FALSE, clean = FALSE),
      "installed from source locally"
    ),
    "Remotes for 'attachment', 'fusen' & 'fakepkg' were added to DESCRIPTION."
  )

  new_desc <- readLines(path.d)

  w.remotes <- grep('Remotes:', new_desc)
  expect_length(w.remotes, 1)
  expect_equal(new_desc[w.remotes + 1], "    thinkr-open/attachment,")
  expect_equal(new_desc[w.remotes + 2], "    thinkr-open/fusen,")
  expect_equal(new_desc[w.remotes + 3], "    gitlab::statnmap/fakepkg")

  # Test clean before
  expect_message(
    internal_remotes_to_desc(remotes["fusen"], path.d = path.d,
                             stop.local = FALSE, clean = TRUE),
    regexp = "'fusen' was added to DESCRIPTION")

  new_desc <- readLines(path.d)
  w.remotes <- grep('Remotes:', new_desc)
  expect_length(w.remotes, 1)
  expect_equal(new_desc[w.remotes + 1], "    thinkr-open/fusen")
  expect_false(any(grepl("attachment", new_desc)))
  expect_false(any(grepl("fakepkg", new_desc)))

  # Test what happens if null and clean FALSE
  expect_message(
  internal_remotes_to_desc(NULL, path.d = path.d,
                           stop.local = FALSE, clean = FALSE),
  regexp = "'fusen' was added to DESCRIPTION")

  new_desc_null <- readLines(path.d)
  expect_equal(new_desc_null, new_desc)

  # Test what happens if null and clean FALSE
  expect_message(
    internal_remotes_to_desc(NULL, path.d = path.d,
                             stop.local = FALSE, clean = TRUE),
    regexp = "Remotes were cleaned, no new remote to add."
  )

  new_desc_null <- readLines(path.d)
  expect_false(any(grepl("Remotes", new_desc_null)))

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
    pkgnames <- glue::glue_collapse(glue::glue("'{names(remotes)}'"), sep = ", ", last = " & ")
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
    "Package 'attachment' was probably installed from source locally"
  )
})
unlink(dummypackage, recursive = TRUE)
