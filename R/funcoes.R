# limpeza de tabelas ------------------------------------------------------

#' Essa função serve para limpar os dados antes de importar para a base de dados do SQLite. Necessita incluir função de inclusão automática de tags.

clear <- function(x){
  x |>
    rvest::html_text() |>
    stringi::stri_trans_general(id = "Latin-ASCII") |> # Remover acentos na exportação
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n") |> # Padrão para separar as linhas
    dplyr::rename(item = value) |>
    dplyr::mutate(tag = "") |> # Criando coluna para inclusão de tags
    dplyr::slice(-n()) # Remover última linha por conta do último \n nas variáveis
}

# requisição --------------------------------------------------------------

#' Essa função serve para fazer as requisições para o tabnet

busca <- function(coluna, conteudo, linha, tipo_contratacao, uf, ano, mes){

  database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de dados "~/ans-tags.db"

  # As variáveis de "a" a "e" servem como auxiliares para puxar os valores selecionados para consultas.

  a <- database |>
    dplyr::tbl("coluna") |>
    dplyr::filter(item == coluna) |>
    dplyr::pull(tag)

  b <- database |>
    dplyr::tbl("conteudo") |>
    dplyr::filter(item == conteudo) |>
    dplyr::pull(tag)

  c <- database |>
    dplyr::tbl("linha") |>
    dplyr::filter(item == linha) |>
    dplyr::pull(tag)

  d <- database |>
    dplyr::tbl("tipo_contratacao") |>
    dplyr::filter(item == tipo_contratacao) |>
    dplyr::pull(tag)

  e <- database |>
    dplyr::tbl("uf") |>
    dplyr::filter(item == uf) |>
    dplyr::pull(tag)

  # URL do tabnet

  tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

  # Escolha do ano de consulta.

  periodo <- glue::glue("tb_br_{ano}{mes}.dbf")

  requisicao <- glue::glue("Linha={c}&Coluna={a}&Incremento={b}&Arquivos={periodo}&SSexo=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria=TODAS_AS_CATEGORIAS__&SFaixa_et%E1ria-Reajuste=TODAS_AS_CATEGORIAS__&STipo_de_contrata%E7%E3o={d}&S%C9poca_de_contrata%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o=TODAS_AS_CATEGORIAS__&SSegmenta%E7%E3o_grupo=TODAS_AS_CATEGORIAS__&SAbrg._Geogr%E1fica=TODAS_AS_CATEGORIAS__&SModalidade=TODAS_AS_CATEGORIAS__&SUF={e}&SGrande_Regi%E3o=TODAS_AS_CATEGORIAS__&SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg._Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra")

  site <- httr::POST(url = tabnet_ans,
                     body = requisicao,
                     timeout(20))

  dados <- httr::content(site, encoding = "latin1", as = "parsed") |> # extrair os dados da requisição
    rvest::html_node("table") |>
    rvest::html_text2() |> # extração do texto da página gerada pela requisição
    tibble::as_tibble() |>
    tidyr::separate_rows(value, sep = "\n")

  n <- 1 + dados |>
    dplyr::slice(1) |>
    dplyr::pull() |>
    stringr::str_count(pattern = "\t")

  dados <- dados |>
    tidyr::separate(col = value, sep = "\t", into = paste0("x", 1:n)) |>
    janitor::row_to_names(row_number = 1) |>
    dplyr::slice(-1)

  return(dados)
}
