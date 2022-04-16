
arquivos <- c("ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_CENTRO_OESTE.7z",
"ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_MG_ES_RJ.7z",
"ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_NORDESTE.7z",
"ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_NORTE.7z",
"ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_SP.7z",
"ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2018/RAIS_VINC_PUB_SUL.7z"
)

purrr::walk(arquivos, download.file)
