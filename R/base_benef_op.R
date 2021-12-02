#### criação de base para página de operadoras do tabnet ####

# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# url do site -------------------------------------------------------------

html <- rvest::read_html("http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_cc.def")

# construindo base de dados -----------------------------------------------

# criando base sqlite

database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # "base/ans-tags.db"

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
    tag = c("Assist%EAncia_M%E9dica", "Excl._Odontol%F3gico"),
    y = "&",
    tipo = "benef_op"
  ) |>
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

# regiao

html |>
  rvest::html_element("#S5") |>
  clear() |>
  dplyr::mutate(
    x = "SGrande_Regi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7"),
    y = "&",
    tipo = "benef_op"
  ) |>
  writedb("regiao")

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
