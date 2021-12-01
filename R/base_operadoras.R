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

# coluna

# conteúdo

html |>
  rvest::html_element("#I") |>
  clear() |>
  dplyr::mutate(
    x = "Incremento=",
    tag = c("Assist%EAncia_M%E9dica", "Excl._Odontol%F3gico"),
    y = "&"
  ) |>
  writedb("conteudo")

# modalidade

# uf

html |>
  rvest::html_element("#S10") |>
  clear() |>
  dplyr::mutate(
    x = "SUF=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "29", "28"),
    y = "&"
  ) |>
  writedb("uf")

# regiao

html |>
  rvest::html_element("#S11") |>
  clear() |>
  dplyr::mutate(
    x = "SGrande_Regi%E3o=",
    tag = c("TODAS_AS_CATEGORIAS__", "1", "2", "3", "4", "5", "6", "7"),
    y = "&"
  ) |>
  writedb("regiao")
