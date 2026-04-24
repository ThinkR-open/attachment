# =====================================================================
# Manual detection edge-case harness for `attachment::att_from_rscript()`
# =====================================================================
#
# PURPOSE
#   This file is deliberately *not* a unit test. It is a very large, messy
#   R script that exercises every dependency-detection situation we could
#   think of — from mundane `library(pkg)` calls to pathological parser
#   edge cases — so a human reviewer can eyeball what the detector picks
#   up, and compare against the expected lists at the bottom of the file.
#
# HOW TO USE
#   devtools::load_all()
#   detected <- attachment::att_from_rscript("dev/manual_detection_edge_cases.R")
#   sort(detected)
#   # Then diff against EXPECTED_TRUE_POSITIVES / EXPECTED_FALSE_POSITIVES
#   # defined at the bottom of this file.
#
# NAMING CONVENTION
#   - Packages that SHOULD be detected use the prefix `findme_*`
#     (e.g. `findme_basic1`, `findme_named_arg`).
#   - Packages that must NEVER be detected use `ghost_*`.
#   - Real package names (glue, stringr, dplyr, …) are only used where a
#     real transitive behaviour is interesting (e.g. `base` filtering).
#
# This file must parse cleanly as R code — if it doesn't, the AST walker
# silently falls back to the legacy regex detector and the whole point of
# the harness is lost. If you add a case, run `parse(file = <thisfile>)`
# to confirm.
# =====================================================================


# ---------------------------------------------------------------------
# SECTION 1 — Canonical `pkg::fun` references
# ---------------------------------------------------------------------

findme_basic1::fun()                  # bare
findme_basic2::fun(1, 2, 3)           # with args
findme_basic3:::internal()            # triple colon (internal)
findme.dotted::fun()                  # dot in pkg name
findme.with.many.dots::fun()          # several dots
findme_basic1::another_fun()          # same pkg, different function — must dedup

f1 <- findme_bareref::fun             # reference-only, no call
fn <- findme_bareref_nocall::fun      # same, different pkg
findme_doublecall::factory()()        # call the returned function too

# Chained operators
x <- 1:10
x2 <- findme_pipe_mg::fn(x)
x3 <- x |> findme_pipe_native::fn()   # R 4.1+ native pipe
x4 <- x |> findme_pipe_named::fn(a = 1)

# Nested: outer pkg wraps inner pkg
findme_outer::fn(findme_inner::fn(findme_deepest::fn(1)))

# Passed as function value
purrr_like <- function(l, f) lapply(l, f)
purrr_like(1:3, findme_passedref::fn)
do.call(findme_docall::fn, list(1, 2))

# In anonymous fn / lambda
(\(x) findme_lambda::fn(x))(1)
(function(x) findme_classic_fn::fn(x))(1)

# Right-arrow assign
findme_rarrow::fn(1) -> result
findme_rarrow2::fn(1) ->> global_result

# Super-assign from pkg
super <- NULL
super <<- findme_supassign::fn(1)


# ---------------------------------------------------------------------
# SECTION 2 — library() / require() variants
# ---------------------------------------------------------------------

library(findme_lib_bare)
library("findme_lib_dquote")
library('findme_lib_squote')
library(`findme_lib_backtick`)

require(findme_req_bare)
require("findme_req_dquote")
requireNamespace("findme_reqns")
requireNamespace("findme_reqns_quietly", quietly = TRUE)

# Named `package =` argument in any position
library(package = "findme_named1")
library(warn.conflicts = FALSE, package = "findme_named2")
library(lib.loc = "/tmp", package = "findme_named3")
library(character.only = TRUE, package = "findme_named4")
require(package = "findme_namedreq1")
require(lib.loc = "/tmp", package = "findme_namedreq2")
requireNamespace("findme_reqns_positional", lib.loc = "/tmp")
requireNamespace(package = "findme_reqns_named", lib.loc = "/tmp")

# loadNamespace
loadNamespace("findme_loadns1")
loadNamespace("findme_loadns2", keep.source = FALSE)
loadNamespace(package = "findme_loadns_named")

# R >= 4.4 use()
use("findme_use1")
use("findme_use2", c("fn_a", "fn_b"))
use(package = "findme_use_named")

# getFromNamespace — package is the 2nd arg
getFromNamespace("fn", "findme_gfns_positional")
getFromNamespace("fn", ns = "findme_gfns_mixed")
getFromNamespace(x = "fn", ns = "findme_gfns_named_xns")
getFromNamespace(ns = "findme_gfns_named_nsx", x = "fn")


