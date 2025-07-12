library(data.table)
library(dplyr)

## caminhos -----

caminho_estab <- "bases/dados_tratados/RAIS_ESTAB_ES_2024.parquet"
caminho_vinc <- "bases/dados_tratados/RAIS_VINC_ES_2024.parquet"

## leitura -----

base_estab <- 
  arrow::read_parquet(
    caminho_estab
    )

base_vinc <- 
  arrow::read_parquet(
    caminho_vinc
  )

## colunas -----

cols_estab<- colnames(base_estab); cols_estab
# View(head(base_estab, 5))
sapply(base_estab, unique) %>% View
unique(base_estab[, uf])
unique(base_estab[, municipio])
unique(base_estab[, cnae_95_classe])
unique(base_estab[, cnae_2_0_classe])

base_estab[
  ,
  c("bairros_sp", 
    "bairros_fortaleza",
    "bairros_rj",
    "distritos_sp",
    "ind_estab_participa_pat") := NULL
  ]


## vinc

cols_vinc <- colnames(base_vinc); cols_vinc
# View(head(base_estab, 5))
sapply(base_vinc, unique) %>% View
unique(base_vinc[, municipio])
unique(base_vinc[, cnae_95_classe])
unique(base_vinc[, cnae_2_0_classe])

base_vinc[
  ,
  c("bairros_sp", 
    "bairros_fortaleza",
    "bairros_rj",
    "distritos_sp",
    "regioes_adm_df") := NULL
]


## vendo relações entre as bases ---------

intersect(colnames(base_estab), colnames(base_vinc))
