if(!require(RCurl)){install.packages("RCurl")}
if(!require(R.utils)){install.packages("R.utils")}
if(!require(sevenZip)){install.packages("sevenZip")}

# Carregar bibliotecas
library(RCurl)
library(R.utils)
library(sevenZip)

# URL base do FTP
ftp_base <- "ftp://ftp.mtps.gov.br/pdet/microdados/NOVO%20CAGED/2024/202412/"
lista <- getURL(ftp_base, ftp.use.epsv = FALSE, dirlistonly = TRUE)
cat(lista)
arquivo <- "CAGEDMOV202412.7z"

caminho_arquivo <- paste0(ftp_base, arquivo); caminho_arquivo

# Baixa o arquivo .7z
download.file(ftp_file_path, destfile = "CAGEDMOV202412.7z", mode = "wb")

# # 2. Descompactando o arquivo
# Usando R.utils::gunzip() (se for .gz):
# gunzip(local_file_path, remove = FALSE, overwrite = TRUE)
# file_to_open <- sub(".7z$", "", local_file_path) # Remove a extensão .7z
# 
# # Usando sevenZip::seven_zip_extract() (para .7z):
# sevenZip::seven_zip_extract(archive = local_file_path, dir = extracted_dir)
