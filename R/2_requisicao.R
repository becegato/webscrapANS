# ----------------------------- #
# --- EXEMPLO DE REQUISIÇÃO --- #
# ----------------------------- #

# bibliotecas e funções ---------------------------------------------------

source("R/0_libraries.R")
source("R/0_functions.R")
source("R/1_sqlite_tabnet.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "tags/ans-tags.db")

DBI::dbListTables(database)
DBI::dbReadTable(database, "linha")

dados <- busca(
  coluna = "UF",
  conteudo = "Assistencia Medica",
  linha = "Operadora",
  ano = 21,
  mes = "12",
  site = "benef_op"
)
