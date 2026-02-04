# ===========================
# Dava Fire — VIIRS first pixel date (daily pixels) + MODIS last pixel date
# Window: June–July of year_target
# ===========================
library(terra)
library(sf)
library(dplyr)
library(stringr)
library(ncdf4)
library(ggplot2)
library(ggspatial)
library(grid)
library(scales)
library(viridisLite)

# ---------- Inputs ----------
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"
viirs_dir <- "C:/Users/jscho/Documents/Scotland Megafire/VIIRS_images"      # VIIRS .nc
modis_dir <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/MODIS"  # GEE-exported LAST-date GeoTIFF(s)
out_dir   <- file.path(modis_dir, "VIIRS_MODIS_date_pixels")

year_target <- 2025
date_min <- as.Date(sprintf("%d-06-01", year_target))
date_max <- as.Date(sprintf("%d-07-31", year_target))

# UTM 30N working grid (MODIS nearest-neighbour; VIIRS rasterized to this grid)
crs_m  <- 32630
cell_m <- 250
buf_m  <- 1000

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---------- Perimeter & template ----------
perim_ll     <- sf::st_read(perim_shp, quiet = TRUE)
perim_m      <- sf::st_transform(perim_ll, crs_m)
perim_bufm   <- sf::st_buffer(perim_m, buf_m)
perim_buf_ll <- sf::st_transform(perim_bufm, 4326)

# Template raster (UTM)
ext_m <- terra::ext(terra::vect(perim_bufm))
tmpl  <- terra::rast(ext_m, resolution = cell_m, crs = paste0("EPSG:", crs_m))

# ===========================================================
# A) VIIRS: per-day rasters -> FIRST date per pixel
# ===========================================================
read_viirs_points <- function(nc_path) {
  nc <- nc_open(nc_path); on.exit(nc_close(nc), add = TRUE)
  lat <- ncvar_get(nc, "FP_latitude")
  lon <- ncvar_get(nc, "FP_longitude")
  frp <- ncvar_get(nc, "FP_power")
  
  # Parse AYYYYDOY -> Date
  fname <- basename(nc_path)
  m <- regmatches(fname, regexpr("A\\d{7}", fname))
  if (!length(m)) return(NULL)
  ds  <- sub("A", "", m)
  yr  <- as.integer(substr(ds, 1, 4))
  doy <- as.integer(substr(ds, 5, 7))
  d   <- as.Date(paste0(yr, "-01-01")) + doy - 1
  
  if (!length(frp)) return(NULL)
  df <- data.frame(lon = as.vector(lon), lat = as.vector(lat), frp = as.vector(frp))
  df <- df[is.finite(df$frp) & df$frp > 0, , drop = FALSE]
  if (!nrow(df)) return(NULL)
  
  pts <- sf::st_as_sf(df, coords = c("lon","lat"), crs = 4326)
  pts$date <- d
  pts
}

message("Reading VIIRS .nc files...")
viirs_files <- list.files(viirs_dir, pattern = "\\.nc$", full.names = TRUE)
viirs_list  <- lapply(viirs_files, read_viirs_points)
viirs_list  <- Filter(Negate(is.null), viirs_list)

viirs_pts <- if (length(viirs_list)) do.call(rbind, viirs_list) else NULL
if (!is.null(viirs_pts)) {
  viirs_pts <- viirs_pts |> dplyr::filter(date >= date_min & date <= date_max)
  inside <- apply(sf::st_within(viirs_pts, perim_buf_ll, sparse = FALSE), 1, any)
  viirs_pts <- viirs_pts[inside, ]
}

first_viirs_num <- NULL
if (!is.null(viirs_pts) && nrow(viirs_pts) > 0) {
  dates     <- sort(unique(as.Date(viirs_pts$date)))
  date_nums <- as.numeric(dates)
  
  vr_list <- vector("list", length(dates))
  for (i in seq_along(dates)) {
    d      <- dates[i]
    pts_d  <- viirs_pts[viirs_pts$date == d, ]
    if (!nrow(pts_d)) next
    pts_m  <- sf::st_transform(pts_d, crs_m)
    v      <- terra::vect(pts_m)
    r_mask <- terra::rasterize(v, tmpl, field = 1, fun = "max")
    r_val  <- terra::ifel(r_mask == 1, date_nums[i], NA)
    vr_list[[i]] <- r_val
  }
  vr_list <- Filter(Negate(is.null), vr_list)
  
  if (length(vr_list)) {
    viirs_stack <- terra::rast(vr_list)
    # First date per pixel (custom reducer is fine here)
    first_viirs_num <- terra::app(viirs_stack, fun = function(v) {
      v <- v[is.finite(v)]
      if (!length(v)) NA_real_ else min(v)
    })
    first_viirs_num <- terra::mask(first_viirs_num, terra::vect(perim_bufm))
    names(first_viirs_num) <- "first_viirs_num"
  }
}

