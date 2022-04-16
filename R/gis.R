install.packages("geobr")
install.packages("sf")
devtools::install_github("abjur/brcities")

library(geobr)
library(sf)
library(brcities)

# Conexão, schema e extensão GIS ------------------------------------------

conn2 <-dbConnect(odbc::odbc(),
                 Driver="PostgreSQL Unicode",
                 uid="postgres",
                 pwd="postgres",
                 database = "projetos")

#dbDisconnect(conn)

conn <-dbConnect(RPostgres::Postgres(),
                 host="localhost",
                 user="postgres",
                 password="postgres",
                 dbname = "projetos")

#dbExecute(conn, "create schema geobr")
dbExecute(conn, "set search_path = geobr")
dbExecute(conn, "create extension postgis")


# Dados -------------------------------------------------------------------

siglas <- c("RO", "AC", "AM", "RR", "PA", "AP", "TO", "MA", "PI", "CE",
            "RN", "PB", "PE", "AL", "SE", "BA", "MG", "ES", "RJ", "SP", "PR",
            "SC", "RS", "MS", "MT", "GO", "DF")

indicador <- 25207L
uf_pop <- map_dfr(siglas, ~br_city_indicators(.x, indicators = indicador))

uf_pop <-  uf_pop %>%
  select(-9) %>%
  rename(pop =8) %>%
  mutate(pop = as.integer(pop))

br <- read_country(year = 2019, simplified = TRUE, showProgress = TRUE)

# Conexão base + postgres -------------------------------------------------

sf::st_write(br, conn)

DBI::dbWriteTable(conn,"uf_pop",uf_pop)

# Query -------------------------------------------------------------------

dados <- st_read(conn, query = "
                      with cte_pop as
                      (select uf, sum(pop) as pop
                      from uf_pop
                      group by uf
                      )
                      select br.abbrev_state, br.name_state, cte_pop.pop, br.geom
                      from br
                      inner join cte_pop on cte_pop.uf = br.abbrev_state
                      ")


# Plotar Mapa -------------------------------------------------------------

dados %>%
  mutate(pop = (pop/1000) %>% round(0)) %>%
  ggplot() +
  geom_sf(aes(fill = abbrev_state), show.legend = FALSE)+
  geom_sf_label(aes(label = pop),size = 2)+
  scale_fill_viridis_d() +
  theme_bw()

