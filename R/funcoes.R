# importação na base ------------------------------------------------------

writedb <- function(x, name) {
  x <- x |> tidyr::unite("tag", c(x, tag, y), sep = "")

  RSQLite::dbWriteTable(
    conn = database,
    name = glue::glue("{name}"),
    value = x,
    overwrite = T
  )
}

# função com suporte a múltiplas consultas --------------------------------

query <- function(x, name) {
  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de dados "~/ans-tags.db"

  x <- x |>
    dplyr::as_tibble() |>
    dplyr::rename(item = value) |>
    dplyr::left_join(database |>
      dplyr::tbl(paste0(name)) |>
      dplyr::collect(),
    by = "item"
    ) |>
    dplyr::select(tag) |>
    purrr::flatten_chr() |>
    stringr::str_flatten()

  return(x)
}

# limpeza de tabelas ------------------------------------------------------

#' Essa função serve para limpar os dados antes de importar para a base de dados do SQLite.

clear <- function(x) {
  x |>
    rvest::html_text() |>
    stringi::stri_trans_general(id = "Latin-ASCII") |> # Remover acentos na exportação
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n") |> # Padrão para separar as linhas
    dplyr::rename(item = value) |>
    dplyr::mutate(tag = "") |> # Criando coluna para inclusão de tags
    dplyr::slice(-n()) # Remover última linha por conta do último \n nas variáveis
}

# argumentos vazios -------------------------------------------------------

#' checa se argumento foi passado para função
#' caso contrário, adiciona valor padrão

missing_arg <- function (x){

  if(is.na(x)){
    return("TODAS_AS_CATEGORIAS__")
  }

  return(x)

}


# requisições do tabnet ---------------------------------------------------

busca <- function(coluna = NA,
                  conteudo = NA,
                  linha = NA,
                  tipo_contratacao = NA,
                  uf = NA,
                  ano = NA,
                  mes = NA) {

  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de dados

  vars <- c(coluna, conteudo, linha, tipo_contratacao, uf, ano, mes) |>
    purrr::map_chr(
    ~ {.x <- missing_arg(.x); .x}
  )

  a <- vars[1] |>
    query("coluna")

  b <- vars[2] |>
    query("conteudo")

  c <- vars[3] |>
    query("linha")

  d <- vars[4] |>
    query("tipo_contratacao")

  e <- vars[5] |>
    query("uf")

  f <- vars[6] |>
    dplyr::as_tibble() |>
    dplyr::mutate(
      x = "Arquivos=tb_br_",
      y = ".dbf&",
      z = vars[7],
      value = as.character(value)
    ) |>
    tidyr::unite("periodo", c(x, value, z, y), sep = "") |>
    purrr::flatten_chr() |>
    stringr::str_flatten()

  # URL do tabnet

  tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

  # Escolha do ano de consulta.

  requisicao <- glue::glue("{c}{a}{b}{f}SSexo=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria-Reajuste=TODAS_AS_CATEGORIAS__&{d}S%C9poca_de_contrata%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o_grupo=TODAS_AS_CATEGORIAS__&SAbrg._Geogr%E1fica=TODAS_AS_CATEGORIAS__&SModalidade=TODAS_AS_CATEGORIAS__&{e}SGrande_Regi%E3o=TODAS_AS_CATEGORIAS__&SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg._Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra")

  tab_site <- httr::POST(
    url = tabnet_ans,
    body = requisicao,
    timeout(20)
  ) |>
    httr::content(encoding = "latin1", as = "parsed") |> # extrair os dados da requisição
    rvest::html_node("table") |>
    rvest::html_text2() |> # extração do texto da página gerada pela requisição
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n")

  n <- 1 + tab_site |>
    dplyr::slice(1) |>
    dplyr::pull() |>
    stringr::str_count(pattern = "\t")

  tab_site <- tab_site |>
    tidyr::separate(col = value, sep = "\t", into = paste0("x", 1:n)) |>
    janitor::row_to_names(row_number = 1) |>
    purrr::map_df(stringr::str_replace_all, "\\.", "") # remover pontos das observações

  return(tab_site)
}
