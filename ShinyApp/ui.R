library("shiny")
library(plotly)
library(shinythemes)

ui <- navbarPage("Walk Safely at UW!",
  # define widgets
  theme = shinytheme("yeti"), # Set theme
  tabPanel("About",
           mainPanel(
             tags$h2('Our Project'),
             tags$p(
               "Our project set out to study what influences the risk of crime to a pedestrian in Seattle's U-District. As 
               students, we're often faced with the task of walking home safely, and as anyone around this area will tell you,
               that is sometimes easier said than done. Our goal was to analyze years of Seattle City Police Department 911 call
               data to attempt to find patterns of crimes against pedestrians in order to lend advice to those wishing to avoid areas with
               a history of danger."
             ),
             tags$h2('What we did'),
             tags$p(
               "In order to study the effects of a variety of conditions on crime in the U-District area, we had to decide what was relevant
               to someone attempting to walk from point A to point B in worrisome areas. We reasoned that that the following were important
               factors to consider when doing analysis:",
               tags$ul(
                 tags$li('Type of crime'),
                 tags$li('Time of Day'),
                 tags$li('Police responsiveness'),
                 tags$li('Proximity to public services')
               ),
               "To address the first factor, type of crime, we decided only to look at crimes likely to directly put a pedestrian in harms
               way. Such crimes include muggings, assaults, hazards, and robberies. We faced unique challenges in handling the other factors
               , the details of which are outline in the other sections of this site."
             ),
             tags$h2('How to use this site'),
             tags$p(
               "Our results are seperated into three tabs, which you can see at the top of this page. We encourage you to click on any one
               of them to learn more about how we examine the factors of risk we identified."
             )
             )
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