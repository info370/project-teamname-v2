library("shiny")
library(plotly)
library(shinythemes)

ui <- navbarPage("Walk Safely at UW!",
  # define widgets
  theme = shinytheme("yeti"), # Set theme
  tabPanel("About",
    h1("This is amazing"),
    titlePanel("Wew"),
    mainPanel("Wew2")
  ),
  tabPanel("Methodology",
   h1("This is amazing"),
   titlePanel("Wew"),
   mainPanel("Wew2")
  ),
  tabPanel("Time of Day",
    h1("Page 2"),
    titlePanel("Title"),
    mainPanel("Content WOW")
  ),
  tabPanel("Clearance Time",
   h1("Page 3"),
   titlePanel("Title"),
   mainPanel("Content WOW")
  ),
  tabPanel("Proximity",
    h1("Page 4"),
    titlePanel("Title"),
    mainPanel("Content WOW")
  )
)

shinyUI(ui)