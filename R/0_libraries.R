# ------------------- #
# --- BIBLIOTECAS --- #
# ------------------- #

if (!require("pacman")) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(
  rvest,
  httr,
  usethis,
  janitor,
  tidyverse,
  RSQLite,
  styler,
  lintr,
  miniUI,
  install = FALSE
)
