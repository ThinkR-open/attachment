
# Test extract Remotes ----
test_that("find_remotes works with no error", {
  # Cannot verify directly if this works because it depends on user installation
  # From CRAN or Github. At least there should be no error.
  expect_true(length(find_remotes("desc")) == 0 |
                length(find_remotes("desc") == 1))
  # base package avoided
  expect_true(length(find_remotes("stats")) == 0)
})

# find_remotes does not fail with packages installation errors ----

test_that("find_remotes does not fail with packages installation errors", {
  tmplibpath <- tempfile("tmplibpath")
  dir.create(tmplibpath)
  dir.create(file.path(tmplibpath, "emptydir"))

  withr::with_libpaths(tmplibpath, {
    expect_warning(packageDescription("zazazaz"), "no package 'zazazaz' was found")

    expect_message(
      suppressWarnings(
        find_remotes(
          c(
            list.dirs(tmplibpath, full.names = FALSE, recursive = FALSE),
            "dontexistspkg"
          )
        )),
      regexp = "emptydir.*dontexistspkg.*They are removed from exploration."
    )
  })

  unlink(tmplibpath, recursive = TRUE)

  expect_warning(
  expect_message(
    res <- find_remotes("dontexistspkg"),
    regexp = "dontexistspkg does not seem to be a package. It is removed from exploration."
  )
  )
  expect_null(res)
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
  expect_equal(extract_pkg_info(fake_desc_github)[["fusen"]], "ThinkR-open/fusen")

  # GitLab
  fake_desc_gitlab <- list(
    list(
      RemoteType = "gitlab",
      RemoteHost = "gitlab.com",
      RemoteRepo = "fakepkg",
      RemoteUsername = "statnmap"
    )
  ) %>% setNames("fakepkg")
  expect_equal(extract_pkg_info(fake_desc_gitlab)[["fakepkg"]], "gitlab::statnmap/fakepkg")

  # Git
  fake_desc_git <- list(
    list(
      RemoteType = "xgit",
      RemoteUrl = "https://github.com/fakepkggit.git"
    )
  ) %>% setNames("fakepkggit")
  expect_equal(extract_pkg_info(fake_desc_git)[["fakepkggit"]], "git::https://github.com/fakepkggit.git")

  fake_desc_git2r <- list(
    list(
      RemoteType = "git2r",
      RemoteUrl = "https://MyForge.com/fakepkggit2r",
      RemoteRepo = NULL,
      RemoteUsername = NULL
    )
  ) %>% setNames("fakepkggit2r")
  expect_equal(extract_pkg_info(fake_desc_git2r)[["fakepkggit2r"]], "git::https://MyForge.com/fakepkggit2r")

  # Bioconductor
  fake_desc_bioc <- list(
    list(
      URL = "https://bioconductor.org/packages/fakepkgbioc",
      git_branch = "RELEASE_3_3",
      Package = "fakepkgbioc"
    )
  ) %>% setNames("fakepkgbioc")
  expect_equal(extract_pkg_info(fake_desc_bioc)[["fakepkgbioc"]], "bioc::3.3/fakepkgbioc")

  # Other installations
  # local package path
  fake_desc_local <- list(
    list(
      RemoteType = "local",
      RemoteUrl = "/path/fakelocal",
      RemoteHost = NULL,
      RemoteRepo = NULL,
      RemoteUsername = NULL
    )
  ) %>% setNames("fakelocal")

  expect_equal(extract_pkg_info(fake_desc_local)[["fakelocal"]], "local::/path/fakelocal")

  # Other specific unknown remotetype
  fake_desc_unknown <- list(
    list(
      RemoteType = "svn",
      RemoteHost = "host",
      RemoteRepo = "repo",
      RemoteUsername = "username"
    )
  ) %>% setNames("fakeunknown")

  expect_equal(extract_pkg_info(fake_desc_unknown)[["fakeunknown"]], c("Maybe ?" = "svn::host:username/repo"))

  # Other installations
  fake_desc_other <- list(
    list(
      RemoteType = NULL,
      RemoteHost = NULL,
      RemoteRepo = NULL,
      RemoteUsername = NULL
    )
  ) %>% setNames("fakenull")

  expect_true(is.na(extract_pkg_info(fake_desc_other)[["fakenull"]]))
  expect_equal(names(extract_pkg_info(fake_desc_other)[["fakenull"]]), "local maybe ?")

  # Test internal_remotes_to_desc ----
  tmpdir <- tempdir()
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")

  path.d <- file.path(dummypackage, "DESCRIPTION")
  cat("Remotes:\n    ThinkR-open/attachment\n", append = TRUE,
      file = path.d)

  remotes <- c(
    extract_pkg_info(fake_desc_github),
    extract_pkg_info(fake_desc_gitlab),
    extract_pkg_info(fake_desc_other),
    extract_pkg_info(fake_desc_git),
    extract_pkg_info(fake_desc_git2r),
    extract_pkg_info(fake_desc_bioc),
    extract_pkg_info(fake_desc_local)
  )

  expect_error(
    internal_remotes_to_desc(remotes, path.d = path.d, stop.local = TRUE),
    "'fakenull' was probably installed from source locally"
  )

  packages_names_sort <- sort(c('attachment', 'fusen', 'fakepkg', 'fakepkggit',
                                'fakepkggit2r', 'fakepkgbioc', 'fakelocal'))
  expect_message(
    expect_message(
      internal_remotes_to_desc(remotes, path.d = path.d,
                               stop.local = FALSE, clean = FALSE),
      "installed from source locally"
    ),
    paste("Remotes for",
          glue::glue_collapse(glue("'{packages_names_sort}'"), sep = ", ", last = " & "),
          "were added to DESCRIPTION.")
  )

  new_desc <- readLines(path.d)

  w.remotes <- grep('Remotes:', new_desc)
  expect_length(w.remotes, 1)
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "attachment")]
    ),
    "    ThinkR-open/attachment")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fusen")]
    ),
    "    ThinkR-open/fusen")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fakepkg")]
    ),
    "    gitlab::statnmap/fakepkg")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fakepkggit")]
    ),
    "    git::https://github.com/fakepkggit.git")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fakepkgbioc")]
    ),
    "    bioc::3.3/fakepkgbioc")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fakelocal")]
    ),
    "    local::/path/fakelocal")
  expect_equal(
    gsub(",", "",
         new_desc[w.remotes + which(packages_names_sort == "fakepkggit2r")]
    ),
    "    git::https://MyForge.com/fakepkggit2r")


  # Test clean before
  expect_message(
    internal_remotes_to_desc(remotes["fusen"], path.d = path.d,
                             stop.local = FALSE, clean = TRUE),
    regexp = "'fusen' was added to DESCRIPTION")

  new_desc <- readLines(path.d)
  w.remotes <- grep('Remotes:', new_desc)
  expect_length(w.remotes, 1)
  expect_equal(new_desc[w.remotes + 1], "    ThinkR-open/fusen")
  expect_false(any(grepl("attachment", new_desc)))
  expect_false(any(grepl("fakepkg", new_desc)))
  expect_false(any(grepl("fakepkggit", new_desc)))
  expect_false(any(grepl("fakepkggit2r", new_desc)))
  expect_false(any(grepl("fakelocal", new_desc)))
  expect_false(any(grepl("fakepkgbioc", new_desc)))

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

  # Add pkglocal in DESCRIPTION as should be local installed from a path
  desc_lines <- readLines(desc_file)
  desc_lines <- c(desc_lines,"Remotes: \n    local::/path/pkglocal")
  writeLines(desc_lines, con = desc_file)

  expect_message(
    set_remotes_to_desc(desc_file),
    "Package 'attachment' was probably installed from source locally"
  )

})
unlink(dummypackage, recursive = TRUE)

