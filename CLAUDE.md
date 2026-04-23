# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this package is

`{attachment}` is an R package that manages dependencies during R package development: it parses NAMESPACE, `R/`, `vignettes/`, tests, and roxygen examples to discover package calls (`library()`, `pkg::fun()`, `@importFrom`) and rewrites the `Imports` / `Suggests` fields of `DESCRIPTION`. It also offers dependency install helpers and `renv` integration. It can also be used outside of a package to list dependencies of arbitrary R scripts or Rmd/qmd files.

## Common commands

Run from the package root in an R session (the package is developed with `devtools` / `usethis` / `fusen`):

- `devtools::load_all()` — load the in-development package.
- `devtools::document()` — regenerate `NAMESPACE` and `man/*.Rd` from roxygen.
- `devtools::test()` — run the full test suite (`tests/testthat/`).
- `testthat::test_file("tests/testthat/test-amend-description.R")` — run a single test file. The tests in `test-amend-description.R` and `test-renv_create.R` are gated on `NOT_CRAN`; to run them locally wrap with `withr::with_envvar(list("NOT_CRAN" = "true"), { ... })` as in `dev/dev_history.R`.
- `devtools::check()` — full R CMD check (also run by CI via `.github/workflows/R-CMD-check.yaml`).
- `devtools::build_vignettes()` — builds the four vignettes in `vignettes/`.
- `attachment::att_amend_desc()` — the package's own dog-food step to refresh `DESCRIPTION`; parameters are read from `dev/config_attachment.yaml` (edit that file rather than retyping arguments).

There is no `Makefile`; `dev/dev_history.R` is the canonical scratchpad of maintainer commands (dependency refresh, CRAN prep, reverse-dep checks).

## Architecture

### Core function layers

There are three layers, roughly:

1. **Extractors** — pure functions that parse one source and return a character vector of package names. One file per source type: `att_from_namespace.R`, `att_from_rmds.R` (Rmd + qmd), `att_from_rscripts.R`, `att_from_examples.R`, `att_from_data.R`, `att_from_description.R`. These can be called standalone, outside a package.
2. **DESCRIPTION writers** — `att_to_description.R` (despite the filename, this is where `att_amend_desc()` / `att_to_desc_from_pkg()` / `att_to_desc_from_is()` live — this is the biggest file in the package at ~450 lines and orchestrates all the extractors) and `set_remotes.R` (fills `Remotes:` by inspecting locally-installed packages via `find_remotes()`).
3. **Config, install, renv helpers** — `amend_with_config.R` (load/save/compare `dev/config_attachment.yaml`), `install_from_description.R`, `create_dependencies_file.R` + `dependencies_file_text.R` (emit `inst/dependencies.R`), `create_renv.R` (generate dev/prod `renv` lockfiles).

The typical user entry point is `att_amend_desc()`: it calls extractors on each directory, unions the results, classifies into `Imports` vs `Suggests` based on which directory the package was found in, and rewrites `DESCRIPTION` via the `{desc}` package.

### Config-driven parameter loading

`att_amend_desc()` has many arguments (ignore lists, extra suggests, dir overrides). `amend_with_config.R` implements a three-way reconcile between (a) arguments passed by the user, (b) previously-saved values in `dev/config_attachment.yaml`, and (c) function defaults. If the user passes non-default args that also differ from the saved config, it errors and asks the user to pick `update.config = TRUE` or `use.config = FALSE`. When adding a new argument to `att_amend_desc()`, you must also: add it to the `local_att_params` list inside the function, and make sure `save_att_params()`/`load_att_params()` round-trip it.

### Test fixtures

`inst/dummypackage/` is a minimal fake R package used as the fixture for most tests (and README examples). Tests copy it into `tempfile()` before mutating it — preserve that pattern for new tests so they stay hermetic. There is also `inst/dummyfolder/` for non-package script tests, and a collection of `f*.R` / `*.Rmd` / `*.qmd` files under `tests/testthat/` that are raw parse targets for the extractors (not test scripts themselves — they have no `test_that`).

## Conventions

- Tidyverse style guide, roxygen2 with markdown (`Roxygen: list(markdown = TRUE)` in `DESCRIPTION`).
- User-facing changes go in a new bullet at the top of `NEWS.md` under the current development version header.
- New exports must be declared via `@export` roxygen tags; `NAMESPACE` is regenerated, not hand-edited.
- `dev/` is `.Rbuildignore`d — it is developer-only and not shipped to CRAN.
