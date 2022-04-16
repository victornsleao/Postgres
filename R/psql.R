install.packages("RPostgres")
install.packages("dbx")
install.packages('odbc')

library(stf)
library(tidyverse)
library(RPostgres)
library(dbx)
library(DBI)
library(odbc)


# Base de dados - STF -----------------------------------------------------

informacoes <- read_stf_information(path = "data-raw/informacoes")
detalhes <- read_stf_details(path = "data-raw/detalhes")
partes <- stf_read_parties(path = "data-raw/partes")
andamento <- read_stf_docket_sheet(path = "data-raw/andamento")


# Conexão -----------------------------------------------------------------

## RPostgres

# conn <-dbConnect(RPostgres::Postgres(),
#                  host="localhost",
#                  user="postgres",
#                  password="postgres",
#                  dbname = "projetos")

## ODBC

conn <-dbConnect(odbc::odbc(),
                 Driver="PostgreSQL Unicode",
                 uid="postgres",
                 pwd="postgres",
                 database = "projetos")


# Criando Schema ----------------------------------------------------------

dbExecute(conn, 'create schema stf')
dbExecute(conn, 'set search_path = stf')

# Criando Tabelas e Inserir informações -----------------------------------


dbCreateTable(conn, 'informacoes', informacoes)
dbx::dbxInsert(conn, 'informacoes', informacoes)

dbCreateTable(conn, 'detalhes', detalhes)
dbxInsert(conn, 'detalhes', detalhes)

dbCreateTable(conn, 'partes', partes)
dbxInsert(conn, 'partes', partes)

dbCreateTable(conn, 'andamentos', andamento)
dbxInsert(conn, 'andamentos', andamento)


# Querys ------------------------------------------------------------------

i <- dbGetQuery(conn, 'SELECT * FROM informacoes')

i <- dbGetQuery(conn, 'SELECT incidente, origem, procedencia FROM informacoes')


dbListFields(conn, 'detalhes')

id <- dbGetQuery(conn, 'SELECT incidente, origem, sigilo, numero_unico, tipo_parte
                 FROM informacoes
                 INNER JOIN detalhes using (incidente)
                 INNER JOIN partes using (incidente)')


