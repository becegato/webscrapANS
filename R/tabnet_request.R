# ---------------------- #
# --- TABNET REQUEST --- #
# ---------------------- #

#' Requisição de tabelas do TABNET ANS
#'
#' @param coluna Parâmetro presente em check_requests().
#' @param conteudo Parâmetro presente em check_requests().
#' @param linha Parâmetro presente em check_requests().
#' @param modalidade Parâmetro presente em check_requests().
#' @param regiao Parâmetro presente em check_requests().
#' @param tipo_contratacao Parâmetro presente em check_requests().
#' @param uf Parâmetro presente em check_requests().
#' @param search_type Sites disponíveis: "uf" para "Beneficiários por UF" e "op" para "Beneficiários por Operadora".
#' @param years Dados disponíveis: 00 a 22.
#' @param months Meses disponíveis: "03", "06", "09", "12".
#' @param sqlite_dir Diretório onde a database de tags está presente retornado por create_sqlite_tags().
#'
#' @return Um tibble.
#' @export
#'
#' @examples
#'
#' tags_dir <- create_sqlite_tags()
#' tabnet_request(
#'   coluna = "Competencia",
#'   conteudo = "Assistencia Medica",
#'   linha = "Operadora",
#'   years = 21,
#'   months = 12,
#'   search_type = "op",
#'   sqlite_dir = tags_dir
#' )
#'
tabnet_request <- function(coluna = "Nao ativa",
                           conteudo = "Assistencia Medica",
                           linha = "Competencia",
                           modalidade = NA,
                           regiao = NA,
                           tipo_contratacao = NA,
                           uf = NA,
                           search_type = "uf",
                           years = 21,
                           months = 12,
                           sqlite_dir) {
  site <- glue::glue("benef_{search_type}")

  db <- DBI::dbConnect(RSQLite::SQLite(), fs::dir_ls(sqlite_dir))

  if (site == "benef_op") {
    page <- "Arquivos=tb_cc_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_cc.def"

    request <- "{tags[3]}{tags[1]}{tags[2]}{period}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
  } else {
    page <- "Arquivos=tb_br_"

    tabnet_ans <- "http://www.ans.gov.br/anstabnet/cgi-bin/tabnet?dados/tabnet_br.def"

    request <- "{tags[3]}{tags[1]}{tags[2]}{period}SRaz%E3o_Social=TODAS_AS_CATEGORIAS__&{tags[4]}{tags[6]}SFaixa_de_Benef=TODAS_AS_CATEGORIAS__&{tags[5]}{tags[7]}SCapital=TODAS_AS_CATEGORIAS__&SInterior=TODAS_AS_CATEGORIAS__&SReg.Metropolitana=TODAS_AS_CATEGORIAS__&formato=table&mostre=Mostra"
  }

  tags <- tibble::tibble(
    names = c("coluna", "conteudo", "linha", "modalidade", "regiao", "tipo_contratacao", "uf"),
    vars = c(coluna, conteudo, linha, modalidade, regiao, tipo_contratacao, uf)
  ) |>
    dplyr::mutate(
      vars = purrr::map_chr(
        vars,
        ~ missing_args(.x)
      )
    ) |>
    dplyr::mutate(
      tags = purrr::map2_chr(
        .x = vars,
        .y = names,
        ~ multi_query(.x, .y, site, db)
      )
    ) |>
    dplyr::select(tags) |>
    purrr::flatten_chr()

  period <- purrr::map(months, ~ glue::glue("{page}{years}{.x}.dbf&")) |>
    purrr::flatten_chr()

  request <- glue::glue(request)

  DBI::dbDisconnect(db, shutdown = TRUE)

  df <- pbapply::pblapply(
    request,
    function(i) {
      tab_site <- httr::POST(
        url = tabnet_ans,
        body = i,
        httr::timeout(20)
      ) |>
        httr::content(encoding = "latin1", as = "parsed") |>
        rvest::html_node("table") |>
        rvest::html_text2() |>
        tibble::as_tibble() |>
        tidyr::separate_rows(value, sep = "\n")

      if (!is.na(tab_site[[1]][[1]])) {
        n <- tab_site |>
          dplyr::slice(1) |>
          dplyr::pull() |>
          stringr::str_count(pattern = "\t")

        tab_site <- tab_site |>
          tidyr::separate(
            col = value,
            sep = "\t",
            into = paste0(
              "x",
              seq_len(n + 1)
            )
          ) |>
          janitor::row_to_names(row_number = 1) |>
          purrr::map_df(stringr::str_replace_all, "\\.", "") |>
          janitor::clean_names()

        if ("operadora" %in% names(tab_site)) {
          tab_site <- tab_site |>
            dplyr::filter(operadora != "TOTAL") |>
            tidyr::separate(
              col = operadora,
              into = c("registro", "operadora"),
              sep = "-",
              extra = "merge"
            ) |>
            dplyr::mutate(registro = as.numeric(registro))
        }

        return(tab_site)
      } else {
        return(FALSE)
      }
    },
    cl = parallel::detectCores()
  )

  indexes <- purrr::map_dbl(
    seq_len(length(df)),
    ~ ifelse(
      tibble::is_tibble(df[[.x]]),
      .x,
      0
    )
  )

  if (sum(indexes) != 0) {
    df <- purrr::map(
      indexes[indexes != 0],
      ~ df[[.x]]
    )

    return(df)
  } else {
    return(cat("Falha na busca."))
  }
}
