library(ncdf4)
library(dplyr)
library(sf)
library(terra)

# Load fire perimeter
fire_perim <- st_read("C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp")
fire_perim <- st_transform(fire_perim, crs = 4326)  # VIIRS is in lat/lon (EPSG:4326)

# Function to extract and crop FRP points from a .nc file

# Transform to UTM zone 30N
fire_perim_m <- st_transform(fire_perim, 32630)

# Buffer by 1 km
fire_perim_buffered <- st_buffer(fire_perim_m, dist = 1000)

# Transform back to WGS84 for VIIRS points
fire_perim_buffered <- st_transform(fire_perim_buffered, 4326)




process_viirs_nc <- function(nc_path) {
  library(ncdf4)
  library(dplyr)
  library(sf)
  
  nc <- nc_open(nc_path)
  
  result <- tryCatch({
    # Extract key variables
    lat <- ncvar_get(nc, "FP_latitude")
    lon <- ncvar_get(nc, "FP_longitude")
    frp <- ncvar_get(nc, "FP_power")
    nc_close(nc)
    
    # Skip empty files
    if (length(frp) == 0 || all(is.na(frp))) {
      message(basename(nc_path), ": No FRP data.")
      return(NULL)
    }
    
    # Extract date from filename (e.g. A2025173 → 2025-06-21)
    filename <- basename(nc_path)
    match <- regmatches(filename, regexpr("A\\d{7}", filename))
    date_string <- sub("A", "", match)
    year <- as.integer(substr(date_string, 1, 4))
    doy  <- as.integer(substr(date_string, 5, 7))
    date <- as.Date(paste0(year, "-01-01")) + doy - 1
    
    # Assemble data frame and filter valid FRP points
    df <- data.frame(lon = lon, lat = lat, frp = frp, date = date) %>%
      filter(!is.na(frp) & frp > 0)
    
    message(date, ": ", nrow(df), " detections before perimeter filter")
    
    if (nrow(df) == 0) return(NULL)
    
    # Convert to sf points
    sf_points <- st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
    
    # Check how many intersect fire perimeter
    #inside_fire <- st_within(sf_points, fire_perim, sparse = FALSE) # unbuffered
    inside_fire <- st_within(sf_points, fire_perim_buffered, sparse = FALSE) # buffered
    message(date, ": ", sum(inside_fire), " detections inside perimeter")
    
    # Filter to points within perimeter
    sf_points_in_fire <- sf_points[inside_fire, ]
    
    # Return empty sf if no detections in fire area
    if (nrow(sf_points_in_fire) == 0) {
      return(st_sf(frp = numeric(0), date = as.Date(character()), geometry = st_sfc(crs = 4326)))
    }
    
    return(sf_points_in_fire)
  },
  error = function(e) {
    message("Failed to process ", basename(nc_path), ": ", e$message)
    nc_close(nc)
    return(st_sf(frp = numeric(0), date = as.Date(character()), geometry = st_sfc(crs = 4326)))
  })
  
  return(result)
}




# Folder of VIIRS .nc files
viirs_folder <- "C:/Users/jscho/Documents/Scotland Megafire/VIIRS_images"
viirs_files <- list.files(viirs_folder, pattern = "\\.nc$", full.names = TRUE)

# Process all files and combine into one sf object
library(purrr)
all_points <- map_dfr(viirs_files, process_viirs_nc)


library(ggplot2)

ggplot(all_points) +
  geom_sf(data = fire_perim, fill = NA, color = "black") +
  geom_sf(aes(color = frp), size = 2) +
  scale_color_viridis_c(option = "inferno", name = "FRP (MW)") +
  facet_wrap(~ date) +
  theme_minimal() +
  labs(title = "VIIRS fire radiative power (megawatts) by date")


# Log transformed color scale

ggplot(all_points) +
  geom_sf(data = fire_perim, fill = NA, color = "black") +
  geom_sf(aes(color = frp), size = 2) +
  scale_color_viridis_c(
    option = "inferno",
    name = "FRP (MW)",
    trans = "log10"
  ) +
  facet_wrap(~ date) +
  theme_classic() +
  labs(title = "VIIRS fire radiative power (MW) by date")


library(sf)
library(dplyr)

