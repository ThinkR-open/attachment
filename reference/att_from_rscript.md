# Look for functions called with `::` and library/requires in one script

Look for functions called with `::` and library/requires in one script

## Usage

``` r
att_from_rscript(path, encoding = getOption("encoding"))
```

## Arguments

- path:

  path to R script file

- encoding:

  Encoding passed to
  [`readLines()`](https://rdrr.io/r/base/readLines.html) when reading
  `path`. Defaults to `getOption("encoding")` so the system locale is
  respected (important on Windows where scripts are often Latin-1 /
  Windows-1252).

## Value

a vector

## Details

Uses the R parser to walk the syntax tree so that occurrences of
`pkg::fun` or
`library()/require()/requireNamespace()/loadNamespace()/use()/getFromNamespace()`
inside string literals or comments are ignored. Named arguments such as
[`library(package = "pkg")`](https://rdrr.io/r/base/library.html) are
supported, as are fully-qualified forms like
[`base::library(pkg)`](https://rdrr.io/r/base/library.html) or
`methods::getFromNamespace(fn, "pkg")`. Introspection helpers such as
[`packageVersion()`](https://rdrr.io/r/utils/packageDescription.html),
[`getNamespace()`](https://rdrr.io/r/base/ns-reflect.html),
[`asNamespace()`](https://rdrr.io/r/base/ns-internal.html), and
[`attachNamespace()`](https://rdrr.io/r/base/ns-load.html) are **not**
treated as dependency introducers, because they are commonly used for
version or feature checks on packages that may or may not be required at
runtime.

If the file cannot be parsed as valid R (syntax error, corrupt encoding,
etc.), the function falls back to a regex-based detector and emits a
[`warning()`](https://rdrr.io/r/base/warning.html) naming the file so
users can investigate.

## Examples

``` r
dummypackage <- system.file("dummypackage",package = "attachment")
# browseURL(dummypackage)

att_from_rscript(path = file.path(dummypackage,"R","my_mean.R"))
#> [1] "stats"
```
