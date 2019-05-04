usethis::use_build_ignore("devstuff_history.R")
usethis::use_readme_rmd()
usethis::use_git()
usethis::use_travis()
usethis::use_news_md()
usethis::use_pkgdown()

usethis::use_code_of_conduct()

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
usethis::use_coverage()
usethis::use_appveyor()

usethis::use_build_ignore("_pkgdown.yml")
pkgdown::build_site()

# Do not parse dir.t because of tests
attachment::att_from_rscripts("tests")
attachment::att_to_description(pkg_ignore = c("remotes", "i"), #i
                               extra.suggests = c("pkgdown", "covr", "testthat"),
                               dir.t = "")

attachment::create_dependencies_file(field = c("Depends", "Imports", "Suggests"))

usethis::use_vignette("fill-pkg-description")

devtools::build_vignettes()
devtools::check()

devtools::check_rhub()
devtools::release()
# devtools::load_all(".")
