library("shiny")

# input = values defined by control widgets (Names in ui)
# output = assigned new values from Server
source('./Scripts/timeOfDay.R') # Imports charts for time of day section

server <- function(input, output) {
  output$Time.one <- renderPlot( # Plot output ("Name") is output$"Name"
    return(TimeChart.one)
  )
  output$Time.two <- renderPlot(
    return(TimeChart.two)
  )
  output$kruskal <- renderPrint(
    return(kruskal)
  )
  output$Time.three <- renderPlot(
    return(TimeChart.three)
  )
  output$Time.four <- renderPlot(
    return(TimeChart.four(input$time.of.day))
  )
  output$Time.five <- renderPlot(
    return(TimeChart.five)
  )
  output$Time.six.a <- renderPlot(
    return(TimeChart.six.a(input$time.of.day))
  )
  output$Time.six.b <- renderPlot(
    return(TimeChart.six.b(input$time.of.day))
  )
  output$Time.seven.a <- renderPlot(
    return(TimeChart.seven.a(input$time.of.day))
  )
  output$Time.seven.b <- renderPlot(
    return(TimeChart.seven.b(input$time.of.day))
  )
}

shinyServer(server)