# VÍNCULO

library(data.table)
library(dplyr)
options(arrow.unsafe_metadata = TRUE)

# caminhos ----------------------------------------------------

caminho_vinc <- "bases/dados_tratados/RAIS_VINC_ES_2024.parquet"
caminho_dicio_CBO <- "bases/dicionarios/dicionario_CBO_CRIATIVO_tratado.csv"
caminho_dicio_CNAE <- "bases/dicionarios/dicionario_CNAE_CRIATIVO.csv"

# leitura: dicionarios -----------------------------------------

dicio_CBO <- 
  read.csv2(caminho_dicio_CBO) |>
  rename(classe_cbo = titulo) |>
  as.data.table()

dicio_CNAE <- 
  read.csv(caminho_dicio_CNAE) |>
  dplyr::mutate(
    CNAE_num = stringr::str_replace_all(CNAE, "[-/]", "")
  ) |>
  janitor::clean_names() |> 
  mutate(codigo_cnae = as.integer(cnae_num)) |>
  select(-cnae_num, -cnae) |>
  as.data.table()

classe_escolaridade <- data.table(
  Nivel = c(
    "Analfabeto",
    "Até a 5ª série incompleta",
    "5ª série do fundamental completa",
    "6ª a 9ª série do fundamental",
    "Fundamental completo",
    "Médio incompleto",
    "Médio completo",
    "Superior incompleto",
    "Superior completo",
    "Mestrado",
    "Doutorado",
    "Ignorado"
  ),
  Codigo = as.integer(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1))
)

classe_cor_raca <- data.table(
  Nivel = c(
    "Indígena",
    "Branca",
    "Preta",
    "Amarela",
    "Parda",
    "Não identificado",
    "Ignorado"
  ),
  Codigo = as.integer(c(1, 2, 4, 6, 8, 9, -1))
)

classe_faixa_etaria <- data.table(
  Nivel = c(
    "10 a 14 anos",
    "15 a 17 anos",
    "18 a 24 anos",
    "25 a 29 anos",
    "30 a 39 anos",
    "40 a 49 anos",
    "50 a 64 anos",
    "65 anos ou mais",
    "Não classificado"
  ),
  Codigo = c(1, 2, 3, 4, 5, 6, 7, 8, 99)
)

classes_municipios <- 
  geobr::read_municipality(code_muni = "ES", year = 2020, simplified = TRUE) |>
  select(code_muni, name_muni) |>
  mutate(municipio = stringr::str_sub(as.character(code_muni), end = 6L),
         municipio = as.integer(municipio)) |>
  as.data.table() |>
  select(-geom, -code_muni) 



## leitura: bases -----------------------------------------

base_vinc <- 
  arrow::read_parquet(
    caminho_vinc
  )

base_vinc[
  ,
  c("bairros_sp", 
    "bairros_fortaleza",
    "bairros_rj",
    "distritos_sp",
    "regioes_adm_df") := NULL
]

#base_vinc[ mes_desligamento  == "{ñ",]
# selecionando ------------------------------------------------------------

# variaveis de interesses
base_vinc_criativo <- base_vinc[ , c(
  "municipio",
  # sobre o vinculo
  "mun_trab",
  "vl_remun_media_nom",
  "cbo_ocupacao_2002",
  "mes_desligamento",
  "mes_admissao",
  # caracteristicas sociais 
  "sexo_trabalhador",
  "raca_cor",
  "idade",
  "faixa_etaria",
  "escolaridade_apos_2005",
  "ind_portador_defic",
  # "nacionalidade",
  # caracteristicas estabelecimento
  "cnae_2_0_subclasse",
  "tipo_estab_2",
  "tamanho_estabelecimento"
)]


# tratamento das bases ----------------------------------

## cbo --------------------------

base_vinc_criativo[, codigo_cbo := cbo_ocupacao_2002]

base_vinc_criativo[, codigo_cbo := 
             fifelse(cbo_ocupacao_2002 %in% dicio_CBO$codigo_cbo,
                     cbo_ocupacao_2002, 
                     999999)]

base_vinc_criativo[, ind_criativo_cbo := 
             as.numeric(fifelse(cbo_ocupacao_2002 %in% dicio_CBO$codigo_cbo, 1, 0))
]

base_vinc_criativo <- dicio_CBO[base_vinc_criativo, on = "codigo_cbo"]

base_vinc_criativo[is.na(classe_cbo), classe_cbo := "Ocupação não Criativa"]

## cnae -------------------------

base_vinc_criativo[, codigo_cnae := 
             fifelse(cnae_2_0_subclasse %in% dicio_CNAE$codigo_cnae,
                     cnae_2_0_subclasse, 
                     9999999)]

base_vinc_criativo <- dicio_CNAE[base_vinc_criativo, on = "codigo_cnae"]
base_vinc_criativo[is.na(grande_setor), grande_setor := "Setor não Criativo"]
base_vinc_criativo[is.na(segmento), segmento := "Segmento não Criativo"]
base_vinc_criativo[is.na(descricao_da_atividade), descricao_da_atividade := "Atividade não Criativa"]

## outros tratamentos ---------------------------

# sexo 
base_vinc_criativo[, sexo_trabalhador := fifelse(sexo_trabalhador == 1, "Masculino", "Feminino" )]

# raca/cor 
base_vinc_criativo[, raca_cor := fifelse(
  raca_cor %in% classe_cor_raca$Codigo,
  classe_cor_raca[match(raca_cor, Codigo), Nivel],
  NA_character_ 
)]

# escolaridade
base_vinc_criativo[, escolaridade_apos_2005 := fifelse(
  escolaridade_apos_2005 %in% classe_escolaridade$Codigo,
  classe_escolaridade[match(escolaridade_apos_2005, Codigo), Nivel],
  NA_character_ 
)]

# faixa etaria
base_vinc_criativo[, faixa_etaria := fifelse(
  faixa_etaria %in% classe_faixa_etaria$Codigo,
  classe_faixa_etaria[match(faixa_etaria, Codigo), Nivel],
  NA_character_ 
)]

# deficiencia 
base_vinc_criativo[, ind_portador_defic := fifelse(ind_portador_defic == 1, "Com deficiência", "Sem deficiência" )]

# muni 

base_vinc_criativo <- classes_municipios[base_vinc_criativo, on = "municipio"]


# saída -------------------------------------------------------------------

arrow::write_parquet(base_vinc_criativo, "bases/bases_dash/base_vinc_criativo.parquet")

