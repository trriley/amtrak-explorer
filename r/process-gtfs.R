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
gtfsFile <- paste(here("data", "transitland"), "amtrak.zip", sep = "/")
amtrak <- read_gtfs(gtfsFile)
if(!dir.exists(travelTimesDir <- here("data", "tts"))) {
  dir.create(travelTimesDir)
}
fileName <- paste(travelTimesDir, "tts.json", sep = "/")

departureDate <- "2018-09-04" 
departureTime <- "00:00:00"
maxArrivalTime <- "96:00:00"
stopTimes <- filter_stop_times(amtrak, departureDate, departureTime, maxArrivalTime)
# stopName <- "Chicago Union Station Amtrak"
stopNames <- amtrak$stops$stop_name

tts <- map_dfr(
  stopNames,
  ~ travel_times(stopTimes, stop_name = .x, 86400) %>%
    select(from_stop_id, to_stop_id, travel_time)
)
ttsJSON <- tts %>%
  toJSON("columns")

write_json(ttsJSON, fileName)
