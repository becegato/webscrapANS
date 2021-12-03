#### criação de base para página de beneficiários do tabnet ####

# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# teste de inclusão automática de strings ---------------------------------

#' Tags encontradas no site do tabnet da ANS:
#' <http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_br.def>
#' <https://stackoverflow.com/questions/32833894/r-rvest-is-not-proper-utf-8-indicate-encoding>

# match de tags

# html |>
#   rvest::html_elements("#L") |>
#   paste0() |>
#   stringr::str_extract_all(regex('value=\"(.*?)\"')) |>
#   purrr::map_df(as_tibble, "x") |>
#   purrr::map_df(
#     stringr::str_replace_all,
#     regex('value=\\\"'), ""
#   ) |>
#   purrr::map_df(
#     stringr::str_replace_all,
#     regex('\\\"'), ""
#   )


# base de dados - beneficiários por uf ------------------------------------

# url do site

html <- rvest::read_html("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_br.def")

# linha

html |>
  rvest::html_element("#L") |>
  clear() |>
  dplyr::mutate(
    x = "Linha=",
    tag = c("Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o%2FUF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana"),
    y = "&",
    tipo = "benef_uf") |>
  writedb("linha")

# coluna

html |>
  rvest::html_element("#C") |>
  clear() |>
  dplyr::mutate(
    x = "Coluna=",
    tag = c("--N%E3o-Ativa--", "Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("coluna")

# conteudo

html |>
  rvest::html_element("#I") |>
  clear() |>
  dplyr::mutate(
    x = "Incremento=",
    tag = c("Assist%EAncia_M%E9dica", "Excl._Odontol%F3gico"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("conteudo")

# modalidade

html |>
  rvest::html_element("#S9") |>
  clear() |>
  dplyr::mutate(
    x = "SModalidade=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("modalidade")

# tipo_contratacao

html |>
  rvest::html_element("#S4") |>
  clear() |>
  dplyr::mutate(
    x = "STipo_de_contrata%E7%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("tipo_contratacao")

# uf

html |>
  rvest::html_element("#S10") |>
  clear() |>
  dplyr::mutate(
    x = "SUF=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "29", "28"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("uf")

# regiao

html |>
  rvest::html_element("#S11") |>
  clear() |>
  dplyr::mutate(
    x = "SGrande_Regi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7"),
    y = "&",
    tipo = "benef_uf"
  ) |>
  writedb("regiao")

# base de dados - beneficiários por operadora -----------------------------

# url do site

html <- rvest::read_html("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_cc.def")

# linha

html |>
  rvest::html_element("#L") |>
  clear() |>
  dplyr::mutate(
    x = "Linha=",
    tag = c("Compet%EAncia", "Operadora", "Modalidade", "Tipo_de_contrata%E7%E3o", "Faixa_de_Benef", "Regi%E3o", "UF_", "Capital", "Reg.Metropolitana"),
    y = "&",
    tipo = "benef_op") |>
  writedb("linha")

# coluna

html |>
  rvest::html_element("#C") |>
  clear() |>
  dplyr::mutate(
    x = "Coluna=",
    tag = c("--N%E3o-Ativa--", "Compet%EAncia", "Modalidade", "Tipo_de_contrata%E7%E3o", "Faixa_de_Benef", "Regi%E3o", "UF", "Capital", "Interior", "RM"),
    y = "&",
    tipo = "benef_op") |>
  writedb("coluna")

# conteúdo

html |>
  rvest::html_element("#I") |>
  clear() |>
  dplyr::mutate(
    x = "Incremento=",
    tag = c("Benef._Asst._M%E9dica", "Benef._Excl._Odont."),
    y = "&",
    tipo = "benef_op"
  ) |>
  dplyr::mutate(item = dplyr::case_when(
    item == "Benef. Asst. Medica" ~ "Assistencia Medica",
    item == "Benef. Excl. Odont." ~ "Excl. Odontologico"
  )) |>
  writedb("conteudo")

# modalidade

html |>
  rvest::html_element("#S2") |>
  clear() |>
  dplyr::mutate(
    x = "SModalidade=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9"),
    y = "&",
    tipo = "benef_op"
  ) |>
  writedb("modalidade")

# tipo_contratacao

html |>
  rvest::html_element("#S3") |>
  clear() |>
  dplyr::mutate(
    x = "STipo_de_contrata%E7%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5"),
    y = "&",
    tipo = "benef_op"
  ) |>
  writedb("tipo_contratacao")

# uf

html |>
  rvest::html_element("#S6") |>
  clear() |>
  dplyr::mutate(
    x = "SUF=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "29", "28"),
    y = "&",
    tipo = "benef_op"
  ) |>
  writedb("uf")

# regiao

html |>
  rvest::html_element("#S5") |>
  clear() |>
  dplyr::mutate(
    x = "SRegi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7"),
    y = "&",
    tipo = "benef_op"
  ) |>
  writedb("regiao")
