# process-gtfs.R
# extracts stop locations and writes output to geoJSON
# written by Tim Riley

# identify necessary packages. use install.packages() if any are missing
packages <- c(
  "sf",
  "tidytransit",
  "tidyverse",
  "here",
  "jsonlite"
)

# load packages
invisible(lapply(packages, library, character.only = TRUE))

# throws a "parsing failures while reading agency" error,
# should not significantly impact output
amtrak <- read_gtfs("./data/transitland/amtrak.zip")
if(!dir.exists(travelTimesDir <- here("data", "tts"))) {
  dir.create(travelTimesDir)
}

departureDate <- "2018-09-04" 
departureTime <- "00:00:00"
maxArrivalTime <- "96:00:00"
stopTimes <- filter_stop_times(amtrak, departureDate, departureTime, maxArrivalTime)
# stopName <- "Chicago Union Station Amtrak"
stopNames <- amtrak$stops$stop_name

for(stopName in stopNames) {
  tts <- travel_times(stopTimes, stopName, 86400) %>%
    select(from_stop_id, to_stop_id, travel_time)
  stopID <- filter(amtrak$stops, stop_name == stopName)[[1,1]]
  fileName <- paste0(travelTimesDir, "/", stopID, ".json")
  tts %>%
    toJSON("columns") %>%
    write_json(fileName)
}