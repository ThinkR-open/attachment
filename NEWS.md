# dev version

- fix `create_renv_for_dev` by removing 'renv' from folder_to_include.


# attachment 0.4.5

## Bug fixes 

- `att_from_examples()` Removed escape characters (`\`) from Roxygen examples.

# attachment 0.4.4

## Patch

- `att_from_examples()` Fixed the selection of `.R` files in the source directory. (#124)

# attachment 0.4.3

## New features

- Add `att_from_examples()` to get all packages called in examples from R files
- Add `att_from_data()` to look for functions called in data loading code
- `att_amend_desc` amend package DESCRIPTION file (Suggests) with the list of dependencies extracted from examples in R files.
- `set_remotes_to_desc()` takes into account the branch

## Patch

- Adding an example using suggest packages to the dummypackage
- `att_from_rmds()` and `att_from_rscript` doesn't search in 'renv' folder anymore

# attachment 0.4.2

## New features

- `create_renv_for_dev` can work even outside of an R packages

# attachment 0.4.1

## Bug fixes 

- Modification of unit tests following {roxygen2} changes. `att_amend_desc` and `att_from_namespace` return messages instead of warnings. (@MurielleDelmotte) 

# attachment 0.4.0

## Breaking changes

- When using `att_amend_desc()` without the default parameters, like `pkg_ignore = "x"` will now require `att_amend_desc(pkg_ignore = "x", update.config = TRUE)`, otherwise, it will fail. This allows for the use of parameters stored in the config file when running `att_amend_desc()` directly in the console.
Recommendation: Run `att_amend_desc(pkg_ignore = "x", update.config = TRUE)` if you have to update your config, run `att_amend_desc()` daily as you'll want to use what is stored in the config file.

- `create_dependencies_file()` gets parameter `install_only_if_missing = FALSE` by default to complete the installation instructions packages only if missing. (@MurielleDelmotte) 

## New features

- `att_amend_desc()` can run with the last set of parameters stored in a configuration file, without having to call them all each time. See vignettes and documentation of parameters `update.config = FALSE`, `use.config = FALSE` and `path.c = "dev/config_attachment.yaml"`. (@dagousket)
- `create_dependencies_file()` now takes other sources into account (git, gitlab, github, bioc, local). (@MurielleDelmotte)
- Use `create_dependencies_file(to = NULL)` to only get the output as character and do not create a file

## Bug fixes 

- `att_amend_desc()` does not modify user `options("warn")` level anymore (#94)
- `att_amend_desc()` allows "Remotes" field to contain `@ref` (#67)

# attachment 0.3.1

## New features

- `find_remotes()` now informs when using "r-universe" repositories.

## Minor changes

- a new parameters `check_if_suggests_is_installed` in `att_amend_desc()` allow not to check if suggested package is installed. (thanks to @yogat3ch)
- `create_renv_for_prod()` don't look anymore for suggested packages
- Clean a maximum of temp directories after examples and unit tests

# attachment 0.3.0

## New features

- `find_remotes()` and `set_remotes_to_desc()` now detects github, gitlab, git, bitbucket, local installations to add to the "Remotes:" part of the DESCRIPTION file (@MurielleDelmotte)
- Quarto documents can be parsed with `att_from_qmds()` as an alias of `att_from_rmds()`.

## Minor changes

- Documentation for bookdown and quarto dependencies extraction updated

## Bug fixes 

* Allow to use dependencies after `att_amend_desc()` #52
* Fix HTML5 issues with update to {roxygen2}

# attachment 0.2.5
## Major changes

* add `create_renv_for_dev()` and `create_renv_for_prod()` function to create `renv.lock` file based on development project (@VincentGuyader and @statnmap).
* Quarto documents can be parsed with `att_from_rmds()`.
* Documentation for bookdown and quarto dependencies extraction updated

## Minor changes

* `att_amend_desc()` now saves file before processing
* Newline escape code `\n` will not interfere with package discovery 

# attachment 0.2.4

## Breaking changes

* (broken in 0.2.3) - `att_to_desc_from_is()` can now run with `must.exist = FALSE` to be used to fill
DESCRIPTION file during bookdown CI process. CI YAML files must be updated with this parameter.

## Major changes

- Split vignette in two: package development and other dependencies management

## Minor changes

- Allow to clean remotes list before updating with `set_remotes_to_desc(clean = TRUE)`


# attachment 0.2.3

## Major changes

* Allow to add Remotes field to DESCRIPTION with `set_remotes_to_desc()`

## Minor changes

* Check for packages names misspelled before filling DESCRIPTION.
* Allow vector of R files in `att_from_rscripts()`
* Move default git branch from master to main

## Bug fixes 

* Add NAMESPACE if missing with `att_amend_desc(document = TRUE)`
* Add DESCRIPTION with empty skeleton if missing with `att_amend_desc()`
* Default to remove NAMESPACE before updating to get rid of corrupted ones in `att_from_namespace()`
* Fix detection of multiple render outputs in Rmd YAML with `att_from_rmd()`


# attachment 0.2.1

* Check for older pandoc version in tests

# attachment 0.2.0

Breaking changes
* `att_to_description()` deprecated in favor of `att_amend_desc()` to be first in autocompletion list, as this is the most used function of this package.
* `att_from_rmd()` gets parameter `inline = TRUE` by default to explore calls for packages in inline R code.
* `att_from_rmd()` and `att_from_rmds()` are not anymore executed in separate R session by default. You must set `inside_rmd = TRUE` to do so.

Minor
* Add `find_remotes()` to help fill Remotes field in DESCRIPTION
* `att_to_desc_from_is()` add parameter `normalize` to avoid problem with {desc}. (See https://github.com/r-lib/desc/issues/80)

# attachment 0.1.0

* `att_amend_desc()` is an alias for `att_to_description()`  
* `att_desc_from_is()` amends DESCRIPTION file from imports/suggests vector of packages  
* `att_to_desc_from_pkg()` is an alias for `att_to_description()`  
* Removed dependency to {devtools}, replace by {roxygen}  
* `att_to_description()` shows packages added/removed from DESCRIPTION  
* `att_to_description()` deals with dependencies in tests/ directory  
* `att_from_rmds()` allows user defined regex to detect Rmd files  

# attachment 0.0.9

* `att_from_rmd` adds a temporary encoding parameter as `knitr::purl` will only deal with UTF-8 in the future. Parameter not added in `att_from_rmds`.
* `att_to_description` if {covr} is needed, should be added in parameter `extra.suggests`
* `att_to_description` has a parameter 'dir.t' to extract suggests dependencies from test directory *Available by default*

# attachment 0.0.8

* `att_to_description` allows for 'LinkingTo' field in DESCRIPTION with a message
* `att_from_rmd` now reads yaml header
* `att_from_rmd` use `purl` to extract R code in an other R session using `system("Rscript -e ''")`
* `att_from_rmd`: add `warn` option to allow hide messages from `purl()`

# attachment 0.0.7

* `att_to_description` accept parameter `path` for package not being the current project
* `att_to_description` no error if NAMESPACE is empty
* `create_dependencies_file` filters base packages that cannot be installed

# attachment 0.0.6

* Prepare examples for CRAN

# attachment 0.0.5

* `att_to_description` deals with Remote dependencies
* `att_to_description` deals with Depends dependencies
* `att_to_description` keeps versions of packages previously added
* `att_to_description` removes option for automatic pkg version
* `create_dependencies_file` deals with github Remotes
* `att_from_rmds` now accept a vector of Rmd filenames

# attachment 0.0.4

* Add examples in functions

# attachment 0.0.3

* `att_to_description(add_version = TRUE)` adds version of package in DESCRIPTION
* `att_to_description(pkg_ignore)` adds possibility to ignore some packages

# attachment 0.0.3

* Get ready for CRAN
* Add tests.

# attachment 0.0.2

* New function `install_from_description` to install all missing packages listed in the description file
* Add an hex by @statnmap !
* Allow for absence of vignette folder in `att_to_description`
* Add `create_dependencies_file` to create a file listing all packages dependencies to dinstall before your package
* Allow for `pkg::fun` calls in R scripts with `att_from_functions`
* Add option to run `devtools::document()` before `att_from_description`

# attachment 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
