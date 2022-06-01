#' Verificar parâmetros disponíveis
#'
#' @param dir Pasta onde base de tags está armazenada.
#'
#' @return Um vetor de caracteres
#' @export
#'
#' @examples
#' tags_dir <- create_sqlite_tags()
#' check_tables(tags_dir)
check_tables <- function(dir) {
  db <- DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(dir))

  x <- DBI::dbListTables(db)

  DBI::dbDisconnect(db, shutdown = TRUE)

  return(x)
}

#' Verificar tags de consulta
#'
#' @param search_type Sites disponíveis: "uf" para "Beneficiários por UF" e "op" para "Beneficiários por Operadora".
#' @param table Tabela de parâmetros disponível em "webscrapANS::check_tables()"
#' @param dir Pasta onde base de tags está armazenada.
#'
#' @return Um tibble
#' @export
#'
#' @examples
#' tags_dir <- create_sqlite_tags()
#' check_requests("op", "linha", tags_dir)
check_requests <- function(search_type, table, dir) {
  site <- glue::glue("benef_{search_type}")

  db <- DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(dir))

  x <- DBI::dbReadTable(db, table) |>
    dplyr::filter(tipo == site) |>
    dplyr::select(item) |>
    dplyr::pull()

  DBI::dbDisconnect(db, shutdown = TRUE)

  return(x)
}
