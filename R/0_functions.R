# --------------- #
# --- FUNÇÕES --- #
# --------------- #

# importação na base sqlite -----------------------------------------------

writedb <- function(x, name) {
  database <- DBI::dbConnect(
    RSQLite::SQLite(),
    "tags/ans-tags.db"
  )

  x <- x |>
    tidyr::unite("tag", c(x, tag, y), sep = "")

  if (DBI::dbExistsTable(database, name) == F) {
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

  RSQLite::dbWriteTable(
    conn = database,
    name = glue::glue("{name}"),
    value = x,
    overwrite = T
  )

  DBI::dbDisconnect(database)
}

# função com suporte a múltiplas consultas --------------------------------

query <- function(x, name, site) {
  database <- DBI::dbConnect(RSQLite::SQLite(), "tags/ans-tags.db")

  x <- x |>
    dplyr::as_tibble() |>
    dplyr::rename(item = value) |>
    dplyr::left_join(
      database |>
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

clear <- function(x) {
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

busca <- function(coluna = "Nao ativa",
                  conteudo = "Assistencia Medica",
                  linha = "Competencia",
                  modalidade = NA,
                  regiao = NA,
                  tipo_contratacao = NA,
                  uf = NA,
                  site, ano, mes) {
  database <- DBI::dbConnect(RSQLite::SQLite(), "tags/ans-tags.db")

  if (site == "benef_op") {
    pagina <- "Arquivos=tb_cc_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_cc.def"

    requisicao <- "{tags[3]}{tags[1]}{tags[2]}{tags[8]}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
  } else {
    pagina <- "Arquivos=tb_br_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

    requisicao <- "{tags[3]}{tags[1]}{tags[2]}{tags[8]}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
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
        ~ query(.x, .y, site)
      )
    ) |>
    dplyr::bind_rows(
      tibble::tibble(
        names = "periodo",
        vars = NA,
        tags = ano |>
          dplyr::as_tibble() |>
          dplyr::mutate(
            x = pagina,
            y = ".dbf&",
            z = mes,
            value = as.character(value)
          ) |>
          tidyr::unite("periodo", c(x, value, z, y), sep = "") |>
          purrr::flatten_chr() |>
          stringr::str_flatten()
      )
    ) |>
    dplyr::select(tags) |>
    purrr::flatten_chr()

  requisicao <- glue::glue(requisicao)

  tab_site <- httr::POST(
    url = tabnet_ans,
    body = requisicao,
    timeout(20)
  ) |>
    httr::content(encoding = "latin1", as = "parsed") |>
    rvest::html_node("table") |>
    rvest::html_text2() |>
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n")

  n <- 1 + tab_site |>
    dplyr::slice(1) |>
    dplyr::pull() |>
    stringr::str_count(pattern = "\t")

  tab_site <- tab_site |>
    tidyr::separate(
      col = value,
      sep = "\t",
      into = paste0(
        "x",
        1:n
      )
    ) |>
    janitor::row_to_names(row_number = 1) |>
    purrr::map_df(stringr::str_replace_all, "\\.", "")

  DBI::dbDisconnect(database)

  return(tab_site)
}
