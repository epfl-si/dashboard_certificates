# FIXME : installation et activation dans autre script selon env
library(ggplot2)
library(shiny)
library(DT)
library(elastic)
library(RSQLite)
library(dplyr)
library(jsonlite)
library(roperators)

# FIXME : selon env si container ou local
options(shiny.host = "0.0.0.0")
options(shiny.port = 8180)

# open connection with elasticsearch
con_elasticsearch <- connect(host = "localhost", path = "", user="", pwd = "", port = 9200, transport_schema  = "http")
# open connection with sqlite
con_sqlite <- dbConnect(RSQLite::SQLite(), "./volumes/sqlite/cmdb.sqlite")

# import ssl data from elasticsearch
ssl_data <- fromJSON(Search(con_elasticsearch, index = "ssl", size = 10000, raw = TRUE))$hits$hits$"_source" %>% mutate(ipv4 = as.character(ipv4))
# import cmdb data from sqlite
cmdb_data_personne <- dbGetQuery(con_sqlite, "SELECT * FROM Personne")
cmdb_data_serveur <- dbGetQuery(con_sqlite, "SELECT * FROM Serveur")
cmdb_data_serveur_personne <- dbGetQuery(con_sqlite, "SELECT * FROM Serveur_Personne")

# FIXME : creation de la table a faire ici ou ailleurs ?
fqdns_ips <- cmdb_data_serveur %>% select(fqdn, ip)
responsables_scipers <- cmdb_data_serveur_personne %>% filter(fqdn %in% fqdns_ips$fqdn) %>% select(fqdn, sciper) %>% distinct()
responsables_noms <- cmdb_data_personne %>% filter(sciper %in% responsables_scipers$sciper) %>% select(sciper, cn)
responsables <- merge(responsables_scipers, responsables_noms, by = "sciper")
fqdns_ips_responsables <- fqdns_ips %>% left_join(responsables, by = c("fqdn" = "fqdn")) %>% group_by(fqdn, ip) %>% summarise(responsables = list(cn), .groups = 'drop')
dates <- ssl_data %>% filter(hostname %in% fqdns_ips_responsables$fqdn) %>% select(hostname, validFrom, validTo)
fqdns_ips_responsables_dates <- merge(fqdns_ips_responsables, dates,  by.x = "fqdn", by.y = "hostname")
tableau <- fqdns_ips_responsables_dates

ui <- fluidPage(
  titlePanel("Certificats SSL"),
  DTOutput("table"),
  verbatimTextOutput("details")
)

server <- function(input, output) {
  output$table <- renderDT({
    datatable(tableau, selection = 'single')
  })

  # affiche simplement donnees en brut -> TODO
  output$details <- renderPrint({
    req(input$table_rows_selected)
    selected_row <- input$table_rows_selected
    tableau[selected_row, ]
  })
}

shinyApp(ui = ui, server = server)
