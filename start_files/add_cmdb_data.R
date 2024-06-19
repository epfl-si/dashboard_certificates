# package install
packages <- c("elastic", "RSQLite", "jsonlite", "dplyr")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

# open connection with elasticsearch
con_elasticsearch <- connect(host = "es", path = "", user="", pwd = "", port = 9200, transport_schema  = "http")
# open connection with sqlite
con_sqlite <- dbConnect(RSQLite::SQLite(), "/home/sqlite/cmdb.sqlite")

# import data from cmdb index
cmdb_data <- fromJSON(Search(con_elasticsearch, index = "cmdb", size = 100000, raw = TRUE))$hits$hits$"_source"

# import data from ssl index
ssl_data <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source" %>% mutate(ipv4 = as.character(ipv4))

# filter cmdb index based on ip addresses present in ssl index
cmdb_data_filtred <- right_join(cmdb_data, ssl_data, by = join_by(ip == ipv4))

# import data into database

# Serveur table
for (i in 1:nrow(cmdb_data_filtred)) {
    ip_adr <- cmdb_data_filtred$ip[i]
    fqdn <- cmdb_data_filtred$fqdn[i]
    insert_query <- sprintf("INSERT INTO Serveur (id_ip_adr, ip, fqdn) VALUES (NULL, '%s', '%s')", ip_adr, fqdn)
    dbExecute(con_sqlite, insert_query)
}

# Personne table
rifs <- cmdb_data_filtred$unit$rifs
adminit <- cmdb_data_filtred$unit$adminit
rifs_df <- distinct(do.call(rbind, rifs))
adminit_df <- distinct(do.call(rbind, adminit))
#rifs_df$fonction <- "rifs"
#adminit_df$fonction <- "adminit"
mix_rifs_adminit <- distinct(rbind(rifs_df, adminit_df))
for (i in 1:nrow(mix_rifs_adminit)) {
    sciper <- mix_rifs_adminit$sciper[i]
    cn <- mix_rifs_adminit$cn[i]
    email <- mix_rifs_adminit$mail[i]
    insert_pers_query <- sprintf("INSERT INTO Personne (sciper, cn, email) VALUES ('%s', '%s', '%s')", sciper, cn, email)
    dbExecute(con_sqlite, insert_pers_query)
}

# Serveur_Personne table
for (i in 1:nrow(cmdb_data_filtred)) {
    ip_adr <- cmdb_data_filtred$ip[i]
    for (j in 1:nrow(mix_rifs_adminit)) {
        sciper <- mix_rifs_adminit$sciper[j]
        insert_serv_pers_query <- sprintf("INSERT INTO Serveur_Personne (id_serv_pers, ip_adr, sciper) VALUES (NULL, '%s', '%s')", ip_adr, sciper)
        dbExecute(con_sqlite, insert_serv_pers_query)
    }
}

# close connection with sqlite
dbDisconnect(con_sqlite)