# ---------------------------------------------------------------------
# SECTION 3 — String literals that must NOT be detected
# ---------------------------------------------------------------------

xpath1  <- "following-sibling::ghost_xpath1"
xpath2  <- "preceding::ghost_xpath2"
css1    <- "label::after"
css2    <- "::first-line"
css3    <- "p::before { content: 'hello'; }"
cxx1    <- "std::vector<int>"
cxx2    <- "std::map<ghost_cxx2, int>"
rcpp_s  <- "Rcpp::List"
url1    <- "file:///home/user"
url2    <- "https://example.com/ghost_url2"
sprintf_pattern <- sprintf("%s::plot()", "ghost_sprintf")
message_pattern <- paste0("use ", "ghost_paste", "::", "fn")

lib_in_string  <- "library(ghost_libstr)"
req_in_string  <- "require(ghost_reqstr)"
use_in_string  <- "use(\"ghost_usestr\")"
long_literal   <- "this string mentions ghost_longlit::foo but it is just text"

multiline_str <- "first line
second ghost_multiline::fn line
third line"

# Raw strings (R 4.0+) — must behave exactly like strings
raw1 <- r"(ghost_raw1::fn)"
raw2 <- r"[ghost_raw2::fn]"
raw3 <- r"---(ghost_raw3::fn with (parens) inside)---"
raw4 <- r"(library(ghost_raw_lib))"

# Escaped characters
esc1 <- "ghost_esc1\\::fn"
esc2 <- "ghost_esc2::fn\""
esc3 <- "ghost_esc3\tlibrary(ghost_esc3b)"

# Strings assembled dynamically — must not resolve to a detected pkg
assembled <- paste0("ghost_", "assembled", "::", "fn")
collapsed <- paste("ghost", "collapsed", sep = "::")


# ---------------------------------------------------------------------
# SECTION 4 — Comments
# ---------------------------------------------------------------------

# ghost_comment1::fn()
# library(ghost_comment_lib)
# require(ghost_comment_req)
# requireNamespace("ghost_comment_reqns")
# TODO: switch to ghost_comment_todo::fn once it is ready

#' @importFrom ghost_roxygen fn
#' (roxygen blocks are not parsed by att_from_rscript; a separate
#'  att_from_namespace() extractor handles them)

x <- 1 # end-of-line comment mentioning ghost_eol::fn()

# A comment on the line immediately before a real call must not
# poison the detection of the call itself:
# ghost_precomment::fn()
findme_after_comment::fn()


# ---------------------------------------------------------------------
# SECTION 5 — Parser edge cases: empty/missing arguments
# ---------------------------------------------------------------------

# Matrix subscripts with empty positions
m  <- matrix(1:20, 4, 5)
r1 <- m[, 1]
r2 <- m[1, ]
r3 <- m[, ]
r4 <- m[, , drop = FALSE]               # 3-arg with empty middle

# Empty else
if (TRUE) findme_emptyelse::fn()        # implicit NULL else
if (TRUE) findme_ifonly::fn() else NULL

# switch() with fallthrough (empty alternatives)
s <- switch("a",
            a = ,                       # fall through to b
            b = findme_switch::fn(),
            stop("bad"))

# `if` as an expression, nested inside a call
x5 <- list(value = if (TRUE) findme_ifexpr::fn() else NA)

# Empty function bodies / trivial defaults / dots
noop      <- function() {}
dots_only <- function(...) list(...)
mixed_def <- function(x, tol = .Machine$double.eps^0.5, ...) x


# ---------------------------------------------------------------------
# SECTION 6 — Control flow with real calls inside
# ---------------------------------------------------------------------

if (interactive()) {
  findme_ctrl_if::fn()
} else {
  findme_ctrl_else::fn()
}

for (p in c("a", "b", "c")) {
  findme_ctrl_for::fn(p)
}

while (FALSE) {
  findme_ctrl_while::fn()
}

repeat {
  findme_ctrl_repeat::fn()
  break
}

# Nested
if (TRUE) {
  if (TRUE) {
    if (TRUE) {
      findme_ctrl_nested::fn()
    }
  }
}

# tryCatch / withCallingHandlers
tryCatch(
  findme_try_expr::fn(),
  warning = function(w) findme_try_warn::fn(),
  error   = function(e) findme_try_err::fn(),
  finally = findme_try_finally::fn()
)
withCallingHandlers(
  findme_wch_expr::fn(),
  message = function(m) findme_wch_msg::fn()
)

# Conditional-install idiom
if (requireNamespace("findme_condreq", quietly = TRUE)) {
  findme_condreq::sub()
}


