# bibliotecas e funções ---------------------------------------------------

source("R/libraries.R")
source("R/functions.R")

# construindo base de dados -----------------------------------------------

#' Tags encontradas no site do tabnet da ANS:
#' <http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_br.def>

# https://stackoverflow.com/questions/32833894/r-rvest-is-not-proper-utf-8-indicate-encoding

html <- rvest::read_html(iconv("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_br.def", to = "UTF-8"), encoding = "UTF-8")

# match de tags

html |>
  rvest::html_elements("#L") |>
  paste0() |>
  stringr::str_extract_all(regex('value=\"(.*?)\"')) |>
  purrr::map_df(as_tibble, "x") |>
  purrr::map_df(stringr::str_replace_all,
                regex('value=\\\"'), "") |>
  purrr::map_df(stringr::str_replace_all,
                regex('\\\"'), "")

linha <- html |>
  rvest::html_element("#L") |>
  clear() |>
  dplyr::mutate(tag = c("Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o%2FUF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana")) |>
  readr::write_csv(glue::glue("base/linha.csv"))

coluna <- html |>
  rvest::html_element("#C") |>
  clear() |>
  dplyr::mutate(tag = c("--N%E3o-Ativa--", "Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana")) |>
  readr::write_csv(glue::glue("base/coluna.csv"))

conteudo <- html |>
  rvest::html_element("#I") |>
  clear() |>
  dplyr::mutate(tag = c("Assist%EAncia_M%E9dica", "Excl._Odontol%F3gico")) |>
  readr::write_csv(glue::glue("base/conteudo.csv"))

tipo_contratacao <- html |>
  rvest::html_element("#S4") |>
  clear() |>
  dplyr::mutate(tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5")) |>
  readr::write_csv(glue::glue("base/tipo_contratacao.csv"))

uf <- html |>
  rvest::html_element("#S10") |>
  clear() |>
  dplyr::mutate(tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "29", "28")) |>
  readr::write_csv(glue::glue("base/uf.csv"))

# Importar planilhas na base SQLite "ans-tags.db"

# query -------------------------------------------------------------------
dbListTables(database) # Listando variáveis

dados <- busca(coluna = "Competencia",
               conteudo = "Assistencia Medica",
               linha = "Tipo de contratacao",
               tipo_contratacao = "Todas as categorias",
               uf = "Todas as categorias",
               ano = "12",
               mes = "06")

#' Próximos passos:
#'
#' - Consultas múltiplas por meio de listas
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados - feito
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
