
# webscrapANS

<!-- badges: start -->

[![R-CMD-check](https://github.com/phrmendes/webscrapANS/workflows/R-CMD-check/badge.svg)](https://github.com/phrmendes/webscrapANS/actions)
<!-- badges: end -->

Extração de dados do site [ANS
TABNET](http://www.ans.gov.br/anstabnet/index.htm) para os campos de
Consultas -\> Beneficiários -\> UF, Região Metropolitana e Capital e
Operadora. O pacote pega dados da página a partir de requisições e
parsing, e os converte em tabelas limpas, prontas para análise.

## Instalação

Você pode instalar a versão de desenvolvimento de `webscrapANS` do
[GitHub](https://github.com/) com:

``` r
# install.packages("devtools")
devtools::install_github("phrmendes/webscrapANS")
```

## Exemplo

Obtendo número de beneficiários de operadoras no TABNET ANS:

``` r
library(webscrapANS)

tags_dir <- webscrapANS::create_sqlite_tags()

tbl <- webscrapANS::tabnet_request(
  coluna = "Competencia",
  conteudo = "Assistencia Medica",
  linha = "Operadora",
  years = 21,
  months = 12,
  search_type = "op",
  sqlite_dir = tags_dir
)

head(tbl[[1]]) |> 
  knitr::kable()
```

| registro | operadora                       | dez_21  | total   |
|---------:|:--------------------------------|:--------|:--------|
|      477 | SOMPO SAÚDE SEGUROS SA          | 111582  | 111582  |
|      515 | ALLIANZ SAÚDE S/A               | 33834   | 33834   |
|      582 | PORTO SEGURO - SEGURO SAÚDE S/A | 340714  | 340714  |
|      701 | UNIMED SEGUROS SAÚDE S/A        | 597977  | 597977  |
|      884 | ITAUSEG SAÚDE SA                | 8455    | 8455    |
|     5711 | BRADESCO SAÚDE SA               | 3309100 | 3309100 |

<!-- devtools::build_readme() -->
