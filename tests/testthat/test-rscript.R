pkgs_to_find <- c("find.me",
                      # "attachment",
                      # "knitr",
                      "findme1",
                      "findme2",
                      "findme3",
                      "findme4",
                      "findme5",
                      "findme6",
                      "findme1a",
                      "findme2a",
                      "findme3a",
                      "findme4a",
                      "findme5a",
                      "findme6a"
)


test_that("rscript well parsed", {

  res <- att_from_rscript(path = "f2.R")

  expect_equal(sort(res), sort(pkgs_to_find))

  # {base} not listed
  expect_false("base" %in% res)

})

# att_from_rscripts accept a vector of files or directory
dir_with_R <- tempfile()
dir.create(dir_with_R)
file.copy("f2.R", to = file.path(dir_with_R, "f2.R"))
path_copy <- file.path(dir_with_R, "f2b.R")
file.copy("f2.R", to = path_copy)
file.copy("f1.Rmd", to = file.path(dir_with_R, "f1.Rmd"))
# Modify second file to add a dep
lines2 <- readLines(path_copy)
lines2[1] <- paste(lines2[1], "; library(find.rscript)")
writeLines(lines2, path_copy)

res_dir <- att_from_rscripts(path = dir_with_R)

all_R_files <- list.files(dir_with_R, full.names = TRUE)
res_files <- att_from_rscripts(path = all_R_files)

test_that("att_from_rscripts well parsed", {
  expect_equal(sort(res_dir), sort(c(pkgs_to_find, "find.rscript")))
  expect_equal(sort(res_files), sort(c(pkgs_to_find, "find.rscript")))

  # {base} not listed
  expect_false("base" %in% res_dir)
  expect_false("base" %in% res_files)

})

# Test escape code not used ----
newline_script <- att_from_rscript(path = "escape_newline.R")

test_that("newline correctly escaped", {
  expect_equal(sort(c("rmarkdown", "glue", "knitr")),
               sort(newline_script))
  expect_true(!"nknitr" %in% newline_script)

})