# ===========================================================
# B) MODIS: LAST pixel date (from GEE export, YYYYMMDD values)
#     - convert per layer (YYYYMMDD -> days)
#     - filter to Jun–Jul
#     - per-pixel MAX across layers = last date
# ===========================================================
all_tifs    <- list.files(modis_dir, pattern = "\\.tif$|\\.tiff$", full.names = TRUE)
modis_files <- grep("last", all_tifs, ignore.case = TRUE, value = TRUE)
if (!length(modis_files)) modis_files <- all_tifs

yyyymmdd_to_days <- function(x) {
  x <- as.numeric(x)
  x[!is.finite(x) | x <= 0] <- NA_real_
  xi <- suppressWarnings(as.integer(round(x)))
  ok <- !is.na(xi) & nchar(xi) %in% c(7, 8)
  ch <- rep(NA_character_, length(xi))
  ch[ok] <- stringr::str_pad(xi[ok], width = 8, pad = "0")
  suppressWarnings(as.numeric(as.Date(ch, format = "%Y%m%d")))
}

last_modis_num <- NULL
if (length(modis_files)) {
  message("Reading MODIS LAST-date GeoTIFF(s)...")
  rlist <- lapply(modis_files, terra::rast)
  r_mos <- if (length(rlist) == 1) rlist[[1]] else do.call(terra::mosaic, rlist)
  
  # Convert YYYYMMDD -> days PER LAYER
  conv_layers <- lapply(seq_len(terra::nlyr(r_mos)), function(i) {
    terra::app(r_mos[[i]], fun = yyyymmdd_to_days)
  })
  r_num <- terra::rast(conv_layers)
  
  # Project to UTM & match grid (NN keeps dates discrete)
  r_num_m <- terra::project(r_num, terra::crs(tmpl), method = "near")
  r_num_m <- terra::resample(r_num_m, tmpl, method = "near")
  
  # Filter to Jun–Jul window
  dn_min <- as.numeric(date_min); dn_max <- as.numeric(date_max)
  ok_rng <- (r_num_m >= dn_min) & (r_num_m <= dn_max)
  r_num_m <- terra::mask(r_num_m, ok_rng)
  
  r_num_m <- terra::mask(r_num_m, terra::vect(perim_bufm))
  
  # >>> FIX: use built-in reducer with na.rm=TRUE <<<
  last_modis_num <- terra::app(r_num_m, fun = "max", na.rm = TRUE)
  names(last_modis_num) <- "last_modis_num"
}

if (is.null(first_viirs_num) && is.null(last_modis_num)) {
  stop("No VIIRS or MODIS detections available for the given period/inputs.")
}

# ===========================================================
# C) Reproject to WGS84, prep data frames, common legend
# ===========================================================
to_ll <- function(r) terra::project(r, "EPSG:4326", method = "near")
viirs_ll <- if (!is.null(first_viirs_num)) to_ll(first_viirs_num) else NULL
modis_ll <- if (!is.null(last_modis_num))  to_ll(last_modis_num)  else NULL

perim_ll_plot <- sf::st_transform(perim_m, 4326)
bb     <- sf::st_bbox(perim_ll_plot)
res_ll <- if (!is.null(viirs_ll)) terra::res(viirs_ll) else terra::res(modis_ll)

df_from_r <- function(r_ll) {
  df <- as.data.frame(r_ll, xy = TRUE, na.rm = TRUE)
  names(df) <- c("lon","lat","date_num")
  df$date <- as.Date(df$date_num, origin = "1970-01-01")
  df
}
df_viirs <- if (!is.null(viirs_ll)) df_from_r(viirs_ll) else NULL
df_modis <- if (!is.null(modis_ll)) df_from_r(modis_ll) else NULL

# Shared legend ticks (weekly)
date_min_plot <- min(c(
  if (!is.null(df_viirs)) min(df_viirs$date, na.rm = TRUE) else Inf,
  if (!is.null(df_modis)) min(df_modis$date, na.rm = TRUE) else Inf
), na.rm = TRUE)

date_max_plot <- max(c(
  if (!is.null(df_viirs)) max(df_viirs$date, na.rm = TRUE) else -Inf,
  if (!is.null(df_modis)) max(df_modis$date, na.rm = TRUE) else -Inf
), na.rm = TRUE)

date_breaks <- seq(date_min_plot, date_max_plot, by = "7 days")
if (length(date_breaks) < 3) date_breaks <- sort(unique(c(date_min_plot, date_max_plot)))
pal_dates <- viridisLite::mako(max(3, length(date_breaks)), direction = -1)

