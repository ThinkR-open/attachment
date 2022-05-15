# This code contains knitr on a newline and should not be read with `\nknitr`

create_vignette_head <- function(pkg, vignette_name, yaml_options = NULL) {
  pkgname <- basename(pkg)

  # Get all yaml options except Title, output, editor_options
  yaml_options <- yaml_options[
    !names(yaml_options) %in% c("output", "title", "editor_options")]

  enc2utf8(
    glue(
      '---
title: ".{vignette_name}."
output: rmarkdown::html_vignette',
      ifelse(length(yaml_options) != 0,
             glue::glue_collapse(
               c("",
                 glue("{names(yaml_options)}: \"{yaml_options}\""), ""),
               sep = "\n"),
             "\n"),
      'vignette: >
  %\\VignetteIndexEntry{.{vignette_name}.}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup}
library(.{pkgname}.)
```
    ',
    .open = ".{", .close = "}."
    )
  )
}
