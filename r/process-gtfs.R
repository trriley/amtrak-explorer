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
amtrak <- read_gtfs("./data/amtrak.zip")
amtrakStops <- stops_as_sf(amtrak$stops) %>%
  write_sf("./data/stops.geojson")