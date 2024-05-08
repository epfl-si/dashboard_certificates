#install.packages("elastic")
library(elastic)
library(jsonlite)

conn <- connect()

# recuperer le nombre d'enregistrements mais ko
count <- cat_count(conn, index_name = "kibana_sample_data_flights", v = TRUE)

# KO -> Error: Argument 'txt' must be a JSON string, URL or file.
data_json <- jsonlite::fromJSON(Search(conn, index = "kibana_sample_data_flights", size = 1, row = TRUE))$hits$hits

# recuperer donnee quand format JSON
data <- Search(conn,  index = "kibana_sample_data_flights", size = 3, row = FALSE)
data$hits$hits[[1]]$`_source`$OriginRegion

# recuperer donnees partielles
partial_data <- docs_mget(conn, index = "kibana_sample_data_flights", ids = c("SlxaPY8B8kjXlPS4macN", "S1xaPY8B8kjXlPS4macN"))
data_test <- jsonlite::fromJSON(partial_data)