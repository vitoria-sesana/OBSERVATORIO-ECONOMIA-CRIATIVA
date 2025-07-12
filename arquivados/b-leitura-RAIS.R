library(data.table)

caminho_RAIS <- "bases/RAIS_VINC_PUB_MG_ES_RJ/RAIS_VINC_PUB_MG_ES_RJ.txt"

cols <- colnames(fread(caminho_RAIS, nrows=0))
cols
cols[22]

dado <- 
  fread(
    file = caminho_RAIS,
    sep = ";", 
    dec = ",",
    select = 22L,
    header = T,
    encoding = "Latin-1",
    data.table = TRUE,
    showProgress = FALSE
    )

mapa_caract <- dado[,.(Total=.N),by=UF]
mapa_caract[,Inicial:=cumsum(Total)-Total]
mapa_caract[,Final:=cumsum(Total)]

