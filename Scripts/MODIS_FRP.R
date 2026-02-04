# --- Daily fire spread from local MODIS rasters (Dava fire) -------------------
# Handles either:
#  A) EE "first fire date" raster (values = YYYYMMDD), or
#  B) Daily binary masks (one .tif per day; date in filename)
# Produces daily cumulative and incremental footprints + a styled map.
# ------------------------------------------------------------------------------

library(terra)
library(sf)
library(dplyr)
library(stringr)
library(lubridate)
library(ggplot2)
library(ggspatial)
library(grid)        # unit()
library(concaveman)  # optional (not used by default)

# --- Inputs -------------------------------------------------------------------
modis_dir <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/MODIS"
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"

# CRS for processing (metres). UTM 30N works well around Dava
crs_m <- 32630  # EPSG:32630

# Optional: buffer around the perimeter to catch edge pixels
buffer_m <- 1000  # 1 km

# --- Perimeter ----------------------------------------------------------------
stopifnot(file.exists(perim_shp))
perim_ll <- sf::st_read(perim_shp, quiet = TRUE)
perim_m  <- sf::st_transform(perim_ll, crs_m)
perim_buf_m <- sf::st_buffer(perim_m, dist = buffer_m)

# --- Helper: turn a binary (1/0) SpatRaster into a single dissolved polygon ---
raster_to_poly <- function(r_bin) {
  if (is.null(r_bin)) return(NULL)
  # keep 1s only
  r1 <- terra::ifel(r_bin == 1, 1, NA)
  if (is.null(r1)) return(NULL)
  # vectorise (dissolve contiguous)
  poly <- try(terra::as.polygons(r1, dissolve = TRUE), silent = TRUE)
  if (inherits(poly, "try-error") || is.null(poly)) return(NULL)
  if (terra::ncell(r1) == 0) return(NULL)
  poly <- sf::st_as_sf(poly)
  if (nrow(poly) == 0) return(NULL)
  # clip to buffered perimeter
  poly <- suppressWarnings(sf::st_intersection(sf::st_make_valid(poly), perim_buf_m))
  if (nrow(poly) == 0) return(NULL)
  sf::st_make_valid(poly)
}

# --- Detect what you have in modis_dir ----------------------------------------
tifs <- list.files(modis_dir, pattern = "\\.tif(f)?$", full.names = TRUE, ignore.case = TRUE)

if (!length(tifs)) stop("No GeoTIFFs found in: ", modis_dir)

# Try to find a single "first fire date" raster
first_fire_path <- tifs[grepl("first", basename(tifs), ignore.case = TRUE)]
use_first_fire  <- length(first_fire_path) >= 1

message("Detected ", length(tifs), " GeoTIFF(s). ",
        if (use_first_fire) "Using FIRST-FIRE raster route." else "Using DAILY-MASKS route.")

