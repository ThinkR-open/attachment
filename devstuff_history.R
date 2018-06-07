usethis::use_build_ignore("devstuff_history.R")
usethis::use_readme_rmd()
usethis::use_git()
usethis::use_travis()
usethis::use_news_md()
options(usethis.full_name = "Vincent Guyader")
usethis::use_gpl3_license()
usethis::use_code_of_conduct()

library(desc)
library(glue)

fill_desc_generic <- function(name, Title,
                              Description = "Here.",
                              repo = name,
                              first_name = "Vincent",
                              last_name = "Guyader",
                              github_user = "Thinkr-open",
                              email = "vincent@thinkr.fr",
                              role = "c('cre', 'aut')",
                              version = "0.0.0.9000"){
  unlink("DESCRIPTION")
  my_desc <- desc::description$new("!new")
  my_desc$set("Package", name)
  my_desc$set("Authors@R",
              glue("person('{first_name}', '{last_name}', email = '{email}', role = {role})"))
  my_desc$del("Maintainer")
  my_desc$set_version(version)
  my_desc$set(Title = Title)
  my_desc$set(Description = Description)
  my_desc$set("URL", glue("https://github.com/{github_user}/{repo}"))
  my_desc$set("BugReports", glue("https://github.com/{github_user}/{repo}/issues"))
  my_desc$write(file = "DESCRIPTION")
}
fill_desc_generic(name = "attachment",
                  Description  = "Tools to help to manage dependencies during pacakge developement.",
                  Title = "Deal with dependencies")

usethis::use_pipe()
usethis::use_package("stringr")