# ---------------------------------------------------------------------
# SECTION 7 — Function bodies, closures, and recursion
# ---------------------------------------------------------------------

wrapper <- function(x) {
  y <- findme_closure::fn(x)
  inner <- function(z) findme_closure_inner::fn(z)
  inner(y)
}

factory <- function() {
  function(x) findme_factory::fn(x)
}

self_ref <- function(n) {
  if (n <= 0) return(0)
  findme_selfref::fn(n) + self_ref(n - 1)
}


# ---------------------------------------------------------------------
# SECTION 8 — Formulas
# ---------------------------------------------------------------------

frm1 <- y ~ x
frm2 <- y ~ findme_formula::fn(x)
frm3 <- ~ findme_formula_rhs::fn(z)
fit  <- function(data) stats::lm(frm2, data = data)


# ---------------------------------------------------------------------
# SECTION 9 — S4 / R6 / methods
# ---------------------------------------------------------------------

methods::setClass("Foo", representation(x = "numeric"))
methods::setGeneric("bar", function(obj) standardGeneric("bar"))
methods::setMethod("bar", "Foo", function(obj) findme_s4::fn(obj@x))

R6::R6Class("MyClass",
            public = list(
              initialize = function() findme_r6_init::fn(),
              do_it      = function() findme_r6_method::fn()
            ))


# ---------------------------------------------------------------------
# SECTION 10 — quote() / bquote() / substitute() / expression()
# ---------------------------------------------------------------------
# KNOWN LIMITATION: the AST walker cannot tell these apart from regular
# code, so every pkg::fn inside them IS currently detected. We list them
# under EXPECTED_TRUE_POSITIVES to document the behaviour honestly.

q1 <- quote(findme_quote::fn())
q2 <- bquote(findme_bquote::fn(.(x)))
q3 <- substitute(findme_substitute::fn(x), list(x = 1))
q4 <- expression(findme_expression::fn())
q5 <- quote({
  library(findme_quote_lib)
  findme_quote_body::fn()
})


# ---------------------------------------------------------------------
# SECTION 11 — Dynamic calls
# ---------------------------------------------------------------------
# Two different shapes to distinguish:
#
#   (a) `library(symbol, character.only = TRUE)` — the walker returns
#       the *symbol* in the `package` position and only that symbol.
#       Other named args (`character.only`, `quiet`, `lib.loc`, …) are
#       correctly ignored, thanks to `match_call_arg()` excluding named
#       args before picking the 1st positional. Same is true for
#       `library(character.only = TRUE, pkg)` (position resolved after
#       stripping named args).
#
#   (b) `do.call("library", list("pkg"))` / `eval(parse(text = "..."))`:
#       the real package name lives inside a string that static analysis
#       cannot reach. Nothing is detected — this is the correct outcome.

pkgname <- "ghost_dynamic_charonly"
library(pkgname, character.only = TRUE)              # (a) detects `pkgname`, not "ghost_*"
library(pkgname2, quiet = TRUE, character.only = TRUE)  # (a) detects `pkgname2`
library(character.only = TRUE, pkgname3)             # (a) detects `pkgname3` — named args skipped

lib_names <- c("ghost_dynamic1", "ghost_dynamic2")
for (nm in lib_names) library(nm, character.only = TRUE)  # (a) detects `nm`

do.call("library",          list("ghost_docall_lib"))
do.call("require",          list("ghost_docall_req"))
do.call("requireNamespace", list("ghost_docall_reqns"))
do.call("use",              list("ghost_docall_use"))

eval(parse(text = "library(ghost_eval_parse)"))

# A user who shadows `library` locally should not see us pick up their
# pretend-package. (We currently *will* detect it, because the AST walker
# has no scope analysis. Documented under the known-limitation list.)
shadowed_library <- function(pkg) invisible(pkg)
# shadowed_library("ghost_shadowed_user") — user call, not detected


# ---------------------------------------------------------------------
# SECTION 12 — Introspection helpers that must NOT introduce deps
# ---------------------------------------------------------------------
# These were part of the PR's first draft but were deliberately removed
# from pkg_intro_calls — they are commonly used for feature-detection.

if (packageVersion("ghost_intro_pv")        >= "1.0") NULL
ns_ref <- getNamespace("ghost_intro_gns")
ns2    <- asNamespace("ghost_intro_ans")
attachNamespace("ghost_intro_attns")


# ---------------------------------------------------------------------
# SECTION 13 — `base` filtering
# ---------------------------------------------------------------------
# `base::` should NEVER appear in the result — att_from_rscript filters
# it explicitly. Same for `:::` internals of base.

base::length(1:3)
base::print("hello")
base:::.Internal(1)


