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
set.seed(44) # For clustering
seattle = get_map(location = c(here_long, here_lat), zoom = 13, maptype = 'roadmap')

data <- read.csv('../maps-api-test/2016-2017-Clean.csv', header = TRUE)
data <- filter(data, !str_detect(Event.Clearance.Description, "HARBOR - DEBRIS, NAVIGATIONAL HAZARDS"))
TimeChart.one <- ggmap(seattle) +
  geom_point(data = data, aes(x = Longitude, y = Latitude), colour = "red", alpha = 0.75)

#check frequency by month
by.month <- table(data$event_clearance_month)
TimeChart.two <- ggplot(as.data.frame(by.month), 
       aes(x = Var1, y = Freq)) +
  geom_bar(stat = 'identity') +
  labs(title = 'Crimes Reported In U-District, Nov. 2016 - Oct. 2017') +
  xlab('Month') +
  ylab('Number of Crimes Reported')

kruskal <- kruskal.test(Freq ~ Var1, by.month)

freq_by_desc <- table(droplevels(data$Event.Clearance.Description))

TimeChart.three <- ggplot(as.data.frame(freq_by_desc), 
       aes(x = Var1, y = Freq)) +
  geom_bar(stat = 'identity') +
  xlab('Number of Crimes') +
  ylab('Crime Description') +
  coord_flip()

#some useful functions for performing clustering

#extract the lat and long from a dataframe, and run kmeans on it
# x = one of our dataframes
# clusters = how many centers you want kmeans to work with when clustering
fit.clusters <- function(x, clusters) {
  # selecting just ID and location data
  df_loc <- x %>% dplyr::select(CAD.CDW.ID, Latitude, Longitude)
  
  # fitting model
  fit <- kmeans(df_loc, clusters)
  fit$centers # look at cluster sizes and means. want clusters to be about equal size
  return(fit)
}

