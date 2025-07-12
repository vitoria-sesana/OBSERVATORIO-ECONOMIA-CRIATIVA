# Leitura do arquivo RAIS de 2024 do ES -----------------------------------

#source("http://cemin.wikidot.com/local--files/raisr/rais.r")
options(timeout = 8000) 

# pacotes -----------------------------------------------------------------

library(RCurl) # leitura dos arquivos FTP do Ministério do Trabalho
library(archive) # dezipar arquivos .7z
library(devtools)

# Leitura geral -----------------------------------------------------------

# # URL base do FTP
# ftp_base <- "ftp://ftp.mtps.gov.br/pdet/microdados/"
# 
# # Listar os arquivos/pastas
# lista <- getURL(ftp_base, ftp.use.epsv = FALSE, dirlistonly = TRUE)
# cat(lista)

# Leitura do arquivo RAIS 2024 --------------------------------------------

## caminho RAIS 2024 SUDESTE ------
ftp_rais <- "ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2024/"
lista_rais <- getURL(ftp_rais, ftp.use.epsv = FALSE, dirlistonly = TRUE)
cat(lista_rais)
arquivo <- "RAIS_VINC_PUB_MG_ES_RJ.7z"
caminho_arquivo_RAIS <- paste0(ftp_rais, arquivo); caminho_arquivo_RAIS

caminho_destino_RAIS <- "bases"

archive_extract(caminho_arquivo_RAIS, dir = caminho_destino_RAIS)

x <- "ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2024/RAIS_VINC_PUB_MG_ES_RJ.7z"

x

# Baixar
download.file(x, destfile = "arquivo_raiz.7z", mode = "wb")
