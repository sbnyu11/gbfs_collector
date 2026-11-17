library(gbfs)
library(dplyr)
library(readr)

dir <- "data"
dir.create(dir, showWarnings = FALSE)
stamp <- format(Sys.time(), "%Y-%m-%d_%H%M", tz = "America/New_York")

pull <- function(url, provider) {
  tryCatch({
    df <- get_free_bike_status(
      url,
      directory = dir,
      file = paste0(provider, "_status_", stamp, ".rds"),
      output = "both"
    )
    df$Provider  <- provider
    df$pulled_at <- Sys.time()
    df
  }, error = function(e) {
    message(provider, " failed: ", conditionMessage(e))
    NULL
  })
}

Lime_status <- pull("https://data.lime.bike/api/partners/v2/gbfs/atlanta/gbfs.json", "Lime")
Bird_status <- pull("https://mds.bird.co/gbfs/v2/public/atlanta/gbfs.json", "Bird")

Combined_status <- bind_rows(Lime_status, Bird_status)

if (nrow(Combined_status) > 0) {
  write_csv(Combined_status, file.path(dir, paste0("Atlanta_status_", stamp, ".csv")))
}