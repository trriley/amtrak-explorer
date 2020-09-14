# process-gtfs.R
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

# throws a "parsing failures while reading agency error"
amtrak <- read_gtfs("gtfs.zip")
amtrak_sf <- gtfs_as_sf(amtrak)