#make a plot that will tell you how many clusters might work for a given dataframe
# x = a dataframe
# max = the maximum number of clusters you want to try
find.num.clusters <- function(x, max) {
  if(max > nrow(x)) { stop('Cannot fit more clusters than there are rows in dataframe')}
  df_loc <- x %>% dplyr::select(CAD.CDW.ID, Latitude, Longitude)
  wss = c()
  for (i in 1:max) {
    wss[i] <- sum(kmeans(df_loc, centers=i)$withinss)
  }
  plot(1:max, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}

#plot the number of observations in each cluster
# x = a fit object returned from kmeans() or the fit.clusters() function above
plot.cluster.sizes <- function(x) {
  cluster.size <- data.frame(data.frame('clusters' = 1:nrow(x$centers), x$size))
  ggplot(data = cluster.size, aes(x = clusters, y = x.size)) +
    geom_bar(stat = 'identity')
}

morning <- filter(data, 6 <= at_scene_time_hr, at_scene_time_hr < 10 )
mid.day <-  filter(data, 10 <= at_scene_time_hr, at_scene_time_hr < 14 )
afternoon <-  filter(data, 14 <= at_scene_time_hr, at_scene_time_hr < 18 )
evening <-  filter(data, 18 <= at_scene_time_hr, at_scene_time_hr < 22 )
night <-  filter(data, 22 <= at_scene_time_hr | at_scene_time_hr < 2 )
early.morning <-  filter(data, 2 <= at_scene_time_hr, at_scene_time_hr < 6 )

TimeChart.four <- function(time.of.day) { # Horrendously inefficient, but works
  if(time.of.day == "Morning") {
    current.plot <- ggmap(seattle) +
    geom_point(data = morning, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
    labs(title = 'Morning')
  }
  else if(time.of.day == "Mid Day") {
    current.plot <- ggmap(seattle) +
      geom_point(data = mid.day, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Mid Day')
  }
  else if(time.of.day == "Afternoon") {
    current.plot <- ggmap(seattle) +
      geom_point(data = afternoon, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Afternoon')
  }
  else if(time.of.day == "Evening") {
    current.plot <- ggmap(seattle) +
      geom_point(data = evening, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Evening')
  }
  else if(time.of.day == "Night") {
    current.plot <- ggmap(seattle) +
      geom_point(data = night, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Night')
  }
  else{ # Only one option left, early morning
    current.plot <- ggmap(seattle) +
      geom_point(data = early.morning, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Early Morning')
  }
  return(current.plot)
}

lengths <- c(nrow(morning), nrow(mid.day), nrow(afternoon), nrow(evening), nrow(night), nrow(early.morning))
names <- c('Morning\n6:00 - 9:59', 'Mid-day\n10:00 - 1:59', 'Afternoon\n2:00 - 5:59', 'Evening\n6:00 - 9:59', 'Night\n10:00 - 1:59', 'Early Morning\n2:00 - 5:59')
by.tod <- data.frame('TOD' = names, 'Count.Crimes' = lengths)
by.tod$TOD = factor(by.tod$TOD, levels = by.tod$TOD)

TimeChart.five <- ggplot(by.tod, aes(x = TOD, y = Count.Crimes)) +
  geom_histogram(stat = 'identity')

TimeChart.six.a <- function(time.of.day) {
  if(time.of.day == "Morning") {
    fit <- fit.clusters(morning, 10)
  }
  else if(time.of.day == "Mid Day") {
    fit <- fit.clusters(mid.day, 10)
  }
  else if(time.of.day == "Afternoon") {
    fit <- fit.clusters(afternoon, 10)
  }
  else if(time.of.day == "Evening") {
    fit <- fit.clusters(evening, 10)
  }
  else if(time.of.day == "Night") {
    fit <- fit.clusters(night, 10)
  }
  else { # Must be early morning
    fit <- fit.clusters(early.morning, 10)
  }
  current.plot <- ggmap(seattle) +
    geom_point(data = as.data.frame(fit$centers), aes(x = Longitude, y = Latitude), alpha = 0.5) +
    labs(title = time.of.day)
  return(current.plot)
}

TimeChart.six.b <- function(time.of.day) {
  if(time.of.day == "Morning") {
    fit <- fit.clusters(morning, 10)
  }
  else if(time.of.day == "Mid Day") {
    fit <- fit.clusters(mid.day, 10)
  }
  else if(time.of.day == "Afternoon") {
    fit <- fit.clusters(afternoon, 10)
  }
  else if(time.of.day == "Evening") {
    fit <- fit.clusters(evening, 10)
  }
  else if(time.of.day == "Night") {
    fit <- fit.clusters(night, 10)
  }
  else { # Must be early morning
    fit <- fit.clusters(early.morning, 10)
  }
  current.plot <- plot.cluster.sizes(fit)
  return(current.plot)
}

TimeChart.seven.a <- function(time.of.day) {
  if(time.of.day == "Morning") {
    current.plot <- ggmap(seattle) +
      geom_point(data = morning.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Morning')
  }
  else if(time.of.day == "Mid Day") {
    current.plot <- ggmap(seattle) +
      geom_point(data = mid.day.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Mid Day')
  }
  else if(time.of.day == "Afternoon") {
    current.plot <- ggmap(seattle) +
      geom_point(data = afternoon.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Afternoon')
  }
  else if(time.of.day == "Evening") {
    current.plot <- ggmap(seattle) +
      geom_point(data = evening.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Evening')
  }
  else if(time.of.day == "Night") {
    current.plot <- ggmap(seattle) +
      geom_point(data = night.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Night')
  }
  else{ # Only one option left, early morning
    current.plot <- ggmap(seattle) +
      geom_point(data = early.morning.filtered, aes(x = Longitude, y = Latitude), alpha = 0.5) + 
      labs(title = 'Early Morning')
  }
  return(current.plot)
}

TimeChart.seven.b <- ggplot(by.tod.two, aes(x = TOD, y = Count.Crimes)) +
  geom_histogram(stat = 'identity')

TimeChart.seven.c <- function(time.of.day) {
  if(time.of.day == "Morning") {
    fit <- fit.clusters(morning, 10)
  }
  else if(time.of.day == "Mid Day") {
    fit <- fit.clusters(mid.day, 10)
  }
  else if(time.of.day == "Afternoon") {
    fit <- fit.clusters(afternoon, 10)
  }
  else if(time.of.day == "Evening") {
    fit <- fit.clusters(evening, 10)
  }
  else if(time.of.day == "Night") {
    fit <- fit.clusters(night, 10)
  }
  else { # Must be early morning
    fit <- fit.clusters(early.morning, 10)
  }
  current.plot <- ggmap(seattle) +
    geom_point(data = as.data.frame(fit$centers), aes(x = Longitude, y = Latitude), alpha = 0.5) +
    labs(title = time.of.day)
  return(current.plot)
}

TimeChart.seven.d <- function(time.of.day) {
  if(time.of.day == "Morning") {
    fit <- fit.clusters(morning.filtered, 10)
  }
  else if(time.of.day == "Mid Day") {
    fit <- fit.clusters(mid.day.filtered, 10)
  }
  else if(time.of.day == "Afternoon") {
    fit <- fit.clusters(afternoon.filtered, 10)
  }
  else if(time.of.day == "Evening") {
    fit <- fit.clusters(evening.filtered, 10)
  }
  else if(time.of.day == "Night") {
    fit <- fit.clusters(night.filtered, 10)
  }
  else { # Must be early morning
    fit <- fit.clusters(early.morning.filtered, 10)
  }
  current.plot <- plot.cluster.sizes(fit)
  return(current.plot)
}
 #take out general crisis complaint - general
 data.filtered <- filter(data, Event.Clearance.Description != 'CRISIS COMPLAINT - GENERAL')

 morning.filtered <- filter(data.filtered, 6 <= at_scene_time_hr, at_scene_time_hr < 10 )
 mid.day.filtered <-  filter(data.filtered, 10 <= at_scene_time_hr, at_scene_time_hr < 14 )
 afternoon.filtered <-  filter(data.filtered, 14 <= at_scene_time_hr, at_scene_time_hr < 18 )
 evening.filtered <-  filter(data.filtered, 18 <= at_scene_time_hr, at_scene_time_hr < 22 )
 night.filtered <-  filter(data.filtered, 22 <= at_scene_time_hr | at_scene_time_hr < 2 )
 early.morning.filtered <-  filter(data.filtered, 2 <= at_scene_time_hr, at_scene_time_hr < 6 )

 lengths.two <- c(nrow(morning.filtered), nrow(mid.day.filtered), nrow(afternoon.filtered), nrow(evening.filtered), nrow(night.filtered), nrow(early.morning.filtered))
 names.two <- c('Morning\n6:00 - 9:59', 'Mid-day\n10:00 - 1:59', 'Afternoon\n2:00 - 5:59', 'Evening\n6:00 - 9:59', 'Night\n10:00 - 1:59', 'Early Morning\n2:00 - 5:59')
 by.tod.two <- data.frame('TOD' = names, 'Count.Crimes' = lengths)
 by.tod.two$TOD = factor(by.tod$TOD, levels = by.tod$TOD)

#  # find the mode of numeric/character data
#  Mode <- function(x) {
#    ux <- unique(x)
#    tab <- tabulate(match(x, ux)); ux[tab == max(tab)]
#  }
# 
#  tod.mean <- mean(data.filtered$at_scene_time_hr)
#  tod.med <- median(data.filtered$at_scene_time_hr)
#  Mode(data.filtered$at_scene_time_hr)
# 
# #What is the most common crime committed at each period?
#  Mode(morning.filtered$Event.Clearance.Description)
#  Mode(mid.day.filtered$Event.Clearance.Description)
#  Mode(afternoon.filtered$Event.Clearance.Description)
#  Mode(evening.filtered$Event.Clearance.Description)
#  Mode(night.filtered$Event.Clearance.Description)
#  Mode(early.morning.filtered$Event.Clearance.Description)