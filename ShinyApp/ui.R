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
  tabPanel("Time",
    h1("Page 2"),
    titlePanel("Title"),
    mainPanel("Content WOW")
  ),
  tabPanel("Proximity",
    h1("Page 3"),
    titlePanel("Title"),
    mainPanel("Content WOW")
  )
  # 
  # h1("My App"),  # first argument
  # textInput('username', label="What is your name?"),  # second argument, var name first
  # textOutput('message')  # third argument
)

shinyUI(ui)