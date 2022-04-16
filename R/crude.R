install.packages("RPostgres")
install.packages("dbx")
install.packages('odbc')
# install.packages("dm")
# install.packages("DiagrammeR")

library(stf)
library(tidyverse)
library(RPostgres)
library(dbx)
library(DBI)
library(odbc)
#library(dm)

dbDisconnect(conn)


# Conexão -----------------------------------------------------------------

## ODBC

# conn <-dbConnect(odbc::odbc(),
#                  Driver="PostgreSQL Unicode",
#                  uid="postgres",
#                  pwd="postgres",
#                  database = "projetos")

## RPostgres

conn <-dbConnect(RPostgres::Postgres(),
                 host="localhost",
                 user="postgres",
                 password="postgres",
                 dbname = "projetos")

dbExecute(conn, "set search_path = stf")


# Indexação ---------------------------------------------------------------


dbExecute(conn, "alter table informacoes add primary key (incidente)")

dbExecute(conn, "alter table detalhes add constraint informacoes_detalhes_fkey
          foreign key (incidente) references informacoes (incidente)")

dbExecute(conn, "create index on detalhes (incidente)")

dbExecute(conn, "alter table partes add constraint informacoes_partes_fkey
          foreign key (incidente) references informacoes (incidente)")

dbExecute(conn, "create index on partes (incidente)")

dbExecute(conn, "alter table andamentos add constraint informacoes_andamentos_fkey
          foreign key (incidente) references informacoes (incidente)")

dbExecute(conn, "create index on andamentos (incidente)")

# modelo <- dm_from_src(conn,
#                       table_names = c("andamentos", "partes", "detalhes", "informacoes"))
#
# dm_draw(modelo, view_type = "all")


# CRUDE -------------------------------------------------------------------

q <- sqlCreateTable(conn, "tabela",
                    c(id = "serial", nome = "text", idade = "integer") )
dbExecute(conn, q)

dados <- tibble(
  nome = c("victor", "maria", "joao", "jose"),
  idade = c(10, 20, 30, 40)
)

## INSERT

dbxInsert(conn, "tabela", dados)

df <- dbGetQuery(conn, "table tabela order by id")

glimpse(df)

## UPDATE

dbxUpdate(conn, "tabela",
          tibble(nome = "victor", idade = 18),
          where_cols = "nome")

df <- dbGetQuery(conn, "table tabela order by id")

glimpse(df)

## DELETE

dbxDelete(conn, "tabela", where = tibble(id = 2))

df <- dbGetQuery(conn, "table tabela order by id")

glimpse(df)
