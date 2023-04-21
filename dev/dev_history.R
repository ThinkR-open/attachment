usethis::use_build_ignore("devstuff_history.R")
usethis::use_build_ignore("dev/")
usethis::use_build_ignore("cran-comments.md")
usethis::use_git_ignore("cran-comments.md")
usethis::use_readme_rmd()
usethis::use_git()
usethis::use_travis()
usethis::use_news_md()
usethis::use_pkgdown()

usethis::use_code_of_conduct(contact = "sebastien@thinkr.fr")

library(desc)
library(glue)

fill_desc_generic <- function(
  name, Title,
  Description = "Here.",
  repo = name,
  dev = c("person('Vincent', 'Guyader', email = 'vincent@thinkr.fr', role = c('cre', 'aut'))",
          "person('Sébastien', 'Rochette', email = 'sebastien@thinkr.fr', role = c('aut'))"),
  github_user = "Thinkr-open",
  version = "0.0.0.9000")
{
  unlink("DESCRIPTION")
  my_desc <- desc::description$new("!new")
  my_desc$set("Package", name)
  my_desc$set("Authors@R", glue("c(", glue_collapse(dev, sep = ",\n\t\t"), ")"))
  my_desc$del("Maintainer")
  my_desc$set_version(version)
  my_desc$set(Title = Title)
  my_desc$set(Description = paste(Description))
  my_desc$set("URL", glue("https://github.com/{github_user}/{repo}"))
  my_desc$set("BugReports", glue("https://github.com/{github_user}/{repo}/issues"))
  my_desc$write(file = "DESCRIPTION")
}
fill_desc_generic(
  name = "attachment",
  Description = c(
    "This package contains tools to help manage dependencies during package",
    "development. This can retrieve all dependencies that are used in R files",
    "in the \"R\" directory, in Rmd files in \"vignettes\" directory and in roxygen2",
    "documentation of functions. There is a function to update the Description file",
    "of your package and a function to create a file with the R commands to install",
    "all dependencies of your package. All functions to retrieve dependencies of R",
    "scripts and Rmd files can be used independently of a package development."),
  Title = "Deal with dependencies")

usethis::use_pipe()
# usethis::use_package("stringr")
# usethis::use_package("magrittr")
options(usethis.full_name = "Vincent Guyader")
usethis::use_gpl3_license()
usethis::use_tidy_description()
usethis::use_test("attachment")
usethis::use_test("att_from_namespace")
usethis::use_test("att_to_desc_from_is")
usethis::use_coverage()
usethis::use_appveyor()
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_action("test-coverage")
usethis::use_github_action(url = "https://github.com/DavisVaughan/extrachecks-html5/blob/main/R-CMD-check-HTML5.yaml")

usethis::use_vignette("use_renv")
usethis::use_build_ignore("_pkgdown.yml")
pkgdown::build_site()

# PR ----
usethis::pr_fetch(28)
usethis::pr_push()

# Deprecation
# usethis::

# Document ----
# Do not parse dir.t because of tests
attachment::att_from_rscripts("tests")
usethis::use_roxygen_md()
roxygen2md::roxygen2md()
roxygen2::roxygenise()
attachment::att_amend_desc(
  pkg_ignore = c("remotes", "i", "usethis", "rstudioapi", "renv",
                 "gitlab", "git", "local", "find.rscript", "bioc",
                 "find.me", "findme1", "findme2", "findme3", "findme4",
                 "findme5", "findme6", "findme1a", "findme2a", "findme3a",
                 "findme4a", "findme5a", "findme6a", "ggplot3",
                 "svn", "pkgload", "bookdown"), #i
  extra.suggests = c("testthat", "rstudioapi", "renv", "lifecycle"), #"pkgdown", "covr",
  normalize = FALSE,
  must.exist = TRUE,
  update.config = TRUE)

attachment::create_dependencies_file(field = c("Depends", "Imports", "Suggests"))
attachment::dependencies_file_text(field = c("Depends", "Imports", "Suggests"))

usethis::use_vignette("fill-pkg-description")

# Checks
devtools::build_vignettes()
devtools::check()

# Check for remotes ----
packageDescription("glue")[["Repository"]]
remotes::install_github("tidyverse/glue")
# restart session
rstudioapi::restartSession()
devtools::test()
# install back from CRAN
install.packages("glue")
# restart session
rstudioapi::restartSession()
devtools::test()

# Test specific interactive ----
devtools::load_all()
withr::with_envvar(list("NOT_CRAN" = "true"), {
  testthat::test_file(here::here("tests/testthat/test-amend-description.R"))
  testthat::test_file(here::here("tests/testthat/test-renv_create.R"))
})

# Test for dependencies
tools:::.check_packages_used_in_tests(dir = ".", testdir = "tests/testthat")

# Checks for CRAN release ----

## Prepare for CRAN ----

# Check package coverage
covr::package_coverage()

# _Check in interactive test-inflate for templates and Addins
pkgload::load_all()
devtools::test()
testthat::test_dir("tests/testthat/")

# Test no output generated in the user files
# Run examples in interactive mode too
devtools::run_examples()

# Check that the state is clean after check
all_files <- checkhelper::check_clean_userspace()
all_files

# Check package as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))
# devtools::check(args = c("--no-manual", "--as-cran"))

# Check content
# remotes::install_github("ThinkR-open/checkhelper")
tags <-
  checkhelper::find_missing_tags() # Toutes les fonctions doivent avoir soit `@noRd` soit un `@export`
tags
checkhelper::check_as_cran()

# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package()

# Check URL are correct
# remotes::install_github("r-lib/urlchecker")
urlchecker::url_check()
urlchecker::url_update()

# Upgrade version number
usethis::use_version(which = c("patch", "minor", "major", "dev")[2])
# check on other distributions
# _rhub
# devtools::check_rhub()
buildpath <- devtools::build()
rhub::platforms()
rhub::check_on_windows(check_args = "--force-multiarch",
                       show_status = FALSE,
                       path = buildpath)
rhub::check_on_solaris(show_status = FALSE, path = buildpath)
rhub::check(platform = "debian-clang-devel",
            show_status = FALSE,
            path = buildpath)
rhub::check(platform = "debian-gcc-devel",
            show_status = FALSE,
            path = buildpath)
rhub::check(platform = "fedora-clang-devel",
            show_status = FALSE,
            path = buildpath)
rhub::check(platform = "macos-highsierra-release-cran",
            show_status = FALSE,
            path = buildpath)
rhub::check_for_cran(show_status = FALSE, path = buildpath)
# _win devel
devtools::check_win_devel()
devtools::check_win_release()
# remotes::install_github("r-lib/devtools")
devtools::check_mac_release() # Need to follow the URL proposed to see the results
# Update NEWS
# Bump version manually and add list of changes
# Add comments for CRAN
# Need to .gitignore this file
usethis::use_cran_comments(open = rlang::is_interactive())
usethis::use_git_ignore("cran-comments.md")
usethis::use_git_ignore("CRAN-SUBMISSION")
# Upgrade version number if necessary
usethis::use_version(which = c("patch", "minor", "major", "dev")[1])
# Verify you're ready for release, and release
devtools::release()
