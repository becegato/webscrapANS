testthat::test_that("tabnet_request() retorna tibble com dados do TABNET ANS", {
  tags_dir <- webscrapANS::create_sqlite_tags()

  df <- webscrapANS::tabnet_request(sqlite_dir = tags_dir)

  test <- tibble::is_tibble(df)

  testthat::expect_equal(test, TRUE)
})
