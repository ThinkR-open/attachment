
  # Copy package in a temporary directory
  tmpdir <- tempfile("dummyadd_build_ignore")
  dir.create(tmpdir)
  file.copy(system.file("dummypackage",package = "attachment"), tmpdir, recursive = TRUE)
  dummypackage <- file.path(tmpdir, "dummypackage")
  # browseURL(dummypackage)
  # rstudioapi::filesPaneNavigate(dummypackage)
  cat("truc\nbidul\ngg\n",file = file.path(tmpdir, "dummypackage", ".Rbuildignore"))
  user_warn <- getOption("warn")
  att_amend_desc(path = dummypackage)

    rbuildignore_file <- readLines(file.path(tmpdir, "dummypackage", ".Rbuildignore"))
  test_that("att_amend_desc add dev/ in .Rbuildignore if needed", {
    expect_true(any(grepl("\\^dev\\$",rbuildignore_file)))
  })
  test_that("att_amend_desc dont remove existing ligne", {
    expect_true(any(grepl("truc",rbuildignore_file)))
    expect_true(any(grepl("bidul",rbuildignore_file)))
    expect_true(any(grepl("gg",rbuildignore_file)))
  })
  att_amend_desc(path = dummypackage)
  rbuildignore_file <- readLines(file.path(tmpdir, "dummypackage", ".Rbuildignore"))

  test_that("att_amend_desc dont add dev/ in .Rbuildignore if already here", {
    expect_equal(c("truc", "bidul", "gg", "^dev$"),rbuildignore_file)
  })

