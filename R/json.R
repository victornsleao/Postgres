library("jsonlite")
library("odbc")
library("DBI")
library(tidyverse)
# Conexão postgres --------------------------------------------------------

conn <-dbConnect(odbc::odbc(),
                 Driver="PostgreSQL Unicode",
                 uid="postgres",
                 pwd="postgres",
                 database = "projetos")


# Criar schema ------------------------------------------------------------

dbExecute(conn, "create schema rh")
dbExecute(conn, "set search_path = rh")

# Criar base - JSON -------------------------------------------------------

curriculo <- list(
  cpf = "123.456.789-10",
  nome = "João da Silva",
  filiacao = c(mae = "Maria da Silva", pai = "Pedro da Silva"),
  educacao = list(
    fundamental = c(escola = "Pingo de Gente", ano = 2000),
    medio = c(escola = "Plenus", ano = 2010),
    superior = c(escola = "UFAL", ano = 2020)
  )
)

curriculo <- list(
  cpf = "321.456.999-11",
  nome = "José da Silva",
  filiacao = c(mae = "Joana da Silva", pai = "Wilson da Silva"),
  educacao = list(
    fundamental = c(escola = "Pingo de Gente", ano = 2000),
    medio = c(escola = "Plenus", ano = 2010),
    superior = c(escola = "UFAL", ano = 2020)
  )
) |>
  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE) %>%
  tibble::tibble(
    json = .
  ) %>%
  dbx::dbxInsert(conn, "curriculo", .)

#jsonlite::toJSON(curriculo)
obj <- jsonlite::toJSON(curriculo, pretty = TRUE, auto_unbox = TRUE)
df <- tibble::tibble(
  json = obj
)

# Criar tabela e popular --------------------------------------------------

dbExecute(conn, "create table curriculo (json jsonb)")

dbx::dbxInsert(conn, "curriculo", df)

# Query -------------------------------------------------------------------

dbGetQuery(conn, "select json ->> 'cpf' as cpf from curriculo")
DBI::dbGetQuery(conn, "select json -> 'educacao' ->> 'medio' as educacao from curriculo")
DBI::dbGetQuery(conn, "select json['educacao']['medio'] as educacao from curriculo")
DBI::dbGetQuery(conn, "select json['educacao']['medio'][1] as educacao from curriculo")


#jsonlite::serializeJSON(curriculo, pretty = TRUE)


# Salvando e lendo .json --------------------------------------------------

write_json(curriculo, path = "data/obj.json")
obj2 <- readLines("data/obj.json")

df2 <- tibble::tibble(
  json = obj2
)

# Popular -----------------------------------------------------------------

dbx::dbxInsert(conn, "curriculo", df2)


# Update tabela -----------------------------------------------------------

dbExecute(conn, "alter table curriculo add column cpf text")
dbExecute(conn, "update curriculo set cpf = json['cpf']")
