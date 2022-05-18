testthat::test_that("create_sqlite_tags() retorna o diretório de uma base de dados", {
  exists_db <- webscrapANS::create_sqlite_tags() |>
    fs::dir_ls() |>
    stringr::str_detect("tags\\.db")

  testthat::expect_equal(exists_db, TRUE)
})
