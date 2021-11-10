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

usethis::use_build_ignore("_pkgdown.yml")
pkgdown::build_site()

# PR
usethis::pr_fetch(28)
usethis::pr_push()

# Deprecation
# usethis::

# Do not parse dir.t because of tests
attachment::att_from_rscripts("tests")
roxygen2::roxygenise()
attachment::att_amend_desc(pkg_ignore = c("remotes", "i", "usethis"), #i
                               extra.suggests = c("testthat"), #"pkgdown", "covr",
                               dir.t = "",
                               normalize = FALSE)

attachment::create_dependencies_file(field = c("Depends", "Imports", "Suggests"))

usethis::use_vignette("fill-pkg-description")

# Checks
devtools::build_vignettes()
devtools::check()

# Checks for CRAN release ----
# Check package as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))

# Check content
# remotes::install_github("ThinkR-open/checkhelper")
checkhelper::find_missing_tags()

# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package()

# Check URL are correct
# remotes::install_github("r-lib/urlchecker")
urlchecker::url_check()
urlchecker::url_update()

# check on other distributions
# _rhub
devtools::check_rhub()
rhub::local_check_linux_images()
rhub::local_check_linux(image = "rhub/debian-gcc-release")
rhub::local_check_linux(image = "rhub/debian-clang-devel")

rhub::check(platform = "windows-x86_64-devel", show_status = FALSE)
rhub::check_on_solaris(show_status = FALSE)
aa <- rhub::check_for_cran(show_status = FALSE)
aa

# _win devel
devtools::check_win_devel()
devtools::check_win_release()

# Check reverse dependencies
# remotes::install_github("r-lib/revdepcheck")
usethis::use_git_ignore("revdep/")
usethis::use_build_ignore("revdep/")

devtools::revdep()
library(revdepcheck)
# In another session
id <- rstudioapi::terminalExecute("Rscript -e 'revdepcheck::revdep_check(num_workers = 4)'")
rstudioapi::terminalKill(id)
# See outputs
revdep_details(revdep = "pkg")
revdep_summary()                 # table of results by package
revdep_report() # in revdep/
# Clean up when on CRAN
revdep_reset()

# Update NEWS
# Bump version manually and add list of changes

# Add comments for CRAN
usethis::use_cran_comments(open = rlang::is_interactive())

# Upgrade version number
usethis::use_version(which = c("patch", "minor", "major", "dev")[1])

# Verify you're ready for release, and release
devtools::release()
