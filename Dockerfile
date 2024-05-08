FROM rocker/shiny
RUN mkdir /home/shiny-app && chown shiny:shiny /home/shiny-app
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'gapminder'))"

#COPY ./shiny/dashboard.R /home/shiny-app/dashboard.R

EXPOSE 8180
CMD Rscript /home/shiny-app/dashboard.R