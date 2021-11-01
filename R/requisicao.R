# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "base/ans-tags.db") # Conexão com a base de tags

DBI::dbListTables(database) # Listando variáveis
DBI::dbReadTable(database, "coluna") # Listando campos disponíveis para consulta

# consultas múltiplas: conteúdo, tipo de contratação e UF
# passar ano no formato anoMes (ex: jun-2021 - 2106)

dados <- busca(coluna = "Nao ativa",
               conteudo = c("Assistencia Medica", "Excl. Odontologico"),
               linha = "UF",
               tipo_contratacao = "Todas as categorias",
               uf = c("Acre", "Goias", "Sao Paulo"),
               periodo = "1206")

#' Próximos passos:
#'
#' - Consultas múltiplas por período
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
#' - Passar base de dados como lista
