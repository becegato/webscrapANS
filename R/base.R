#### criação de base para página de beneficiários do tabnet ####

# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")


# pasta da base sqlite ----------------------------------------------------

if (fs::dir_exists("tags/") == F) {
  fs::dir_create("tags/")
} else {
  fs::dir_delete("tags/")

  fs::dir_create("tags/")
}

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

# beneficiários por UF ----------------------------------------------------

elements <- list(
  linha = tibble::tibble(
    x = "Linha=",
    tag = c("Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o%2FUF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana"),
    y = "&",
    tipo = "benef_uf"
  ),
  coluna = tibble::tibble(
    x = "Coluna=",
    tag = c("--N%E3o-Ativa--", "Compet%EAncia", "Sexo", "Faixa_et%E1ria", "Faixa_et%E1ria-Reajuste", "Tipo_de_contrata%E7%E3o", "%C9poca_de_contrata%E7%E3o", "Segmenta%E7%E3o", "Segmenta%E7%E3o_grupo", "Abrg._Geogr%E1fica", "Modalidade", "UF", "Grande_Regi%E3o", "Capital", "Interior", "Reg._Metropolitana"),
    y = "&",
    tipo = "benef_uf"
  ),
  conteudo = tibble::tibble(
    x = "Incremento=",
    tag = c("Assist%EAncia_M%E9dica", "Excl._Odontol%F3gico"),
    y = "&",
    tipo = "benef_uf"
  ),
  modalidade = tibble::tibble(
    x = "SModalidade=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:9)),
    y = "&",
    tipo = "benef_uf"
  ),
  tipo_contratacao = tibble::tibble(
    x = "STipo_de_contrata%E7%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:5)),
    y = "&",
    tipo = "benef_uf"
  ),
  estado = tibble::tibble(
    x = "SUF=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:29)), # "29", "28"
    y = "&",
    tipo = "benef_uf"
  ),
  regiao = tibble::tibble(
    x = "SGrande_Regi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:7)),
    y = "&",
    tipo = "benef_uf"
  )
)

html <- rvest::read_html("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_br.def")

vars <- list(
  a = elements,
  b = c("#L", "#C", "#I", "#S9", "#S4", "#S10", "#S11"), # css da página
  c = c("linha", "coluna", "conteudo", "modalidade", "tipo_contratacao", "uf", "regiao") # nome das tabelas da base de consulta
)

purrr::pmap(
  .l = vars,
  function(a, b, c) {
    a |>
      dplyr::mutate(
        html |>
          rvest::html_element(b) |>
          clear()
      ) |>
      writedb(c)
  }
)

# beneficiários por operadora ---------------------------------------------

elements <- list(
  linha = tibble::tibble(
    x = "Linha=",
    tag = c("Compet%EAncia", "Operadora", "Modalidade", "Tipo_de_contrata%E7%E3o", "Faixa_de_Benef", "Regi%E3o", "UF_", "Capital", "Reg.Metropolitana"),
    y = "&",
    tipo = "benef_op"
  ),
  coluna = tibble::tibble(
    x = "Coluna=",
    tag = c("--N%E3o-Ativa--", "Compet%EAncia", "Modalidade", "Tipo_de_contrata%E7%E3o", "Faixa_de_Benef", "Regi%E3o", "UF", "Capital", "Interior", "RM"),
    y = "&",
    tipo = "benef_op"
  ),
  conteudo = tibble::tibble(
    x = "Incremento=",
    tag = c("Benef._Asst._M%E9dica", "Benef._Excl._Odont."),
    y = "&",
    tipo = "benef_op"
  ),
  modalidade = tibble::tibble(
    x = "SModalidade=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:9)),
    y = "&",
    tipo = "benef_op"
  ),
  tipo_contratacao = tibble::tibble(
    x = "STipo_de_contrata%E7%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:5)),
    y = "&",
    tipo = "benef_op"
  ),
  estado = tibble::tibble(
    x = "SUF=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:29)), # "29", "28"
    y = "&",
    tipo = "benef_op"
  ),
  regiao = tibble::tibble(
    x = "SRegi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:7)),
    y = "&",
    tipo = "benef_op"
  )
)

html <- rvest::read_html("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_cc.def")

vars <- list(
  a = elements,
  b = c("#L", "#C", "#I", "#S2", "#S3", "#S6", "#S5"), # css da página
  c = c("linha", "coluna", "conteudo", "modalidade", "tipo_contratacao", "uf", "regiao") # nome das tabelas da base de consulta
)

purrr::pmap(
  .l = vars,
  function(a, b, c) {
    a |>
      dplyr::mutate(
        html |>
          rvest::html_element(b) |>
          clear()
      ) |>
      dplyr::mutate(item = dplyr::case_when(
        item == "Benef. Asst. Medica" ~ "Assistencia Medica",
        item == "Benef. Excl. Odont." ~ "Excl. Odontologico",
        TRUE ~ as.character(item)
      )) |>
      writedb(c)
  }
)