label_lon <- scales::label_number(accuracy = 0.01, suffix = "°")
label_lat <- scales::label_number(accuracy = 0.01, suffix = "°")

map_theme <- theme_bw(base_size = 11) +
  theme(
    panel.grid       = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background  = element_rect(fill = "white", colour = NA),
    legend.position      = c(0.02, 0.06),
    legend.justification = c("left","bottom"),
    legend.background    = element_rect(fill = scales::alpha("white", 0.9), colour = "grey60"),
    legend.box.margin    = margin(3, 4, 3, 4),
    legend.margin        = margin(2, 2, 2, 2)
  )

make_map <- function(df, title, res_ll, bb, perim_ll) {
  ggplot() +
    geom_tile(
      data   = df,
      aes(x = lon, y = lat, fill = as.numeric(date)),
      width  = res_ll[1], height = res_ll[2]
    ) +
    geom_sf(data = perim_ll, fill = NA, colour = "black", linewidth = 0.01) +
    scale_fill_gradientn(
      colours = pal_dates,
      breaks  = as.numeric(date_breaks),
      labels  = format(date_breaks, "%d %b"),
      name    = "Date of detection"
    ) +
    coord_sf(
      crs  = sf::st_crs(4326),
      xlim = c(bb["xmin"], bb["xmax"]),
      ylim = c(bb["ymin"], bb["ymax"]),
      expand = FALSE
    ) +
    scale_x_continuous(labels = label_lon, expand = c(0,0)) +
    scale_y_continuous(labels = label_lat, expand = c(0,0)) +
    labs(x = "Longitude (°)", y = "Latitude (°)", title = title) +
    map_theme +
    guides(
      fill = guide_colorbar(
        direction      = "horizontal",
        title.position = "top",
        barwidth       = unit(3.8, "cm"),
        barheight      = unit(0.35, "cm"),
        ticks          = TRUE
      )
    ) +
    ggspatial::annotation_scale(
      location   = "br", width_hint = 0.25,
      pad_x      = unit(0.35, "cm"), pad_y = unit(0.35, "cm"),
      bar_cols   = c("grey90","grey30")
    ) +
    ggspatial::annotation_north_arrow(
      location = "br", style = north_arrow_orienteering,
      pad_x = unit(0.3, "cm"), pad_y = unit(1.2, "cm"),
      height = unit(0.8, "cm"), width = unit(0.6, "cm")
    )
}

p_viirs_first <- if (!is.null(df_viirs)) make_map(df_viirs, "VIIRS — First pixel date (Jun–Jul)", res_ll, bb, perim_ll_plot) else NULL
p_modis_last  <- if (!is.null(df_modis)) make_map(df_modis, "MODIS — Last pixel date (Jun–Jul)",  res_ll, bb, perim_ll_plot) else NULL

if (!is.null(p_viirs_first)) print(p_viirs_first)
if (!is.null(p_modis_last))  print(p_modis_last)

# ---------- Save ----------
if (!is.null(p_viirs_first)) ggsave(file.path(out_dir, "viirs_first_pixel_date.png"), p_viirs_first, width = 9, height = 7, dpi = 300)
if (!is.null(p_modis_last))  ggsave(file.path(out_dir, "modis_last_pixel_date.png"),  p_modis_last,  width = 9, height = 7, dpi = 300)








# ---- C) Composite = earliest of VIIRS-first and MODIS-last -------------------
stopifnot(exists("date_min"), exists("date_max"))

combo_num <- if (exists("first_viirs_num") && exists("last_modis_num") &&
                 !is.null(first_viirs_num) && !is.null(last_modis_num)) {
  terra::mosaic(first_viirs_num, last_modis_num, fun = "min")
} else if (exists("first_viirs_num") && !is.null(first_viirs_num)) {
  first_viirs_num
} else if (exists("last_modis_num") && !is.null(last_modis_num)) {
  last_modis_num
} else {
  stop("No VIIRS or MODIS rasters available.")
}
names(combo_num) <- "combo_first_num"

# ---- D) Clamp strictly to June–July (drop everything else) -------------------
dn_min <- as.numeric(date_min)  # e.g., as.numeric(as.Date("2025-06-01"))
dn_max <- as.numeric(date_max)  # e.g., as.numeric(as.Date("2025-07-31"))

# IMPORTANT: drop outside-window pixels by setting them to NA
combo_num <- terra::ifel(combo_num >= dn_min & combo_num <= dn_max, combo_num, NA_real_)

# (Optional) QC: print min/max remaining dates
rng_num <- terra::global(combo_num, fun = "range", na.rm = TRUE)
print(as.Date(unlist(rng_num), origin = "1970-01-01"))

