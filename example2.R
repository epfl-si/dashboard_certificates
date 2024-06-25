library(shiny)
library(ggplot2)

# define UI
ui <- page_sidebar(
  title = "Dashboard",
  sidebarLayout(sidebarPanel("Menu", selectInput(inputId = "date", label = "Choix de la date d'échéance limite:", choices = c("23.05.2024", "30.07.2025"))), mainPanel(tableOutput("liste"))),
  "Liste des certificats selon date d'échéance",
  card(plotOutput(outputId = 'scatterplot'))
)

# define server logic
server <- function(input, output, session) {
  output$scatterplot <- renderPlot({
    ggplot(data = iris) + geom_point(aes(Sepal.Length, Sepal.Width))
  })
}

# run the app
shinyApp(ui = ui, server = server)