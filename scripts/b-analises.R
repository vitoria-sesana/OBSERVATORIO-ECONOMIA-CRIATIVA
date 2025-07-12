
# por municipio -----------------------------------------------------------

base_estab[, .(qtd_criativos = sum(classe_criativo_cnae)), by = municipio]

base_vinc[, .(qtd_criativos = sum(classe_criativo_cnae)), by = municipio]


colnames(base_estab)
