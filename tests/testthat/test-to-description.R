# att_amend_desc ----
# Copy package in a temporary directory
tmpdir <- tempdir()
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
  expect_equal(desc_file[11], "Depends: ")
  expect_equal(desc_file[12], "    R (>= 3.5.0)")
  expect_equal(desc_file[13], "Imports: ")
  expect_equal(desc_file[14], "    magrittr,")
  expect_equal(desc_file[15], "    stats")
  expect_equal(desc_file[16], "Suggests: ")
  expect_equal(desc_file[17], "    ggplot2,")
  expect_equal(desc_file[18], "    knitr,")
  expect_equal(desc_file[19], "    rmarkdown,")
  expect_equal(desc_file[20], "    testthat")
  expect_equal(desc_file[21], "LinkingTo:" )
  expect_equal(desc_file[22], "    Rcpp")
  # base does not appear
  expect_false(all(grepl("base", desc_file)))
})
unlink(dummypackage, recursive = TRUE)

# att_to_desc_from_is ----
# Copy package in a temporary directory
tmpdir <- tempdir()
file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
dummypackage <- file.path(tmpdir, "dummypackage")
# browseURL(dummypackage)
att_to_desc_from_is(path.d = file.path(dummypackage, "DESCRIPTION"),
                      imports = c("fcuk", "attachment"), suggests = c("knitr"))

desc_file <- readLines(file.path(tmpdir, "dummypackage", "DESCRIPTION"))

test_that("att_to_desc_from_is updates description", {
  expect_equal(desc_file[11], "Depends: ")
  expect_equal(desc_file[12], "    R (>= 3.5.0)")
  expect_equal(desc_file[13], "Imports: ")
  expect_equal(desc_file[14], "    attachment,")
  expect_equal(desc_file[15], "    fcuk")
  expect_equal(desc_file[16], "Suggests: ")
  expect_equal(desc_file[17], "    knitr")
  expect_equal(desc_file[18], "LinkingTo:" )
  expect_equal(desc_file[19], "    Rcpp")
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

# Test core of find_remotes
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
  expect_equal(extract_pkg_info(fake_desc_github)$golem, "thinkr-open/golem")

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
  expect_equal(extract_pkg_info(fake_desc_gitlab)$fakepkg, "gitlab::statnmap/fakepkg")

  # Other installations
  fake_desc_local <- list(
    list(
      RemoteType = NULL,
      RemoteHost = NULL,
      RemoteRepo = NULL,
      RemoteUsername = NULL
    )
  ) %>% setNames("fakenull")

  expect_true(is.na(extract_pkg_info(fake_desc_local)$fakenull))
  expect_equal(names(extract_pkg_info(fake_desc_local)$fakenull), "local maybe ?")
})

