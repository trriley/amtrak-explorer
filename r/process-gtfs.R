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
gtfsFile <- here("data", "transitland", "amtrak.zip")
amtrak <- read_gtfs(gtfsFile)
if(!dir.exists(travelTimesDir <- here("data", "tts"))) {
  dir.create(travelTimesDir)
}

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

# we have some stations whose only travel_time entry is for themselves, with a
# value of 0. These aren't terribly useful for our map, so they need to be 
# removed as well
# stationsRemove <- tts %>%
#   group_by(from_stop_id) %>%
#   summarize(count = n()) %>%
#   filter(count == 1)
# 
# ttsRemoved <- tts %>%
#   anti_join(stationsRemove)

# semi-join tts with stops.shp to filter both tables
# (we only want stops.shp to have stations with schedule info, and we only want
# tts.json to have schedule info for stations in stops.shp)
stopsGeo <- here("data", "stops_backup.geojson") %>%
  read_sf() %>%
  semi_join(tts, by = c("STNCODE" = "from_stop_id"))

write_sf(stopsGeo, here("data", "stops.geojson"))

ttsFiltered <- tts %>%
  semi_join(stopsGeo, by = c("from_stop_id" = "STNCODE"))

ttsJSON <- list(
  from_stop_id = ttsFiltered$from_stop_id,
  to_stop_id = ttsFiltered$to_stop_id,
  travel_time = ttsFiltered$travel_time
) %>%
  toJSON()

jsonFile <- paste(travelTimesDir, "tts.json", sep = "/")
# write_json(ttsJSON, jsonFile)
# write_json encodes the data as an array with one element for some insane
# reason, so it is necessary to manually copy/paste the output of >ttsJSON to
# the tts.json file
