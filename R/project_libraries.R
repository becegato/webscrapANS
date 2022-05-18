if (!require("pacman")) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(
  lintr,
  styler,
  devtools,
  usethis,
  testthat,
  rmarkdown,
  knitr,
  miniUI
)
