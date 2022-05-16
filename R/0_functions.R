# ----------------- #
# --- FUNCTIONS --- #
# ----------------- #

# importação na base sqlite -----------------------------------------------

write_db <- function(x, name, dir) {
  database <- DBI::dbConnect(
    RSQLite::SQLite(),
    glue::glue("{dir}/tags.db")
  )

  x <- x |>
    tidyr::unite("tag", c(x, tag, y), sep = "")

  if (!DBI::dbExistsTable(database, name)) {
    DBI::dbCreateTable(
      conn = database,
      name = name,
      fields = x,
      row.names = NULL
    )
  }

  x <- x |>
    dplyr::bind_rows(
      dplyr::tbl(database, glue::glue("{name}")) |>
        dplyr::collect()
    ) |>
    dplyr::group_by(tipo) |>
    dplyr::distinct(item, tag)

  DBI::dbWriteTable(
    conn = database,
    name = glue::glue("{name}"),
    value = x,
    overwrite = T
  )

  DBI::dbDisconnect(database)
}

# função que habilita suporte a múltiplas consultas -----------------------

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

# limpeza de tabelas ------------------------------------------------------

clear_html <- function(x) {
  x <- x |>
    rvest::html_text() |>
    stringi::stri_trans_general(id = "Latin-ASCII") |>
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n") |>
    dplyr::rename(item = value) |>
    dplyr::slice(-n())

  return(x)
}

# argumentos vazios -------------------------------------------------------

missing_args <- function(x) {
  if (is.na(x)) {
    return("Todas as categorias")
  }

  return(x)
}

# requisições do tabnet ---------------------------------------------------

tabnet_request <- function(coluna = "Nao ativa",
                           conteudo = "Assistencia Medica",
                           linha = "Competencia",
                           modalidade = NA,
                           regiao = NA,
                           tipo_contratacao = NA,
                           uf = NA,
                           sqlite = fs::dir_ls(tags_dir),
                           search_type = "uf",
                           years = 13:21,
                           months = 12) {
  site <- glue::glue("benef_{search_type}")

  db <- DBI::dbConnect(RSQLite::SQLite(), sqlite)

  if (site == "benef_op") {
    page <- "Arquivos=tb_cc_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_cc.def"

    request <- "{tags[3]}{tags[1]}{tags[2]}{period}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
  } else {
    page <- "Arquivos=tb_br_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

    request <- "{tags[3]}{tags[1]}{tags[2]}{period}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
  }

  tags <- tibble::tibble(
    names = c("coluna", "conteudo", "linha", "modalidade", "regiao", "tipo_contratacao", "uf"),
    vars = c(coluna, conteudo, linha, modalidade, regiao, tipo_contratacao, uf)
  ) |>
    dplyr::mutate(
      vars = purrr::map_chr(
        vars,
        ~ missing_args(.x)
      )
    ) |>
    dplyr::mutate(
      tags = purrr::map2_chr(
        .x = vars,
        .y = names,
        ~ multi_query(.x, .y, site, db)
      )
    ) |>
    dplyr::select(tags) |>
    purrr::flatten_chr()

  period <- purrr::map(months, ~ glue::glue("{page}{years}{.x}.dbf&")) |>
    purrr::flatten_chr() |>
    stringr::str_flatten()

  request <- glue::glue(request)

  tab_site <- httr::POST(
    url = tabnet_ans,
    body = request,
    httr::timeout(20)
  ) |>
    httr::content(encoding = "latin1", as = "parsed") |>
    rvest::html_node("table") |>
    rvest::html_text2() |>
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n")

  if (!is.na(tab_site[[1]][[1]])) {
    n <- tab_site |>
      dplyr::slice(1) |>
      dplyr::pull() |>
      stringr::str_count(pattern = "\t")

    tab_site <- tab_site |>
      tidyr::separate(
        col = value,
        sep = "\t",
        into = paste0(
          "x",
          seq_len(n + 1)
        )
      ) |>
      janitor::row_to_names(row_number = 1) |>
      purrr::map_df(stringr::str_replace_all, "\\.", "") |>
      janitor::clean_names()

    if ("operadora" %in% names(tab_site)) {
      tab_site <- tab_site |>
        dplyr::filter(operadora != "TOTAL") |>
        tidyr::separate(
          col = operadora,
          into = c("registro", "operadora"),
          sep = "-",
          extra = "merge"
        ) |>
        dplyr::mutate(registro = as.numeric(registro))
    }

    DBI::dbDisconnect(database)

    return(tab_site)
  } else {
    return(cat("Busca má especificada ou não suportada pelo tabnet."))
  }
}

# funções de consulta de tabelas ------------------------------------------

check_tables <- function(dir = tags_dir) {
  DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(tags_dir)) |>
    DBI::dbListTables()
}

check_requests <- function(site, table, dir = tags_dir) {
  site <- glue::glue("benef_{site}")

  db <- DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(tags_dir))

  DBI::dbReadTable(db, table) |>
    dplyr::filter(tipo == site) |>
    dplyr::select(item) |>
    dplyr::pull()
}