# --- Route A: FIRST-FIRE raster (values = YYYYMMDD) ---------------------------
if (use_first_fire) {
  
  r0 <- terra::rast(first_fire_path[1])
  # Reproject to metres and clip to buffer
  if (!terra::same.crs(r0, perim_m)) {
    r0 <- terra::project(r0, paste0("EPSG:", crs_m), method = "near")
  }
  r0 <- terra::crop(r0, terra::vect(perim_buf_m), snap = "out")
  r0 <- terra::mask(r0, terra::vect(perim_buf_m))
  
  # Pull unique valid "dates" (YYYYMMDD) in the area
  vals <- terra::values(r0, na.rm = TRUE)
  vals <- vals[is.finite(vals)]
  # Keep only plausible YYYYMMDD integers (to avoid nonsense)
  vals <- vals[vals >= 20000101 & vals <= 21000101]
  date_uniq <- sort(unique(as.integer(vals)))
  if (!length(date_uniq)) stop("No valid YYYYMMDD values found in the first-fire raster within the perimeter buffer.")
  
  # Build per-day polygons from equality masks, then cumulative & increments
  daily_list <- vector("list", length(date_uniq))
  for (i in seq_along(date_uniq)) {
    d <- date_uniq[i]
    d_date <- as.Date(as.character(d), format = "%Y%m%d")
    mask_d <- r0 == d
    # convert to binary (1/NA) and polygonise
    r_bin  <- terra::ifel(mask_d, 1, NA)
    poly_d <- raster_to_poly(r_bin)
    if (is.null(poly_d)) next
    poly_d$date <- d_date
    daily_list[[i]] <- poly_d[, "date"]
  }
  daily_polys <- do.call(rbind, daily_list)
  if (is.null(daily_polys) || nrow(daily_polys) == 0) stop("No daily polygons could be built.")
  
} else {
  # --- Route B: DAILY MASKS (one file per day; date in filename) ----------------
  
  # Try to parse YYYYMMDD from filenames
  get_date_from_name <- function(f) {
    s <- basename(f)
    m <- str_extract(s, "(?<!\\d)(20\\d{6})(?!\\d)")  # first 8-digit block starting with 20
    if (is.na(m)) return(NA)
    tryCatch(as.Date(m, format = "%Y%m%d"), error = function(e) NA)
  }
  
  df_files <- tibble::tibble(path = tifs) |>
    dplyr::mutate(date = vapply(path, get_date_from_name, as.Date(NA))) |>
    dplyr::filter(!is.na(date)) |>
    dplyr::arrange(date)
  
  if (!nrow(df_files)) stop("None of the .tif filenames contained a parsable YYYYMMDD date.")
  
  # Build per-day polygons from each mask
  daily_list <- vector("list", nrow(df_files))
  for (i in seq_len(nrow(df_files))) {
    f  <- df_files$path[i]
    dd <- df_files$date[i]
    r  <- terra::rast(f)
    # Reproject, clip, mask
    if (!terra::same.crs(r, perim_m)) {
      r <- terra::project(r, paste0("EPSG:", crs_m), method = "near")
    }
    r <- terra::crop(r, terra::vect(perim_buf_m), snap = "out")
    r <- terra::mask(r, terra::vect(perim_buf_m))
    # Assume non-zero = fire. Coerce to binary 1/NA
    r_bin <- terra::ifel(r != 0, 1, NA)
    poly_d <- raster_to_poly(r_bin)
    if (is.null(poly_d)) next
    poly_d$date <- dd
    daily_list[[i]] <- poly_d[, "date"]
  }
  daily_polys <- do.call(rbind, daily_list)
  if (is.null(daily_polys) || nrow(daily_polys) == 0) stop("No daily polygons could be built from the masks.")
}

# --- Tidy & order --------------------------------------------------------------
daily_polys <- sf::st_make_valid(daily_polys) |>
  dplyr::mutate(date = as.Date(date)) |>
  dplyr::arrange(date)

dates_vec <- sort(unique(daily_polys$date))

# --- Build cumulative (union up to day i) and daily increments -----------------
# Helper to ensure single-geometry sfc -> sfg
to_sfg <- function(sfc1) {
  if (sf::st_is_empty(sfc1)) return(sf::st_geometrycollection())
  sf::st_geometry(sfc1)[[1]]
}

cum_sfg <- vector("list", length(dates_vec))
inc_sfg <- vector("list", length(dates_vec))
acc <- NULL
prev <- NULL
for (i in seq_along(dates_vec)) {
  d <- dates_vec[i]
  # union of today's polygons (if multiple).
  today <- daily_polys %>% dplyr::filter(date == d) %>% sf::st_make_valid()
  if (nrow(today) == 0) {
    cum_sfg[[i]] <- to_sfg(sf::st_sfc(sf::st_geometrycollection(), crs = crs_m))
    inc_sfg[[i]] <- to_sfg(sf::st_sfc(sf::st_geometrycollection(), crs = crs_m))
    next
  }
  today_u <- suppressWarnings(sf::st_union(sf::st_geometry(today)))
  acc     <- if (is.null(acc)) today_u else suppressWarnings(sf::st_union(acc, today_u))
  cum_sfg[[i]] <- to_sfg(acc)
  
  # increment = acc - prev
  if (is.null(prev)) {
    inc <- today_u
  } else {
    inc <- suppressWarnings(sf::st_difference(acc, prev))
  }
  # keep polys only
  inc <- sf::st_collection_extract(inc, "POLYGON", warn = FALSE)
  if (length(inc) == 0) {
    inc <- sf::st_sfc(sf::st_geometrycollection(), crs = crs_m)
  }
  inc_sfg[[i]] <- to_sfg(inc)
  prev <- acc
}

