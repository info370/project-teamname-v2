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
               "To address the first factor, type of crime, we decided only to look at crimes likely to directly put a pedestrian in harm's
               way. Such crimes include muggings, assaults, hazards, and robberies. We faced unique challenges in handling the other factors
               , the details of which are outlined in the other sections of this app."
             ),
             tags$h2('How to use this app'),
             tags$p(
               "Our results are seperated into three tabs, which you can see at the top of this page. We encourage you to click on any one
               of them to learn more about how we examine the factors of risk we identified."
             )
             )
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
        p("Crimes within the last year (No Crisis Complaints)"),
        plotOutput("Time.seven.a"),
        p("Count of crimes without Crisis Complaints"),
        plotOutput("Time.seven.b"),
        p("Clustering not factoring in Crisis Complaints"),
        plotOutput("Time.seven.c"),
        p("Clustering density not factoring in Crisis Complaints"),
        plotOutput("Time.seven.d"),
        p(
          "In conclusion, there is variance in reported crime throughout the day. The highest time of activity seems to be around
          mid day, which might be contrary to popular belief. It's still yet to be determined what effect less people around during night
          time has on rate of crime reporting. Intuition should suggest that if there are less people awake to witness crimes, there's
          a good chance less crime will be reported. This could explain why there are more reported crimes during the day, but it
          would be interesting to study this in further detail at a later date. For now, we find it advisable to continue being
          vigilant during all hours of the day."
        ),
        p(
          "From our clustering analysis we can see that the area between 42nd and 50th, Brooklyn to 15th is the hottest spot for 
          reported pedestrian crimes. While there are outliers that may change throughout the day, most crimes tend to be reported 
          in this area. Furthermore, it appears that during the afternoon and early morning, most crimes take place on 45th Avenue
          specifically. It is advisable to be extra careful on this part of campus during these hours.
          "
        ),
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
    style = "padding-left: 2cm",
    h2("Results of testing by proximity to public services"),
    mainPanel(
      p(
        "Another one of the factors we investigated was whether or not proximity to public services, such as transport services like bus stops, had an impact on the frequency of crime in an area."
      ),
      p("
        To perform this analysis, we cross-referenced data between our filtered down crime dataset and Google Transit data regarding bus stops in Seattle. To begin with, a map showing all bus stops in our considered region is depicted below."
        ),
      img(src='Bus_Stops.png'),
      p("
        As one would expect, the points on the map are aligned with the city's streets."
        ),
      p("
        Next, we defined 'dangerous bus stops' to be any stop with at least one criminal incident reported within 20 meters. Of the 297 stops found within 2600 meters of Red Square, 49 fell under this category. A histogram depicting frequency by proximity to stops may be seen here:
        "),
      img(src='Bus_Stops_Histogram.png'),
      p("
        With this, we can see that the majority of stops are likely to be safe - however, there are several outliers that have significantly higher rates of crime around them than the rest of the data set. While a mapping of all 49 stops featuring criminal incidents within 20 meters may look like this:
        "),
      img(src='Dangerous_Bus_Stops.png'),
      p("
        A mapping of the stops with the highest frequency of incident reports, including at least one per month in the dataset we have, will look like this:
        "),
      img(src='Most_Dangerous_Stops.png'),
      p("
        And these results are in line with the results of the clustering anaylsis we performed, which suggested that the area up and down University Way right next to U.W. campus is the area within our region of interest that is most dangerous to pedestrians.
        "),
      p("
        While this analysis is not necessarily indicative of a relationship between bus stop location and crime ( and moreso just highlights the bus stops that are in the areas with the greatest prevalence of criminal activity ), it may further serve to inform students of where they should, or rather should not, wait to catch the bus if they want to stay safe.
        ")
    )
  )
)

shinyUI(ui)