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
data <- filter(data, Event.Clearance.Description != 'CRISIS COMPLAINT - GENERAL') # filtering out data that is under the Crisis Complaint Description
data <- filter(data, time_until_event_clear > 20000) # filtering out data that takes 20000 minutes or under to clear

clearance_codes <- factor(data$Event.Clearance.Code)
# plotting the scatter plot with distance from Red Square and clearance times
clearanceChart.one <- ggplot(data) +
  geom_point(aes(x = data$dist, y = data$time_until_event_clear, colour = clearance_codes), stat = 'identity') +
  xlab('Distance from Red Square (Meters)') +
  ylab('Clearance Time (Minutes)') 

data <- filter(data, Event.Clearance.Code != 350) # filtering out hazards

# recreating the buckets of data for specific times of day
morning <- filter(data, 6 <= at_scene_time_hr, at_scene_time_hr < 10 )
mid.day <-  filter(data, 10 <= at_scene_time_hr, at_scene_time_hr < 14 )
afternoon <-  filter(data, 14 <= at_scene_time_hr, at_scene_time_hr < 18 )
evening <-  filter(data, 18 <= at_scene_time_hr, at_scene_time_hr < 22 )
night <-  filter(data, 22 <= at_scene_time_hr | at_scene_time_hr < 2 )
early.morning <-  filter(data, 2 <= at_scene_time_hr, at_scene_time_hr < 6 )

# Clustering functions based on clearance time
fit.clusters <- function(x, clusters) {
  # selecting just ID and location data
  df_loc <- x %>% dplyr::select(CAD.CDW.ID, time_until_event_clear)
  
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
  df_loc <- x %>% dplyr::select(CAD.CDW.ID, time_until_event_clear)
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

# Let's see if time of day has an effect on clearance times.

clearanceChart.two <- function(time.of.day) {
  if (time.of.day == "Early Morning") {
    current.plot <- ggmap(seattle) + 
      geom_point(data = early.morning, aes(x = Longitude, y = Latitude, colour = early.morning$time_until_event_clear)) +
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Early Morning")
  }
  else if (time.of.day == "Morning") {
    current.plot <- ggmap(seattle) +
      geom_point(data = morning, aes(x = Longitude, y = Latitude, colour = morning$time_until_event_clear)) + 
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Morning")
  }
  else if (time.of.day == "Mid Day") {
    current.plot <- ggmap(seattle) + 
      geom_point(data = mid.day, aes(x = Longitude, y = Latitude, colour = mid.day$time_until_event_clear)) + 
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Mid Day")
  }
  else if (time.of.day == "Afternoon") {
    current.plot <- ggmap(seattle) + 
      geom_point(data = afternoon, aes(x = Longitude, y = Latitude, colour = afternoon$time_until_event_clear)) +
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Afternoon")
  }
  else if (time.of.day == "Evening") {
    current.plot <- ggmap(seattle) + 
      geom_point(data = evening, aes(x = Longitude, y = Latitude, colour = evening$time_until_event_clear)) +
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Evening")
  }
  else {
    current.plot <- ggmap(seattle) + 
      geom_point(data = night, aes(x = Longitude, y = Latitude, colour = night$time_until_event_clear)) +
      scale_colour_gradient(low = "blue", high = "red") + 
      labs(title = "Night")
  }
  return(current.plot)
}

# attempting to cluster all of the data based on clearance times
fit <- fit.clusters(data, 10)
cluster.crimes <- filter(data, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) +     scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

#now, attempting to cluster the data in terms of time of day
fit <- fit.clusters(morning, 1)
cluster.crimes <- filter(morning, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = as.data.frame(cluster.crimes), aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) +     scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

fit <- fit.clusters(mid.day, 10)
cluster.crimes <- filter(mid.day, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) +
  scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

fit <- fit.clusters(afternoon, 1)
cluster.crimes <- filter(afternoon, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) + 
  scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

fit <- fit.clusters(evening, 5)
cluster.crimes <- filter(evening, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) + 
  scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

fit <- fit.clusters(night, 1)
cluster.crimes <- filter(night, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) + 
  scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

fit <- fit.clusters(early.morning, 1)
cluster.crimes <- filter(early.morning, CAD.CDW.ID %in% fit$centers[1:nrow(fit$centers)])
ggmap(seattle) +
  geom_point(data = cluster.crimes, aes(x = Longitude, y = Latitude, colour = time_until_event_clear), alpha = 0.5) + 
  scale_colour_gradient(low = "blue", high = "red")
plot.cluster.sizes(fit)