# ---------------------------------------------------------------------
# SECTION 14 — Numeric / reserved / weird but valid R
# ---------------------------------------------------------------------

n1 <- 1e10
n2 <- 0x1F
n3 <- 1L
n4 <- 1.5e-3
n5 <- .Machine$integer.max
b  <- c(TRUE, FALSE, NA, NaN, Inf, -Inf)
L  <- list(NULL, NA_integer_, NA_character_)

# Custom infix
`%between%` <- function(x, rng) x >= rng[1] & x <= rng[2]
stopifnot(5 %between% c(1, 10))

# Pipe placeholder and anonymous fn chain
out <- mtcars |>
  (\(d) d[d$mpg > 20, ])() |>
  findme_pipe_chain::fn()


# ---------------------------------------------------------------------
# SECTION 15 — tidyeval / quasiquotation expressions
# ---------------------------------------------------------------------

tidy_example <- function(df, col) {
  findme_tidy::fn(df, {{ col }})
}

tidy_bangbang <- function(df, syms) {
  findme_tidy_bb::fn(df, !!!syms)
}


# ---------------------------------------------------------------------
# SECTION 16 — Massively nested / wide expressions (parser stress)
# ---------------------------------------------------------------------

deep <- findme_deep1::a(
  findme_deep2::b(
    findme_deep3::c(
      findme_deep4::d(
        findme_deep5::e(
          findme_deep6::f(
            findme_deep7::g(
              findme_deep8::h(
                findme_deep9::i(
                  findme_deep10::j(1)
                )
              )
            )
          )
        )
      )
    )
  )
)

wide <- list(
  findme_wide01::a(), findme_wide02::a(), findme_wide03::a(),
  findme_wide04::a(), findme_wide05::a(), findme_wide06::a(),
  findme_wide07::a(), findme_wide08::a(), findme_wide09::a(),
  findme_wide10::a()
)


# ---------------------------------------------------------------------
# SECTION 17 — Multi-statement lines, semicolons, weird spacing
# ---------------------------------------------------------------------

library(findme_semi1); library(findme_semi2); findme_semi3::fn()

findme_spacey  ::  fn(1)         # whitespace around ::
findme_newline_call::fn(
  1,
  2,
  3
)

library(
  findme_multiline_lib
)


# ---------------------------------------------------------------------
# SECTION 18 — eval(quote(...)) WILL be detected (AST recurses)
# ---------------------------------------------------------------------
# Documented under EXPECTED_TRUE_POSITIVES as a consequence of the walker
# having no concept of lazy evaluation.

eval(quote(findme_eval_quote::fn()))
eval(quote(library(findme_eval_quote_lib)))


# ---------------------------------------------------------------------
# SECTION 19 — Fully-qualified dependency-introducing calls
# ---------------------------------------------------------------------
# `base::library(pkg)` and siblings must detect the inner package.
# The outer `base`/`methods` is also recorded but filtered out for
# `base` (always excluded). `methods` is a real transitive dep.

base::library(findme_qual_lib)
base::require(findme_qual_req)
base::requireNamespace("findme_qual_reqns")
base::loadNamespace("findme_qual_ldns")
methods::getFromNamespace("fn", "findme_qual_gfns")

# Other namespaces qualifying the same intro calls — the outer pkg is
# detected too (via ::), so both must appear in the result.
foreign_wrapper::library(findme_qual_wrapped)


