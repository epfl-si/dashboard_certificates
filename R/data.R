#install.packages("jsonlite")

library(jsonlite)

# bash ./R/reformat_json.bash
data <- jsonlite::fromJSON(txt = './R/clean_ssl.json')$data$"_source"