# ---- E) Reproject to WGS84 and prep discrete per-day palette ----------------
to_ll   <- function(r) terra::project(r, "EPSG:4326", method = "near")
combo_ll <- to_ll(combo_num)

perim_ll_plot <- if (exists("perim_m")) sf::st_transform(perim_m, 4326) else {
  stopifnot(exists("perim_shp"))
  sf::st_transform(sf::st_read(perim_shp, quiet = TRUE), 4326)
}

bb     <- sf::st_bbox(perim_ll_plot)
res_ll <- terra::res(combo_ll)

df_combo <- as.data.frame(combo_ll, xy = TRUE, na.rm = TRUE)
if (!nrow(df_combo)) stop("No composite pixels fall within June–July after clamping.")
names(df_combo) <- c("lon","lat","date_num")
df_combo$date   <- as.Date(df_combo$date_num, origin = "1970-01-01")

# keep only June–July in the table too (belt-and-braces)
df_combo <- dplyr::filter(df_combo, date >= date_min, date <= date_max)

all_dates   <- sort(unique(df_combo$date))
date_labels <- format(all_dates, "%d %b")
df_combo$date_f <- factor(df_combo$date, levels = all_dates, labels = date_labels)

n_dates    <- length(all_dates)
pal_disc   <- setNames(viridisLite::mako(n_dates, direction = -1), levels(df_combo$date_f))
legend_cols <- if (n_dates <= 8) 1 else if (n_dates <= 16) 2 else 3


# --- Clean, generic map theme (no legend-specific rules here) ---
map_theme_clean <- theme_bw(base_size = 11) +
  theme(
    panel.grid       = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background  = element_rect(fill = "white", colour = NA)
  )

# (re)label helpers in case they’re not already defined
label_lon <- scales::label_number(accuracy = 0.01, suffix = "°")
label_lat <- scales::label_number(accuracy = 0.01, suffix = "°")

# fallback for legend columns if not defined earlier
if (!exists("legend_cols")) {
  n_dates <- length(pal_disc)
  legend_cols <- if (n_dates <= 8) 1 else if (n_dates <= 16) 2 else 3
}

p_combo_disc <- ggplot() +
  geom_tile(
    data   = df_combo,
    aes(x = lon, y = lat, fill = date_f),
    width  = res_ll[1], height = res_ll[2]
  ) +
  geom_sf(data = perim_ll_plot, fill = NA, colour = "black", linewidth = 0.01) +
  scale_fill_manual(values = pal_disc, name = "Date of detection", drop = FALSE) +
  # Legend layout only (no box styling here)
  guides(
    fill = guide_legend(
      title.position = "top",
      ncol = legend_cols, byrow = TRUE
    )
  ) +
  coord_sf(
    crs  = sf::st_crs(4326),
    xlim = c(bb["xmin"], bb["xmax"]),
    ylim = c(bb["ymin"], bb["ymax"]),
    expand = FALSE
  ) +
  scale_x_continuous(labels = label_lon, expand = c(0,0)) +
  scale_y_continuous(labels = label_lat, expand = c(0,0)) +
  labs(x = "Longitude (°)", y = "Latitude (°)", title = NULL) +
  map_theme_clean +
  # Legend box styling + position goes in theme()
  theme(
    legend.position      = c(0.60, 0.1),   # inside panel
    legend.justification = c("left", "bottom"),
    legend.background    = element_rect(fill = scales::alpha("white", 0.85), colour = "grey60"),
    legend.title         = element_text(),
    legend.key.width     = unit(0.35, "cm"),
    legend.key.height    = unit(0.35, "cm"),
    legend.box.margin    = margin(2, 2, 2, 2),
    legend.margin        = margin(2, 2, 2, 2)
  ) +
  # Scale bar & north arrow
  ggspatial::annotation_scale(
    location   = "bl", width_hint = 0.28,
    pad_x      = unit(0.6, "npc"), pad_y = unit(0.35, "cm"),
    bar_cols   = c("grey90","grey30")
  ) +
  ggspatial::annotation_north_arrow(
    location = "br", style = north_arrow_orienteering,
    pad_x = unit(0.3, "cm"), pad_y = unit(0.2, "cm"),
    height = unit(0.5, "cm"), width = unit(0.2, "cm")
  )

print(p_combo_disc)



# --- save (A4 portrait-ish) ---
library(devEMF)
ggsave(
  filename  = "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Figures/VIIRS_MODIS_fire_spread.emf",
  plot      = p_combo_disc,
  device    = function(filename, ...) devEMF::emf(filename, emfPlus = TRUE, family = "Arial", ...),
  width     = 8.27, height = 6, units = "in",
  bg        = "white",
  limitsize = FALSE
)










