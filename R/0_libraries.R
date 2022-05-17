# ----------------- #
# --- LIBRARIES --- #
# ----------------- #

if (!require("pacman")) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(
  rvest,
  httr,
  janitor,
  tidyverse,
  RSQLite,
  styler,
  lintr,
  miniUI,
  glue,
  devtools,
  roxygen2,
  testthat,
  knitr,
  rstudioapi,
  install = FALSE
)
