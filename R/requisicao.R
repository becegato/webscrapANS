# bibliotecas e funções ---------------------------------------------------

source("R/bibliotecas.R")
source("R/funcoes.R")

# requisicao --------------------------------------------------------------

database <- DBI::dbConnect(RSQLite::SQLite(), "~/ans-tags.db") # Conexão com a base de tags

DBI::dbListTables(database) # Listando variáveis
DBI::dbReadTable(database, "linha") # Listando campos disponíveis para consulta

dados <- busca(coluna = "Modalidade",
               conteudo = "Assistencia Medica",
               linha = "UF",
               tipo_contratacao = "Todas as categorias",
               uf = "Todas as categorias",
               ano = "12",
               mes = "06")

uf <- c("Acre", "Goias")


teste <- database |>
  dplyr::tbl("uf") |>
  dplyr::collect()

uf |>
  as_tibble() |>
  rename(item = value) |>
  left_join(database |>
              dplyr::tbl("uf") |>
              dplyr::collect(),
            by = "item") |>



  dplyr::inner_join(uf, by = item)

#' Próximos passos:
#'
#' - Consultas múltiplas
#' - Expansão de consultas
#' - Catalogação automática de tags de tabelas da base de dados - feito
#' - Função de opção default "Todas as categorias" caso variável esteja vazia
