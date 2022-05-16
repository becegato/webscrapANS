# ----------------------------- #
# --- EXEMPLO DE REQUISIÇÃO --- #
# ----------------------------- #

# bibliotecas e funções ---------------------------------------------------

source("R/0_libraries.R")
source("R/0_functions.R")
source("R/1_sqlite_tabnet.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(tags_dir))

check_tables()

check_requests(
  site = "op",
  table = "coluna"
)

dados <- tabnet_request(
  coluna = "Competencia",
  conteudo = "Assistencia Medica",
  linha = "Operadora",
  years = 15:21,
  months = c(paste0("0", seq(3, 9, by = 3)), 12),
  search_type = "op"
)
