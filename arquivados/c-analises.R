
# source("b-leitura.R")

# estabelecimentos 59111 --------------------------------------------------

estab_cnae_59111 <- 
  base_estabelecimento %>% 
  filter(cnae_2_0_classe == 59111) %>% 
  group_by(municipio) %>% 
  summarise(n= n()) %>% 
  left_join(
    cd_ibge, by = "municipio"
  )

View(estab_cnae_59111)
sum(estab_cnae_59111$n)

write.csv2(estab_cnae_59111, "tabela_muni_estab_5911.csv")
