# attachment 0.0.7

* `att_to_description` accept parameter `path` for package not being the current project
* `att_to_description` no error if NAMESPACE is empty

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
* Add `create_dependencies_file` to create a file listing all packages dependencies to install before your package
* Allow for `pkg::fun` calls in R scripts with `att_from_functions`
* Add option to run `devtools::document()` before `att_from_description`

# attachment 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
