library(data.table)
options(arrow.unsafe_metadata = TRUE)

# caminhos ----------------------------------------------------

caminho_estab <- "bases/dados_tratados/RAIS_ESTAB_ES_2024.parquet"
caminho_vinc <- "bases/dados_tratados/RAIS_VINC_ES_2024.parquet"
caminho_dicio_CBO <- "bases/dicionarios/dicionario_CBO_CRIATIVO_tratado.csv"
caminho_dicio_CNAE <- "bases/dicionarios/dicionario_CNAE_CRIATIVO.csv"

# leitura: dicionarios -----------------------------------------

dicio_CNAE <- 
  read.csv(caminho_dicio_CNAE) |>
  dplyr::mutate(
    CNAE_num = stringr::str_replace_all(CNAE, "[-/]", "")
  ) |>
  janitor::clean_names() |> 
  mutate(codigo_cnae = as.integer(cnae_num)) |>
  select(-cnae_num, -cnae) |>
  as.data.table()

dicio_CBO <- 
  read.csv2(caminho_dicio_CBO) |>
  rename(classe_cbo = titulo) |>
  as.data.table()

## leitura: bases -----------------------------------------

base_estab <- 
  arrow::read_parquet(
    caminho_estab
  )

base_vinc <- 
  arrow::read_parquet(
    caminho_vinc
  )

# tratamento das bases ----------------------------------

## padronizando nomes colunas cbo e cnae -----
base_estab[, codigo_cnae := cnae_2_0_subclasse]
base_vinc[, codigo_cnae := cnae_2_0_subclasse]
base_vinc[, codigo_cbo := cbo_ocupacao_2002]

base_estab <- dicio_CNAE[base_estab, on = "codigo_cnae"]
base_vinc <- dicio_CNAE[base_vinc, on = "codigo_cnae"]
base_vinc <- dicio_CBO[base_vinc, on = "codigo_cbo"]

base_estab[, classe_criativo_cnae := 
             as.numeric(fifelse(codigo_cnae %in% dicio_CNAE$codigo_cnae, 1, 0))
           ]

base_vinc[, classe_criativo_cnae := 
            as.numeric(fifelse(codigo_cnae %in% dicio_CNAE$codigo_cnae, 1, 0))
          ]

base_vinc[, classe_criativo_cbo := 
            as.numeric(fifelse(codigo_cbo %in% dicio_CBO$codigo_cbo, 1, 0))
          ]

# validacao -------------- 
base_vinc %>% 
  mutate(x = (classe_criativo_cbo == classe_criativo_cnae)) %>% 
  select(classe_criativo_cbo, classe_criativo_cnae, x) %>% 
  View() ## 

base_vinc %>% 
  mutate(x = (classe_criativo_cbo == classe_criativo_cnae)) %>% 
  select(x) %>% 
  table() ## 
