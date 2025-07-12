# Leitura RAIS: estabelecimentos e vínculos  ------------------------------
# Espírito Santo 
# 2024


# pacotes -----------------------------------------------------------------
library(dplyr)

# leitura -----------------------------------------------------------------

## estabelecimentos ----
base_estabelecimento <- 
  arrow::read_parquet(
    "RAIS_ES_2024/RAIS_ESTAB_ES_2024.parquet"
    )

## vínculo ------------
base_vinculo <- 
  arrow::read_parquet(
    "RAIS_ES_2024/RAIS_VINC_ES_2024.parquet"
  )


base_estabelecimento %>% colnames()
head(base_estabelecimento)

base_vinculo %>% colnames()
head(base_vinculo)

# leitura arquivos 7z -----------------------------------------------------

# caminho_RAIS <-
#   "bases/RAIS_VINC_PUB_MG_ES_RJ.7z"
# 
# destino_RAIS <- "bases/"
# 
# archive::archive(caminho_RAIS)
# archive::archive_extract(
#   caminho_RAIS, 
#   dir = "bases/")
# 
# 
# arquivo_7z <- "C:/MeusArquivos/dados.7z"
# destino <- "C:/MeusArquivosExtraidos/"
# 
# # Comando para o 7-Zip
# system(
#   paste0(
#     '"C:/Program Files/7-Zip/7z.exe" x "',
#     caminho_RAIS, '" -o"', destino_RAIS, '" -y'))
