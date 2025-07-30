# ESTABELECIMENTO 

library(data.table)
library(dplyr)
options(arrow.unsafe_metadata = TRUE)

# caminhos ----------------------------------------------------

caminho_estab <- "bases/dados_tratados/RAIS_ESTAB_ES_2024.parquet"
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

classe_tamanho <- 
  c("Zero",	1,
    "Até 4",	2,
    "De 5 a 9",	3,
    "De 10 a 19",	4,
    "De 20 a 49",	5,
    "De 50 a 99",	6,
    "De 100 a 249",	7,
    "De 250 a 499",	8,
    "De 500 a 999",	9,
    "1000 ou mais",	10,
    "Ignorado",	-1) |> 
  matrix(ncol = 2, byrow = TRUE) |>
  as.data.frame() |>
  dplyr::mutate(V2 = as.integer(V2)) |>
  dplyr::rename(classe_tamanho_estabelecimento = V1,
                tamanho_estabelecimento = V2) |>
  as.data.table()

classes_municipios <- 
  geobr::read_municipality(code_muni = "ES", year = 2020, simplified = TRUE) |>
  select(code_muni, name_muni) |>
  mutate(municipio = stringr::str_sub(as.character(code_muni), end = 6L),
         municipio = as.integer(municipio)) |>
  as.data.table() |>
  select(-geom, -code_muni) 
  


## leitura: bases -----------------------------------------

base_estab <- 
  arrow::read_parquet(
    caminho_estab
  )

# selecionando ------------------------------------------------------------

# variaveis de interesses
base_estab <- 
  base_estab[ , c(
    "municipio",
    "cnae_2_0_subclasse",
    "tamanho_estabelecimento",
    "qtd_vinculos_ativos",
    "qtd_vinculos_clt",
    "qtd_vinculos_estatutarios"
)]

base_estab[, codigo_cnae := 
             fifelse(cnae_2_0_subclasse %in% dicio_CNAE$codigo_cnae,
                     cnae_2_0_subclasse, 
                     9999999)]

base_estab[, ind_criativo_cnae := 
             as.numeric(fifelse(codigo_cnae %in% dicio_CNAE$codigo_cnae, 1, 0))
]




base_estab_criativo <- 
  base_estab[, .(soma_qtnd_estab_criativos = sum(ind_criativo_cnae),
                 soma_qtd_vinculos_ativos = sum(qtd_vinculos_ativos),
                 soma_qtd_vinculos_clt = sum(qtd_vinculos_clt),
                 soma_qtd_vinculos_estatutarios = sum(qtd_vinculos_estatutarios)
                 ), 
                by = c("municipio", "codigo_cnae", "tamanho_estabelecimento")]


# tratando nomes 
base_estab_criativo <- dicio_CNAE[base_estab_criativo, on = "codigo_cnae"]
base_estab_criativo[is.na(grande_setor), grande_setor := "Setor não Criativo"]
base_estab_criativo[is.na(segmento), segmento := "Segmento não Criativo"]
base_estab_criativo[is.na(descricao_da_atividade), descricao_da_atividade := "Atividade não Criativa"]

base_estab_criativo <- classe_tamanho[base_estab_criativo, on = "tamanho_estabelecimento"]
base_estab_criativo <- classes_municipios[base_estab_criativo, on = "municipio"]

setcolorder(base_estab_criativo, c(
  "municipio",
  "name_muni",
  "soma_qtnd_estab_criativos",
  "codigo_cnae",
  "grande_setor",
  "segmento",
  "descricao_da_atividade",
  "tamanho_estabelecimento",
  "classe_tamanho_estabelecimento",
  "soma_qtd_vinculos_ativos",
  "soma_qtd_vinculos_clt",
  "soma_qtd_vinculos_estatutarios"
))


# saída -------------------------------------------------------------------

arrow::write_parquet(base_estab_criativo, "bases/bases_dash/base_estab_criativo.parquet")

