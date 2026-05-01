# Create reproducible environments for your R projects with *renv*

**\[experimental\]**

Tool to create and maintain renv.lock files. The idea is to have 2
distinct files, one for development and the other for deployment.
Indeed, although packages like *attachment* or *pkgload* must be
installed to develop, they are not necessary in your project, package or
Shiny application.

## Usage

``` r
create_renv_for_dev(
  path = ".",
  dev_pkg = "_default",
  folder_to_include = c("dev", "data-raw", "renv"),
  folder_to_exclude = c("renv"),
  output = "renv.lock",
  install_if_missing = TRUE,
  document = TRUE,
  pkg_ignore = NULL,
  check_if_suggests_is_installed = TRUE,
  ...
)

create_renv_for_prod(
  path = ".",
  output = "renv.lock.prod",
  dev_pkg = "remotes",
  check_if_suggests_is_installed = FALSE,
  ...
)
```

## Arguments

- path:

  Path to your current package source folder

- dev_pkg:

  Vector of packages you need for development. Use `_default` (with
  underscore before to avoid confusing with a package name), to use the
  default list. Use `NULL` for no extra package. Use
  `attachment:::extra_dev_pkg` for the list.

- folder_to_include:

  Folder to scan to detect development packages

- folder_to_exclude:

  Folder to exclude during scan to detect packages.'renv' by default

- output:

  Path and name of the file created, default is `./renv.lock`

- install_if_missing:

  Logical. Install missing packages. `TRUE` by default

- document:

  Logical. Whether to run
  [`att_amend_desc()`](https://thinkr-open.github.io/attachment/reference/att_amend_desc.md)
  before detecting packages in DESCRIPTION.

- pkg_ignore:

  Vector of packages to ignore from being discovered in your files. This
  does not prevent them to be in "renv.lock" if they are recursive
  dependencies.

- check_if_suggests_is_installed:

  Logical. Whether to require that packages in the Suggests section are
  installed.

- ...:

  Other arguments to pass to
  [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)

## Value

a renv.lock file

## Examples

``` r
if (FALSE) { # \dontrun{
# Writes a renv.lock a file in the user directory
create_renv_for_dev()
create_renv_for_dev(dev_pkg = "attachment")
create_renv_for_prod()
} # }
```
