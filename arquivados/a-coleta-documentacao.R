# URL base do FTP
ftp_base <- "ftp://ftp.mtps.gov.br/pdet/microdados/NOVO%20CAGED/"
lista <- getURL(ftp_base, ftp.use.epsv = FALSE, dirlistonly = TRUE)
cat(lista)
arquivo <- "Leia-me.txt"

caminho_arquivo <- paste0(ftp_base, arquivo); caminho_arquivo

# Baixa o arquivo .7z
download.file(caminho_arquivo, destfile = "texto111.txt", mode = "wb")


# URL base do FTP
ftp_base <- "ftp://ftp.mtps.gov.br/pdet/microdados/NOVO%20CAGED/"
lista <- getURL(ftp_base, ftp.use.epsv = FALSE, dirlistonly = TRUE)
cat(lista)
arquivo <- "Sobre%20o%20Novo%20Caged.pdf"

caminho_arquivo <- paste0(ftp_base, arquivo); caminho_arquivo

# Baixa o arquivo .7z
download.file(caminho_arquivo, destfile = "Sobre o Novo Caged.pdf", mode = "wb")
