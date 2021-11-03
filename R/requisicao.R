# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de tags

DBI::dbListTables(database) # Listando variáveis
DBI::dbReadTable(database, "Coluna") # Listando campos disponíveis para consulta

# consultas múltiplas: conteúdo, tipo de contratação e UF
# passar mês no formato de caractere (ex: mes = "01")

dados <- busca(coluna = "Modalidade",
               conteudo = "Excl. Odontologico",
               linha = "Competencia",
               tipo_contratacao = "Todas as categorias",
               uf = "Todas as categorias",
               ano = 15:21,
               mes = "06")

#' Próximos passos:
#'
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
#' - Passar base de dados como lista