# Extract coordinates from geometry column and save to CSV
all_points_df <- all_points %>%
  mutate(lon = st_coordinates(.)[,1],
         lat = st_coordinates(.)[,2]) %>%
  st_drop_geometry()

write.csv(all_points_df, "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/viirs_frp_points.csv", row.names = FALSE)







# ----- DAILY FIRE SPREAD (one map) via cumulative concave hulls ---------------
# --- Libraries (no lwgeom needed) ---
library(sf)
library(dplyr)
library(ggplot2)
library(concaveman)

# --- Assumes you already have: all_points (sf POINTs with 'date'), fire_perim (sf POLYGON) ---

# 1) Reproject to metres (UTM 30N) and make a perimeter buffer for cropping
pts_m         <- st_transform(all_points, 32630)
fire_perim_m  <- st_transform(fire_perim, 32630)
fire_buffer_m <- st_buffer(fire_perim_m, dist = 1000)   # 1 km buffer

# 2) Daily concave hulls from POINTS (avoid MULTIPOINT to keep concaveman happy)
dates <- sort(unique(as.Date(pts_m$date)))
daily_hulls_list <- lapply(dates, function(d) {
  pts_day <- pts_m[as.Date(pts_m$date) == d, ]
  
  # drop duplicate coordinates (can trip up hull algorithms)
  pts_day <- pts_day[!duplicated(st_coordinates(pts_day)), ]
  
  if (nrow(pts_day) < 3) return(NULL)
  
  # concave hull from POINTS; fall back to convex hull if needed
  hull <- tryCatch(
    concaveman::concaveman(pts_day, concavity = 2, length_threshold = 0),
    error = function(e) st_convex_hull(st_union(pts_day))
  )
  
  # small smoothing buffer and clip to fire buffer
  hull <- st_buffer(hull, 200)
  hull <- suppressWarnings(st_intersection(hull, fire_buffer_m))
  if (st_is_empty(hull)) return(NULL)
  
  st_sf(date = d, geometry = st_geometry(hull), crs = st_crs(hull))
})

if (length(daily_hulls_list) == 0 || all(sapply(daily_hulls_list, is.null))) {
  stop("No daily hulls created — check inputs.")
}

daily_hulls <- do.call(rbind, daily_hulls_list) |> sf::st_make_valid()
daily_hulls <- daily_hulls[order(daily_hulls$date), ]

# Helper: convert a length-1 sfc to a single sfg, preserving empties
to_sfg <- function(sfc1) {
  if (sf::st_is_empty(sfc1)) return(sf::st_geometrycollection())
  sf::st_geometry(sfc1)[[1]]
}

# 3) CUMULATIVE footprint: union day-by-day, carefully building sfg list
geoms <- daily_hulls$geometry                     # sfc
cum_sfg_list <- vector("list", length(geoms))
acc <- NULL
for (i in seq_along(geoms)) {
  g    <- geoms[i]
  acc  <- if (is.null(acc)) g else sf::st_union(acc, g)  # sfc length 1
  cum_sfg_list[[i]] <- to_sfg(acc)                       # sfg
}
cum_sfc <- sf::st_sfc(cum_sfg_list, crs = sf::st_crs(daily_hulls))
daily_cum <- sf::st_sf(date = daily_hulls$date, geometry = cum_sfc) |>
  sf::st_make_valid()

# 4) DAILY INCREMENTS: today minus yesterday, again building sfgs safely
inc_sfg_list <- vector("list", length(cum_sfc))
prev <- NULL
for (i in seq_along(cum_sfc)) {
  cur <- cum_sfc[i]
  sfc_res <- if (is.null(prev)) cur else sf::st_difference(cur, prev)  # sfc len 1
  inc_sfg_list[[i]] <- to_sfg(sfc_res)                                 # sfg
  prev <- cur
}
inc_sfc <- sf::st_sfc(inc_sfg_list, crs = sf::st_crs(daily_cum))
daily_inc <- sf::st_sf(date = daily_cum$date, geometry = inc_sfc) |>
  sf::st_make_valid() |>
  # keep polygons only; drop lines/points/empties
  sf::st_collection_extract("POLYGON", warn = FALSE)

# 5) Quick QA: areas (ha)
daily_cum$area_ha <- as.numeric(sf::st_area(daily_cum)) / 1e4
daily_inc$area_ha <- as.numeric(sf::st_area(daily_inc)) / 1e4
print(head(daily_cum[, c("date","area_ha")]))
print(head(daily_inc[, c("date","area_ha")]))   # may be 0/empty for some days

