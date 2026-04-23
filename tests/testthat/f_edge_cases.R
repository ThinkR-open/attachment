# Fixture for issues #120, #128, #129, #132
# Each line below tests one specific detection case.

# --- Must detect (true positives) ---
library(findedge0)
require(findedge1)
requireNamespace("findedge2")
loadNamespace("findedge3")
glue::glue("ok")
stringr:::str_trim("ok")

# --- Named `package=` arg ---
library(lib.loc = "/tmp", package = "findedge4")
require(package = "findedge5")
requireNamespace(lib.loc = "/tmp", "findedge6")
require(lib.loc = "/tmp", package = "findedge7")

# --- R 4.4 use() --- #128
use("findedge8")
use("findedge9", c("fn_a", "fn_b"))
use(package = "findedge10")

# --- getFromNamespace --- #129
getFromNamespace("fn_x", "findedge11")
getFromNamespace(x = "fn_x", ns = "findedge12")

# --- Must NOT detect (false positives) ---
# This comment with blabla::dontfind_a shouldn't trigger
x <- "following-sibling::dontfind_b"                       # #120 xpath-like
y <- "label::after"                                        # #132 CSS
z <- sprintf('%s::plot()', 'dontfind_c')                   # #129 '%s'
"library(dontfind_d)"                                      # string literal
"require(dontfind_e)"                                      # string literal
# library(dontfind_f)                                      # comment
