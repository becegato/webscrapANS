# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de tags

DBI::dbListTables(database) # Listando variáveis
DBI::dbReadTable(database, "linha") # Listando campos disponíveis para consulta

# consultas múltiplas: conteúdo, tipo de contratação e UF
# passar mês no formato de caractere (ex: mes = "01")

dados <- busca(
  # coluna = "UF",
  base = ""
  conteudo = "Assistencia Medica",
  linha = "Competencia",
  tipo_contratacao = "Todas as categorias",
  uf = "Todas as categorias",
  ano = 10,
  mes = "03"
)

#' Próximos passos:
#'
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
#' - Busca por grande região
