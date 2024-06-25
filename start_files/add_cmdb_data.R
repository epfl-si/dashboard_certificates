# package install
packages <- c("elastic", "RSQLite", "jsonlite", "dplyr")

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

# import data from cmdb index
cmdb_data <- fromJSON(Search(con_elasticsearch, index = "cmdb", size = 100000, raw = TRUE))$hits$hits$"_source"

# import data from ssl index
ssl_data <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source" %>% mutate(ipv4 = as.character(ipv4))

# FIXME !!!
# but est de filtrer l'index cmdb pour ensuite alimenter les tables dans sqlite (avant filtre sur ip mais certificat rattache a fqdn/hostname et pas a ip)
# semi pour ne garder que colonnes de cmdb et que lignes similaires entre cmdb et ssl sur fqdn = hostname
cmdb_data_filtred_semi <- semi_join(cmdb_data, ssl_data, by = c("fqdn" = "hostname")) # pourquoi uniquement 557 lignes ?
# tentative de filtrer avec right
cmdb_data_filtred_right <- right_join(cmdb_data, ssl_data, by = c("fqdn" = "hostname")) # centaine de lignes en trop (2628) car doublons
# recherche des doublons
doublons_ssl <- ssl_data$hostname %>% unique() # pas de doublon dans ssl
doubons_cmdb <- cmdb_data$fqdn %>% unique() # doublons dans cmdb -> 88209 a 87557
cmdb_data_unique <- cmdb_data %>% distinct() # toujours 88209 donc pas vraiment des doublons ?
# trouver 652 doublons de fqdn dans cmdb
fqdn_nb_doublons <- cmdb_data %>% group_by(fqdn) %>% tally() %>% filter(n > 1) # 638 doublons et pas 652...
fqdn_doublons <- fqdn_nb_doublons %>% ungroup() %>% select(fqdn) # liste des doublons
# pourquoi pas le meme nombre de doublons ?
cmdb_data_filtred <- cmdb_data_filtred_semi

# import data into database

# Serveur table
for (i in 1:nrow(cmdb_data_filtred)) {
    ip_adr <- cmdb_data_filtred$ip[i]
    fqdn <- cmdb_data_filtred$fqdn[i]
    insert_query <- sprintf("INSERT INTO Serveur (id_ip_adr, fqdn, ip) VALUES (NULL, '%s', '%s')", fqdn, ip_adr)
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
    fqdn <- cmdb_data_filtred$fqdn[i]
    for (j in 1:nrow(mix_rifs_adminit)) {
        sciper <- mix_rifs_adminit$sciper[j]
        insert_serv_pers_query <- sprintf("INSERT INTO Serveur_Personne (id_serv_pers, fqdn, sciper) VALUES (NULL, '%s', '%s')", fqdn, sciper)
        dbExecute(con_sqlite, insert_serv_pers_query)
    }
}

# close connection with sqlite
dbDisconnect(con_sqlite)
