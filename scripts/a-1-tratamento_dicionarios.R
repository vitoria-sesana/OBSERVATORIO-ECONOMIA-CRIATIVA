## caminhos -----

caminho_estab <- "bases/dados_tratados/RAIS_ESTAB_ES_2024.parquet"
caminho_vinc <- "bases/dados_tratados/RAIS_VINC_ES_2024.parquet"
caminho_CBO <- "bases/dicionarios/dicionario_CBO_CRIATIVO.csv"
caminho_CNAE <- "bases/dicionarios/dicionario_CNAE_CRIATIVO.csv"
caminho_CBO_CLASSES <- "bases/dicionarios/CBO2002.xlsx"


## leitura -----

cnae_estab <- 
  arrow::read_parquet(
    caminho_estab, 
    col_select = c("cnae_2_0_classe",
                   "cnae_95_classe",
                   "cnae_2_0_subclasse")
  )

cbo_vinc <- 
  arrow::read_parquet(
    caminho_vinc,
    col_select = "cbo_ocupacao_2002" 
  )

dicio_CBO <- read.csv(caminho_CBO) |>
  janitor::clean_names()

dicio_CNAE <- 
  read.csv(caminho_CNAE) |>
  dplyr::mutate(
    CNAE_num = stringr::str_replace_all(CNAE, "[-/]", "")
  ) |>
  janitor::clean_names()
  
dicio_CBO_CLASSES <- 
  readxl::read_xlsx(caminho_CBO_CLASSES) |>
  janitor::clean_names() |>
  mutate(codigo = as.integer(codigo))

# cnae --------------------------------------------------------------------

dicio_CNAE$cnae_num 
dicio_CNAE$cnae_num |> unique() |> length()
cnae_estab$cnae_2_0_classe |> unique()
cnae_estab$cnae_95_classe |> unique()
cnae_estab$cnae_2_0_subclasse |> unique()

intersect(
  dicio_CNAE$cnae_num,
  cnae_estab$cnae_2_0_classe |> unique()
)

intersect(
  dicio_CNAE$cnae_num,
  cnae_estab$cnae_2_0_subclasse |> unique()
) |> length() ###

intersect(
  dicio_CNAE$cnae_num,
  cnae_estab$cnae_95_classe |> unique()
)

# CBO ---------------------------------------------------------------------

intersect(
  dicio_CBO$codigo,
  cbo_vinc$cbo_ocupacao_2002 |> unique()
) 

intersect(
  dicio_CBO$codigo,
  cbo_vinc$cbo_ocupacao_2002 |> unique()
) |> length()

intersect(
  dicio_CBO_CLASSES$codigo,
  dicio_CBO$codigo
  ) %>% length()

difsCBO <- setdiff(
  dicio_CBO$codigo,
  dicio_CBO_CLASSES$codigo
  )

difsCBO

dicio_CBO_CLASSES %>% 
  filter(codigo %in% difsCBO) %>% 
  View

cbo_vinc[cbo_ocupacao_2002 %in% difsCBO]

# tratamento CBO ----------------------------------------------------------

 dicio_CBO_tratada <-
  left_join(
    dicio_CBO,
    dicio_CBO_CLASSES,
    by = "codigo"
  ) |>
  mutate(codigo_cbo = codigo) |>
  select(-codigo)

# saídas -------------------------------------------------------------------

write.csv2(
  dicio_CBO_tratada,
  "bases/dicionarios/dicionario_CBO_CRIATIVO_tratado.csv",
  row.names = FALSE
)
