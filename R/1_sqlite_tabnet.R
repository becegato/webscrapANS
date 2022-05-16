# ------------------------------------------------ #
# --- GERAÇÃO DE DATABSE DE CONSULTA NO TABNET --- #
# ------------------------------------------------ #


# bibliotecas, funções e variáveis ----------------------------------------

source("R/0_libraries.R")
source("R/0_functions.R")

tags_dir <- fs::dir_create(glue::glue("{tempdir()}/tags"))

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
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:29)),
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
  elements = elements,
  css_selectors = c("#L", "#C", "#I", "#S9", "#S4", "#S10", "#S11"),
  db_names = c("linha", "coluna", "conteudo", "modalidade", "tipo_contratacao", "uf", "regiao")
)

purrr::pwalk(
  .l = vars,
  function(elements, css_selectors, db_names) {
    elements |>
      dplyr::mutate(
        html |>
          rvest::html_element(css_selectors) |>
          clear_html()
      ) |>
      write_db(name = db_names, dir = tags_dir)
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
    tag = c("TODAS_AS_CATEGORIAS__", paste0(1:29)),
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
  elements = elements,
  css_selectors = c("#L", "#C", "#I", "#S2", "#S3", "#S6", "#S5"),
  db_names = c("linha", "coluna", "conteudo", "modalidade", "tipo_contratacao", "uf", "regiao")
)

purrr::pwalk(
  .l = vars,
  function(elements, css_selectors, db_names) {
    elements |>
      dplyr::mutate(
        html |>
          rvest::html_element(css_selectors) |>
          clear_html()
      ) |>
      dplyr::mutate(item = dplyr::case_when(
        item == "Benef. Asst. Medica" ~ "Assistencia Medica",
        item == "Benef. Excl. Odont." ~ "Excl. Odontologico",
        TRUE ~ item
      )) |>
      write_db(name = db_names, dir = tags_dir)
  }
)

rm(elements, html, vars)