daily_cum <- sf::st_sf(date = dates_vec, geometry = sf::st_sfc(cum_sfg, crs = crs_m)) |>
  sf::st_make_valid()
daily_inc <- sf::st_sf(date = dates_vec, geometry = sf::st_sfc(inc_sfg, crs = crs_m)) |>
  sf::st_make_valid() |>
  sf::st_collection_extract("POLYGON", warn = FALSE)

# --- Areas (ha) for sanity check ----------------------------------------------
daily_cum$area_ha <- as.numeric(sf::st_area(daily_cum)) / 1e4
daily_inc$area_ha <- as.numeric(sf::st_area(daily_inc)) / 1e4
print(daily_cum[, c("date","area_ha")])
print(daily_inc[, c("date","area_ha")])

# --- Plot (in metres CRS, like the VIIRS map) ---------------------------------
# Nice discrete palette across dates (light → dark)
date_lab <- format(dates_vec, "%d %b")
daily_inc$date_f <- factor(daily_inc$date, levels = dates_vec, labels = date_lab)

lvls <- levels(daily_inc$date_f)
mycol <- setNames(colorRampPalette(c("#FEE5D9", "#FB6A4A", "#CB181D"))(length(lvls)), lvls)

p_inc <- ggplot() +
  geom_sf(data = daily_inc, aes(fill = date_f),
          colour = "white", linewidth = 0.2, alpha = 0.9) +
  geom_sf(data = perim_m, fill = NA, colour = "black", linewidth = 0.6) +
  scale_fill_manual(values = mycol, name = "New area\nby date", drop = FALSE) +
  coord_sf(crs = sf::st_crs(perim_m)) +
  labs(x = NULL, y = NULL, title = "Daily fire spread increments (MODIS)") +
  theme_bw(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    legend.position      = c(0.03, 0.97),
    legend.justification = c("left", "top"),
    legend.direction     = "vertical",
    legend.background    = element_rect(fill = scales::alpha("white", 0.75), colour = "grey60"),
    legend.key.height    = unit(0.45, "cm"),
    legend.key.width     = unit(0.45, "cm")
  ) +
  annotation_scale(location = "br", width_hint = 0.25,
                   pad_x = unit(0.35, "cm"), pad_y = unit(0.35, "cm")) +
  annotation_north_arrow(location = "br", which_north = "true",
                         style = north_arrow_fancy_orienteering,
                         pad_x = unit(0.35, "cm"), pad_y = unit(1.3, "cm"))

p_cum <- ggplot() +
  geom_sf(data = daily_cum, aes(fill = date),
          colour = NA, alpha = 0.7) +
  geom_sf(data = perim_m, fill = NA, colour = "black", linewidth = 0.6) +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Cumulative\nfootprint",
                       labels = function(x) format(as.Date(x, origin="1970-01-01"), "%d %b")) +
  coord_sf(crs = sf::st_crs(perim_m)) +
  labs(x = NULL, y = NULL, title = "Daily fire spread (cumulative MODIS footprint)") +
  theme_classic(base_size = 11) +
  theme(panel.grid = element_blank())

print(p_inc)
print(p_cum)

# --- Optional: save & export ---------------------------------------------------
out_dir <- file.path(modis_dir, "outputs")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

ggsave(file.path(out_dir, "modis_daily_spread_increments.png"), p_inc, width = 9, height = 7, dpi = 300)
ggsave(file.path(out_dir, "modis_daily_spread_cumulative.png"), p_cum, width = 9, height = 7, dpi = 300)

# Write a GeoPackage with both layers
gpkg_path <- file.path(out_dir, "modis_daily_spread.gpkg")
sf::st_write(daily_cum, gpkg_path, layer = "cumulative", delete_dsn = TRUE, quiet = TRUE)
sf::st_write(daily_inc, gpkg_path, layer = "increments", append = TRUE, quiet = TRUE)

message("Done. Outputs in: ", out_dir)
