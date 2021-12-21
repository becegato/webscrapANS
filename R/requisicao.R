# bibliotecas e funções ---------------------------------------------------

rm(list = ls())

source("R/bibliotecas.R")
source("R/base.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "tags/ans-tags.db") # Conexão com a base de tags

DBI::dbListTables(database) # Listando variáveis
DBI::dbReadTable(database, "uf") # Listando campos disponíveis para consulta

#' consultas múltiplas: conteúdo, tipo de contratação e UF
#' passar mês no formato de caractere (ex: mes = "01")

#' beneficiários por UF e região = benef_uf
#' beneficiários por operadoras = benef_op

dados <- busca(
  coluna = "Competencia",
  conteudo = "Assistencia Medica",
  linha = "Operadora",
  ano = 14:21,
  mes = "06",
  site = "benef_op"
)

#' Próximos passos:

#' - Catalogação automática de tags de tabelas da base de dados
