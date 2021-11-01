# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

dbListTables(database) # Listando variáveis

dados <- busca(coluna = "Competencia",
               conteudo = "Assistencia Medica",
               linha = "Tipo de contratacao",
               tipo_contratacao = "Todas as categorias",
               uf = "Todas as categorias",
               ano = "12",
               mes = "06")

#' Próximos passos:
#'
#' - Consultas múltiplas por meio de listas
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados - feito
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
