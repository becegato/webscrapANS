
# webscrapANS

<!-- badges: start -->
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
  years = 20:21,
  months = 12,
  search_type = "op",
  sqlite_dir = tags_dir
)

head(tbl)
#> # A tibble: 6 × 4
#>   registro operadora                       dez_21  dez_20 
#>      <dbl> <chr>                           <chr>   <chr>  
#> 1      477 SOMPO SAÚDE SEGUROS SA          111582  90013  
#> 2      515 ALLIANZ SAÚDE S/A               33834   36745  
#> 3      582 PORTO SEGURO - SEGURO SAÚDE S/A 340714  269182 
#> 4      701 UNIMED SEGUROS SAÚDE S/A        597977  533308 
#> 5      884 ITAUSEG SAÚDE SA                8455    9065   
#> 6     5711 BRADESCO SAÚDE SA               3309100 3267234
```

<!-- devtools::build_readme() -->
