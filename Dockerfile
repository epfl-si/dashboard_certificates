FROM rocker/shiny

RUN apt-get update && \
    apt-get install -y sqlite3 libsqlite3-dev && \
    R -e "install.packages(c('dplyr', 'ggplot2', 'gapminder', 'elastic', 'jsonlite', 'RSQLite', 'DBI', 'shiny'))"

EXPOSE 8180