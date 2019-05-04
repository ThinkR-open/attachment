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
* Add `create_dependencies_file` to create a file listing all packages dependencies to install before your package
* Allow for `pkg::fun` calls in R scripts with `att_from_functions`
* Add option to run `devtools::document()` before `att_from_description`

# attachment 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
