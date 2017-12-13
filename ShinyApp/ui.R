library("shiny")
library(plotly)
library(shinythemes)
library(tidyverse)
require("maps")
library(geosphere)
library(stringr)
library(rgdal)
library(caret)
library(lubridate)
library(maptools)
if (!require(ggmap)) { install.packages('ggmap'); require(ggmap) }
library(ggmap)

here_long <-  -122.3095
here_lat <- 47.6560

seattle = get_map(location = c(here_long, here_lat), zoom = 13, maptype = 'roadmap')

ui <- navbarPage("Walk Safely at UW!",
  # define widgets
  
  theme = shinytheme("yeti"), # Set theme
  tabPanel("About",
    h1("This is amazing"),
    titlePanel("Wew"),
    mainPanel("Wew2")
  ),
  tabPanel("Time of Day",
    titlePanel("Results of testing by Time of Day"),
    sidebarLayout(
      sidebarPanel(style = "position:fixed;width:inherit;",
        selectInput("time.of.day", "Select Time",
                               list("Morning", "Mid Day", "Afternoon", "Evening", "Night", "Early Morning")
      ),
      width = 2),
      mainPanel(
        style = "padding-left: 2cm;",
        p("Time is a huge factor when discussing pedestrian safety, or so we're told. 
          Common wisdom states that night time is more dangerous than day time, but is this even true? 
          When do crimes get reported, and how does that change where the centers of crime are located? 
          Here, we look at a year's worth of SPD data in order to gain some insight."),
        plotOutput("Time.one"),
        p("First of all, we want to make sure we use as much data 
          as possible. Using reports for all years 
          possible would be ideal, but that data set is 
          too large to handle or interpret easily. Instead, we will 
          use just the past year's worth, from November 1st, 
          2016 to October 31st, 2017. That gives us 
          a full year's worth of data to look at, and its far 
          enough in the past from today that we can ensure most, 
          if not all, incidences will be closed (and therefore 
          included in the data set)."),
        p("Before we go any further though, it is important we determine whether or not the time of year has any meaningful effect on the number of observations we have to work with. If several months have much higher crime rates than others, it may skew the results of any analysis we attempt. With that in mind, let's take a look at the distribution of crimes for each month in the last year."),
        plotOutput("Time.two"),
        p("As we can see, there isn't much varience in the frequency of reported crimes in the UW area for the past year. We can use a Kruskal-Wallis to test the independence of Month and Number of Crimes, which should indicate whether there is a relationship between them or not."),
        verbatimTextOutput("kruskal"), # textOutput would get rid of formatting, makes it messy
        p("Since our null hypothesis, that the count of crimes for each month is consistent, was given a p-value of 0.4433, we can confidently reject it and state that there is no dependence between the month of year and the number of crimes reported during it."),
        p("Next, we can look at the distribution of crimes across the categories we've defined. If there's no variation there, we can continue to look at the data set as a whole, but if there's significant variation, we'll need to handle things a bit more carefully. Here we see a histogram of the Event Clearance Descriptions (what the reported crime was classified as in the SPD's computer system)."),
        plotOutput("Time.three"),
        p("We see here that there are significant differences in the types of crimes that are reported, with Crisis Complaints comprising a large number of them. This could simply be due to a large number of mental health crisises in the U-District. More likely, however, officers are unsure of what to classify a crime as in an incident report and they simply choose a catch all category that comes closest to describing what happened. Regardless, this uneven distribution means that when it comes time to perform clustering, we'll need to be careful to account for the significant weight these crimes will inflict upon the cluster centers."),
        p("We can bucket the data into 6 time frames to look at how reported crime changes throughout the day (Use widget to change time)."),
        plotOutput("Time.four"),
        p("We can see that crimes reported are generally normally distributed around the afternoon. This would suggest that the highest rate of crime is during the day, or that there are less people reporting crimes at night. Which one is true isn't possible to infer from this data."),
        plotOutput("Time.five"),
        p("Clustering reveals that the average reported crime doesn't stray too far from the Ave. Some time frames have somewhat lower densities (Use widget to change time)."),
        plotOutput("Time.six.a"),
        plotOutput("Time.six.b"),
        p("The fact that Crisis Complaints outnumber every other description and its not very specific is skewing our analysis. Let's remove those crimes and try again."),
        plotOutput("Time.seven.a"),
        plotOutput("Time.seven.b"),
        p("CONCLUSION SKL:FJKL:SDJKL:FJD:SFUIOWEF"),
        width = 8
      )
    )
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