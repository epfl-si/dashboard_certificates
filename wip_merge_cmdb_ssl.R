# package install
packages <- c("elastic", "RSQLite", "DBI", "jsonlite")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

# open connection with elasticsearch
con_elasticsearch <- connect()
# open connection with sqlite
con_sqlite <- dbConnect(RSQLite::SQLite(), "./volumes/sqlite/cmdb.sqlite")

# import ssl data from elasticsearch
ssl_data <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source"

# dataframe with ips from both cmdb and ssl
ssl_data <- ssl_data %>% mutate(ipv4 = as.character(ipv4))
ssl_ips <- ssl_data[, "ipv4", drop = FALSE]

cmdb_data <- fromJSON(Search(con_elasticsearch, index = "cmdb", size = 100000, raw = TRUE))$hits$hits$"_source"
cmdb_ips <- cmdb_data[, "ip", drop = FALSE]
# query_sqlite <- "SELECT ip_adr FROM Serveur"
# cmdb_ips <- dbGetQuery(con_sqlite, query_sqlite)

ips_comparator <- inner_join(ssl_ips, cmdb_ips, by = c("ipv4" = "ip"))

# import cmdb data into sqlite database with filter
cmdb_filtred <- cmdb_data %>% filter(ip == "10.95.156.19")

# data into unite table
unit_data_flitred <- cmdb_filtred$unit
id_unit <- unit_data_flitred $id
path <- unit_data_flitred $path
sigle <- unit_data_flitred $sigle
insert_query <- sprintf("INSERT INTO Unite (id_unite, path, sigle) VALUES ('%s', '%s', '%s')", id_unit, path, sigle)
dbExecute(con_sqlite, insert_query)

# data into serveur table
ip_adr <- cmdb_filtred$ip
fqdn <- cmdb_filtred$fqdn
id_unite <- id_unit
insert_query <- sprintf("INSERT INTO Serveur (ip_adr, fqdn, id_unite) VALUES ('%s', '%s', '%s')", ip_adr, fqdn, id_unite)
dbExecute(con_sqlite, insert_query)

# data into personne table
rifs <- cmdb_filtred$unit$rifs
adminit <- cmdb_filtred$unit$adminit
rifs_df <- distinct(do.call(rbind, rifs))
adminit_df <- distinct(do.call(rbind, adminit))
#rifs_df$fonction <- "rifs"
#adminit_df$fonction <- "adminit"
mix_rifs_adminit <- distinct(rbind(rifs_df, adminit_df))
for (i in 1:nrow(mix_rifs_adminit)) {
    sciper <- mix_rifs_adminit$sciper[i]
    cn <- mix_rifs_adminit$cn[i]
    email <- mix_rifs_adminit$mail[i]
    id_unite <- distinct(cmdb_filtred$unit)$id[i]
    insert_query <- sprintf("INSERT INTO Personne (sciper, cn, email, id_unite) VALUES ('%s', '%s', '%s', '%s')", sciper, cn, email, id_unite)
    dbExecute(con_sqlite, insert_query)
}

# --------------------------------------------------------------------------- #

# request to determine certificates depending on a sciper
# cmdb : sciper -> unit_id -> ip_adr dans sqlite
# ssl : ip_adr -> tout dans elasticsearch

# KO -> filtre sur 1 personne alors meme pas lien sur serveur...

# request to determine people depending on a ip_adr
# ssl : ip_adr dans elasticsearch
# cmdb : ip_adr -> id_unite -> sciper

# KO -> filtre sur une ip dans cmdb et besoin de retrouver 23 personnes alors que uniquement 1 personne dans l'unite de la machine donc passer a cote de 22 personnes...

# OK : ip_adr dans Personne comme cle etrangere de Serveur -> TODO