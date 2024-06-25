# package install
packages <- c("elastic", "RSQLite", "DBI", "jsonlite", "httr", "dplyr")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

# open connection with elasticsearch
con_elasticsearch <- connect(host = "localhost", path = "", user="", pwd = "", port = 9200, transport_schema  = "http")

# open connection with sqlite
con_sqlite <- dbConnect(RSQLite::SQLite(), "./volumes/sqlite/cmdb.sqlite")

# import ssl data from elasticsearch
ssl_data <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source" %>% mutate(ipv4 = as.character(ipv4))

# request to determine certificates depending on a sciper -> sciper dans Personne puis lier a Serveur_Personne pour recuperer ips et finalement obtenir details avec index ssl dans elasticsearch
sciper_test1 <- dbGetQuery(con_sqlite, "SELECT sciper FROM Personne")
ips_test1 <- distinct(dbGetQuery(con_sqlite, "SELECT ip_adr FROM Serveur_Personne WHERE sciper = <...>"))
colnames(ips_test1) <- c("ipv4")
ssl_details_test1 <- left_join(ssl_data, ips_test1, by = "ipv4")


# request to determine scipers depending on certificate -> ip dans index ssl sur elasticsearch puis lier a Serveur_Personne pour recuperer sciper et finalement obtenir details avec Personne
ssl_ips_test2 <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source"$"ipv4"
scipers_test2 <- dbGetQuery(con_sqlite, "SELECT sciper FROM Serveur_Personne WHERE ip_adr = \"<...>\"") %>% mutate(sciper = as.integer(sciper))
personne_details_test2 <- dbGetQuery(con_sqlite, "SELECT * FROM Personne WHERE sciper = ?", params = list(scipers_test2$sciper))