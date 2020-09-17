# process-gtfs.R
# extracts stop locations and writes output to geoJSON
# written by Tim Riley

# identify necessary packages. use install.packages() if any are missing
packages <- c(
  "sf",
  "tidytransit",
  "tidyverse",
  "here"
)

# load packages
invisible(lapply(packages, library, character.only = TRUE))

# throws a "parsing failures while reading agency" error,
# should not significantly impact output
amtrak <- read_gtfs("./data/transitland/amtrak.zip")
departureDate <- "2018-09-04" 
departureTime <- "06:00:00"
maxArrivalTime <- "96:00:00"
stopTimes <- filter_stop_times(amtrak, departureDate, departureTime, maxArrivalTime)
stopName <- "Chicago Union Station Amtrak"
travel_times(stopTimes, stopName, 36000)
