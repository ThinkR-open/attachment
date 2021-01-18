context("test-rmd.R")

# All code including inline code ----
# Rmd packages listed to be found
all_to_be_found <- c(
  "find.me",
  "knitr",
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
  "findme6a",
  "find.inline"
)

test_that("rmd well parsed", {
  res <- sort(attachment::att_from_rmds(path = "."))
  expect_equal(sort(res), sort(all_to_be_found))
})

# Without inline code ----
test_that("rmd well parsed", {
  res <- sort(attachment::att_from_rmds(path = ".", inline = FALSE))
  # attachment::att_from_rmd("f1.Rmd")
  expect_equal(sort(res), sort(setdiff(all_to_be_found, "find.inline")))
})

# Test inside ----
success_file <- rmarkdown::render("insidermd.Rmd", quiet = TRUE)
test_that("test inside rmd works", {
  expect_equal(basename(success_file), "insidermd.html")
})
# clean
file.remove(success_file)

