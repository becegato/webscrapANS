library(webscrapANS)

testthat::test_that("check_tables() retorna tabelas na base de tags", {
  dir <- webscrapANS::create_sqlite_tags()

  tables_from_function <- webscrapANS::check_tables(dir)

  tables <- c("conteudo", "coluna", "linha", "modalidade", "regiao", "tipo_contratacao", "uf")

  test <- purrr::map_chr(
    tables_from_function,
    ~ .x %in% tables
  )

  x <- ifelse(FALSE %in% test, FALSE, TRUE)

  testthat::expect_equal(x, TRUE)
})

testthat::test_that("check_requests() retorna tabelas na base de tags", {
  tags_dir <- webscrapANS::create_sqlite_tags()

  requests_op <- webscrapANS::check_requests(
    search_type = "op",
    dir = tags_dir,
    table = "linha"
  )

  test <- c(!is.na(requests_op), is.character(requests_op), is.vector(requests_op))

  x <- ifelse(FALSE %in% test, FALSE, TRUE)

  testthat::expect_equal(x, TRUE)
})
