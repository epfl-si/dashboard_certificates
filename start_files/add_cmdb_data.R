# package install
packages <- c("elastic", "RSQLite", "jsonlite")

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

# import data from cmdb index
cmdb_data <- fromJSON(Search(con_elasticsearch, index = "cmdb", size = 100000, raw = TRUE))$hits$hits$"_source"

# import data into database


# Unite table
#unit_data <- cmdb_data$unit
#unit_data_distinct <- distinct(unit_data)
#for (i in 1:nrow(unit_data_distinct)) {
#    id_unit <- unit_data_distinct$id[i]
#    path <- unit_data_distinct$path[i]
#    sigle <- unit_data_distinct$sigle[i]
#    insert_query <- sprintf("INSERT INTO Unite (id_unite, path, sigle) VALUES ('%s', '%s', '%s')", id_unit, path, sigle)
#    dbExecute(con_sqlite, insert_query)
#}

# Serveur table
for (i in 1:nrow(cmdb_data)) {
    ip_adr <- cmdb_data$ip[i]
    fqdn <- cmdb_data$fqdn[i]
    id_unite <- distinct(cmdb_data$unit)$id[i]
    insert_query <- sprintf("INSERT INTO Serveur (ip_adr, fqdn, id_unite) VALUES ('%s', '%s', '%s')", ip_adr, fqdn, id_unite)
    dbExecute(con_sqlite, insert_query)
}

# Personne table
rifs <- cmdb_data$unit$rifs
adminit <- cmdb_data$unit$adminit
rifs_df <- distinct(do.call(rbind, rifs))
adminit_df <- distinct(do.call(rbind, adminit))
#rifs_df$fonction <- "rifs"
#adminit_df$fonction <- "adminit"
mix_rifs_adminit <- distinct(rbind(rifs_df, adminit_df))
for (i in 1:nrow(cmdb_data)) {
    ip_adr <- cmdb_data$ip[i]
    for (j in 1:nrow(mix_rifs_adminit)) {
        sciper <- mix_rifs_adminit$sciper[j]
        cn <- mix_rifs_adminit$cn[j]
        email <- mix_rifs_adminit$mail[j]
        id_unite <- distinct(cmdb_data$unit)$id[j]
        insert_query <- sprintf("INSERT INTO Personne (sciper, cn, email, serveur_ip) VALUES ('%s', '%s', '%s', '%s')", sciper, cn, email, ip_adr)
        dbExecute(con_sqlite, insert_query)
    }
}