# 6) Plots — single map each
labels_date <- function(x) format(as.Date(x, origin = "1970-01-01"), "%d %b")

p_cum <- ggplot() +
  geom_sf(data = daily_cum, aes(fill = date), colour = NA, alpha = 0.7) +
  geom_sf(data = fire_perim_m, fill = NA, colour = "black", linewidth = 0.6) +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Cumulative\nfootprint",
                       labels = labels_date) +
  coord_sf(crs = sf::st_crs(fire_perim_m)) +
  labs(title = "Daily fire spread (cumulative VIIRS footprint)", x = NULL, y = NULL) +
  theme_classic(base_size = 11) + theme(panel.grid = element_blank())

p_inc <- ggplot() +
  geom_sf(data = daily_inc, aes(fill = date), colour = "white", linewidth = 0.2, alpha = 0.9) +
  geom_sf(data = fire_perim_m, fill = NA, colour = "black", linewidth = 0.6) +
  scale_fill_viridis_c(option = "mako", direction = -1,
                       name = "New area\nby date",
                       labels = labels_date) +
  coord_sf(crs = sf::st_crs(fire_perim_m)) +
  labs(title = "Daily fire spread increments (VIIRS)", x = NULL, y = NULL) +
  theme_classic(base_size = 11) + theme(panel.grid = element_blank())


# Discrete colour palette for three dates
# Build a labeled factor for the dates (ordered + pretty labels)
dates_vec <- sort(unique(daily_inc$date))
daily_inc$date_f <- factor(daily_inc$date,
                           levels = dates_vec,
                           labels = format(dates_vec, "%d %b"))

# add once at top if not loaded
library(ggspatial)
library(grid)  # for unit()

lvls  <- levels(daily_inc$date_f)
mycol <- setNames(
  c("#FEE5D9", "#FB6A4A", "#CB181D")[seq_along(lvls)],  # light, medium, dark red
  lvls
)

p_inc <- ggplot() +
  geom_sf(data = daily_inc, aes(fill = date_f),
          colour = "white", linewidth = 0.2, alpha = 0.9) +
  geom_sf(data = fire_perim_m, fill = NA, colour = "black", linewidth = 0.01) +
  scale_fill_manual(values = mycol, name = "Fire spread\nby date", drop = FALSE) +
  coord_sf(crs = sf::st_crs(fire_perim_m)) +
  labs(title = "", x = NULL, y = NULL) +
  theme_bw(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    # --- Legend in top-left, inside the panel ---
    legend.position      = c(0.03, 0.97),              # (x, y) in NPC coords
    legend.justification = c("left", "top"),
    legend.direction     = "vertical",
    # nice readable box
    legend.background    = element_rect(fill = scales::alpha("white", 0.75),
                                        colour = "grey60"),
    legend.title         = element_text(), #face = "bold"
    legend.key.height    = unit(0.45, "cm"),
    legend.key.width     = unit(0.45, "cm")
  ) +
  # Scale bar & north arrow (bottom-right)
  annotation_scale(location = "br", width_hint = 0.25,
                   pad_x = unit(0.35, "cm"), pad_y = unit(0.35, "cm")) +
  annotation_north_arrow(location = "br", which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         pad_x = unit(0.35, "cm"), pad_y = unit(1.3, "cm"))

print(p_inc)




print(p_cum)
print(p_inc)

# 7) (Optional) Save outputs
out_dir <- "C:/Users/jscho/Documents/Scotland Megafire"
ggsave(file.path(out_dir, "viirs_daily_spread_cumulative.png"), p_cum, width = 9, height = 7, dpi = 300)
ggsave(file.path(out_dir, "viirs_daily_spread_increments.png"), p_inc, width = 9, height = 7, dpi = 300)

# GeoPackage with both layers (overwrite -> then append)
gpkg_path <- file.path(out_dir, "viirs_daily_spread.gpkg")
sf::st_write(daily_cum, gpkg_path, layer = "cumulative", delete_dsn = TRUE, quiet = TRUE)
sf::st_write(daily_inc, gpkg_path, layer = "increments", append = TRUE, quiet = TRUE)

