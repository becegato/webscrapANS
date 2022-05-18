# --------------------------- #
# --- AUXILIARY FUNCTIONS --- #
# --------------------------- #

utils::globalVariables(c("item", "operadora", "registro", "tag", "tipo", "value", "vars", "y"))

write_db <- function(x, name, dir) {
  db <- DBI::dbConnect(
    RSQLite::SQLite(),
    glue::glue("{dir}/tags.db")
  )

  x <- x |>
    tidyr::unite("tag", c(x, tag, y), sep = "")

  if (!DBI::dbExistsTable(db, name)) {
    DBI::dbCreateTable(
      conn = db,
      name = name,
      fields = x,
      row.names = NULL
    )
  }

  x <- x |>
    dplyr::bind_rows(
      dplyr::tbl(db, glue::glue("{name}")) |>
        dplyr::collect()
    ) |>
    dplyr::group_by(tipo) |>
    dplyr::distinct(item, tag)

  DBI::dbWriteTable(
    conn = db,
    name = glue::glue("{name}"),
    value = x,
    overwrite = T
  )

  DBI::dbDisconnect(db)
}

multi_query <- function(x, name, site, db) {
  x <- x |>
    dplyr::as_tibble() |>
    dplyr::rename(item = value) |>
    dplyr::left_join(
      db |>
        dplyr::tbl(paste0(name)) |>
        dplyr::collect() |>
        dplyr::filter(tipo == site),
      by = "item"
    ) |>
    dplyr::select(tag) |>
    purrr::flatten_chr() |>
    stringr::str_flatten()

  return(x)
}

clear_html <- function(x) {
  x <- x |>
    rvest::html_text() |>
    stringi::stri_trans_general(id = "Latin-ASCII") |>
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n") |>
    dplyr::rename(item = value) |>
    dplyr::slice(-dplyr::n())

  return(x)
}

missing_args <- function(x) {
  if (is.na(x)) {
    return("Todas as categorias")
  }

  return(x)
}