# =====================================================================
# EXPECTED RESULTS — keep this in sync when adding cases above.
# =====================================================================
# EXPECTED_TRUE_POSITIVES <- sort(c(
#   # Section 1 — pkg::fn references
#   "findme_basic1", "findme_basic2", "findme_basic3",
#   "findme.dotted", "findme.with.many.dots",
#   "findme_bareref", "findme_bareref_nocall", "findme_doublecall",
#   "findme_pipe_mg", "findme_pipe_native", "findme_pipe_named",
#   "findme_outer", "findme_inner", "findme_deepest",
#   "findme_passedref", "findme_docall",
#   "findme_lambda", "findme_classic_fn",
#   "findme_rarrow", "findme_rarrow2", "findme_supassign",
#
#   # Section 2 — library/require variants
#   "findme_lib_bare", "findme_lib_dquote", "findme_lib_squote", "findme_lib_backtick",
#   "findme_req_bare", "findme_req_dquote",
#   "findme_reqns", "findme_reqns_quietly",
#   "findme_named1", "findme_named2", "findme_named3", "findme_named4",
#   "findme_namedreq1", "findme_namedreq2",
#   "findme_reqns_positional", "findme_reqns_named",
#   "findme_loadns1", "findme_loadns2", "findme_loadns_named",
#   "findme_use1", "findme_use2", "findme_use_named",
#   "findme_gfns_positional", "findme_gfns_mixed",
#   "findme_gfns_named_xns", "findme_gfns_named_nsx",
#
#   # Section 4 — real call after a comment mentioning a ghost
#   "findme_after_comment",
#
#   # Section 5/6/7 — empty-arg / control-flow / closures
#   "findme_emptyelse", "findme_ifonly", "findme_switch", "findme_ifexpr",
#   "findme_ctrl_if", "findme_ctrl_else", "findme_ctrl_for",
#   "findme_ctrl_while", "findme_ctrl_repeat", "findme_ctrl_nested",
#   "findme_try_expr", "findme_try_warn", "findme_try_err", "findme_try_finally",
#   "findme_wch_expr", "findme_wch_msg",
#   "findme_condreq",
#   "findme_closure", "findme_closure_inner", "findme_factory", "findme_selfref",
#
#   # Section 8 — formulas
#   "findme_formula", "findme_formula_rhs",
#
#   # Section 9 — S4 / R6
#   "findme_s4", "findme_r6_init", "findme_r6_method",
#
#   # Section 10 — quote/bquote/substitute/expression (known limitation)
#   "findme_quote", "findme_bquote", "findme_substitute", "findme_expression",
#   "findme_quote_lib", "findme_quote_body",
#
#   # Section 14 — pipe chain
#   "findme_pipe_chain",
#
#   # Section 15 — tidyeval
#   "findme_tidy", "findme_tidy_bb",
#
#   # Section 16 — deep / wide
#   "findme_deep1","findme_deep2","findme_deep3","findme_deep4","findme_deep5",
#   "findme_deep6","findme_deep7","findme_deep8","findme_deep9","findme_deep10",
#   "findme_wide01","findme_wide02","findme_wide03","findme_wide04","findme_wide05",
#   "findme_wide06","findme_wide07","findme_wide08","findme_wide09","findme_wide10",
#
#   # Section 17 — semicolons / whitespace / multi-line
#   "findme_semi1", "findme_semi2", "findme_semi3",
#   "findme_spacey", "findme_newline_call", "findme_multiline_lib",
#
#   # Section 18 — eval(quote(...)) (known limitation)
#   "findme_eval_quote", "findme_eval_quote_lib",
#
#   # Section 19 — fully-qualified intro calls
#   "findme_qual_lib", "findme_qual_req", "findme_qual_reqns",
#   "findme_qual_ldns", "findme_qual_gfns", "findme_qual_wrapped",
#   "foreign_wrapper",
#
#   # Real packages genuinely used via pkg::
#   "methods", "R6", "stats",
#
#   # Section 11 — `library(symbol, character.only=TRUE)` records the
#   # symbol exactly (named args like character.only/quiet are *not*
#   # picked up, only the positional `package` symbol is).
#   "pkgname", "pkgname2", "pkgname3", "nm"
# ))
#
# EXPECTED_FALSE_POSITIVES <- sort(c(
#   # Section 3 — string literals
#   "ghost_xpath1", "ghost_xpath2", "sibling", "preceding",
#   "label", "after", "first-line", "before",
#   "std", "ghost_cxx2", "Rcpp",
#   "file", "https",
#   "ghost_sprintf", "s", "ghost_paste",
#   "ghost_libstr", "ghost_reqstr", "ghost_usestr", "ghost_longlit", "ghost_multiline",
#   "ghost_raw1", "ghost_raw2", "ghost_raw3", "ghost_raw_lib",
#   "ghost_esc1", "ghost_esc2", "ghost_esc3", "ghost_esc3b",
#   "ghost_assembled", "ghost_collapsed",
#
#   # Section 4 — comments
#   "ghost_comment1", "ghost_comment_lib", "ghost_comment_req",
#   "ghost_comment_reqns", "ghost_comment_todo", "ghost_eol", "ghost_precomment",
#
#   # Section 11 — dynamic calls (strings hidden from static analysis)
#   "ghost_dynamic_charonly", "ghost_dynamic1", "ghost_dynamic2",
#   "ghost_docall_lib", "ghost_docall_req", "ghost_docall_reqns", "ghost_docall_use",
#   "ghost_eval_parse",
#
#   # Section 12 — introspection helpers that must not count
#   "ghost_intro_pv", "ghost_intro_gns", "ghost_intro_ans", "ghost_intro_attns",
#
#   # Section 13 — base always filtered
#   "base"
# ))
# =====================================================================
