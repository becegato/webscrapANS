# importação na base ------------------------------------------------------

writedb <- function(x, name) {

  # criando base sqlite

  if(fs::dir_exists("base/") == F){

    fs::dir_create("base/")

  }

  # criação/conexão com base sqlite

  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # "base/ans-tags.db"

  # junta variáveis auxiliares para criar tags da requisição
  x <- x |>
    tidyr::unite("tag", c(x, tag, y), sep = "")

  # cria tabela caso ela não exista na base
  if(DBI::dbExistsTable(database, name) == F){

    DBI::dbCreateTable(conn = database,
                       name = name,
                       fields = x,
                       row.names = NULL)

  }

  # adiciona novas tags e verifica tags duplicadas
  x <- x |>
      dplyr::bind_rows(
      dplyr::tbl(database, glue::glue("{name}")) |>
        dplyr::collect()
    ) |>
    dplyr::group_by(tipo) |>
    dplyr::distinct(item, tag)

  # escreve na base
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

  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de dados "~/ans-tags.db"

  x <- x |>
    dplyr::as_tibble() |>
    dplyr::rename(item = value) |>
    dplyr::left_join(
      database |>
        dplyr::tbl(paste0(name)) |>
        dplyr::collect() |>
        dplyr::filter(tipo == site),
    by = "item"
    ) |> # filtrando tags necessárias para a requisição por página solicitada
    dplyr::select(tag) |>
    purrr::flatten_chr() |>
    stringr::str_flatten() # criando string da consulta

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

missing_args <- function (x){

  if(is.na(x)){
    return("Todas as categorias")
  }

  return(x)

}

# requisições do tabnet ---------------------------------------------------

busca <- function(coluna = "Nao ativa", # valor padrão para as linhas
                  conteudo = "Assistencia Medica",
                  linha = "Competencia",
                  modalidade = NA,
                  regiao = NA,
                  tipo_contratacao = NA,
                  uf = NA,
                  site, ano, mes) {

  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de dados

  vars <- c(modalidade, regiao, tipo_contratacao, uf) |>
    purrr::map_chr(
    ~ {.x <- missing_args(.x); .x}
  )

  a <- coluna |>
    query("coluna", site)

  b <- conteudo |>
    query("conteudo", site)

  c <- linha |>
    query("linha", site)

  d <- vars[3] |>
    query("tipo_contratacao", site)

  e <- vars[4] |>
    query("uf", site)

  g <- vars[2] |>
    query("regiao", site)

  h <- vars[1] |>
    query("modalidade", site)

  if(site == "benef_op"){

    f <- ano |>
      dplyr::as_tibble() |>
      dplyr::mutate(
        x = "Arquivos=tb_cc_",
        y = ".dbf&",
        z = mes,
        value = as.character(value)
      ) |>
      tidyr::unite("periodo", c(x, value, z, y), sep = "") |>
      purrr::flatten_chr() |>
      stringr::str_flatten()

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_cc.def"

    requisicao <- glue::glue("{c}{a}{b}{f}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{h}{d}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{g}{e}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra")

  } else{

    f <- ano |>
      dplyr::as_tibble() |>
      dplyr::mutate(
        x = "Arquivos=tb_br_",
        y = ".dbf&",
        z = mes,
        value = as.character(value)
      ) |>
      tidyr::unite("periodo", c(x, value, z, y), sep = "") |>
      purrr::flatten_chr() |>
      stringr::str_flatten()

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

    requisicao <- glue::glue("{c}{a}{b}{f}SSexo=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria-Reajuste=TODAS_AS_CATEGORIAS__&{d}S%C9poca_de_contrata%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o_grupo=TODAS_AS_CATEGORIAS__&SAbrg._Geogr%E1fica=TODAS_AS_CATEGORIAS__&SModalidade=TODAS_AS_CATEGORIAS__&{e}{g}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg._Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra")

  }

  # escolha do ano de consulta

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

  DBI::dbDisconnect(database)

  return(tab_site)
}
