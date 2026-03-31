# --- Scotland Dava-Carrbridge Fire — Sentinel-2 burn severity (UNSCALED thresholds) ---
library(terra)
library(tidyr)

# ===================== INPUTS =====================
in_dir    <- "C:/Users/jscho/Documents/Scotland Megafire/Burn severity Sentinel-2"
out_dir   <- in_dir
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"

# If these exact files exist they'll be used; otherwise we'll mosaic matching patterns below.
rdnbr_file <- file.path(in_dir, "Carr_RdNBR.tif")
dnbr_file  <- file.path(in_dir, "Carr_dNBR.tif")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ===================== LOAD PERIMETER (EPSG:3035 equal-area) =====================
stopifnot(file.exists(perim_shp))
perim <- vect(perim_shp)
message("Perimeter CRS: ", crs(perim))

# ===================== HELPERS =====================
# Read one raster or mosaic many matching a pattern
read_or_mosaic <- function(single_path, pattern) {
  if (file.exists(single_path)) {
    rast(single_path)
  } else {
    files <- list.files(in_dir, pattern = pattern, full.names = TRUE)
    if (!length(files)) return(NULL)
    message("Mosaicing ", length(files), " tiles for pattern: ", pattern)
    rlist <- lapply(files, rast)
    do.call(mosaic, rlist)
  }
}

# Reproject (to perimeter CRS), crop & mask (continuous rasters -> bilinear)
prep_continuous <- function(r, per) {
  if (is.null(r)) return(NULL)
  if (!same.crs(r, per)) {
    message("Reprojecting raster to ", crs(per))
    r <- project(r, crs(per), method = "bilinear")
  }
  r <- crop(r, per, snap = "out")
  r <- mask(r, per)
  r
}

# Classify, save, plot, and compute area by class (ha) using zonal(cellSize)
classify_write_plot_area <- function(x, rcl, labels, base_name, pal) {
  if (is.null(x)) return(invisible(NULL))
  
  # Classify ([from, to) intervals; include.lowest to catch minima)
  cls <- classify(x, rcl = rcl, include.lowest = TRUE)
  
  # Attach labels & colors
  levels(cls) <- data.frame(id = seq_along(labels), class = labels)
  coltab(cls) <- data.frame(value = seq_along(labels),
                            col   = unname(pal[labels]))
  
  # Write classified GeoTIFF (kept in EPSG:3035, area-preserving)
  out_tif <- file.path(out_dir, paste0(base_name, "_class_unscaled_3035.tif"))
  writeRaster(cls, out_tif, overwrite = TRUE)
  message("Wrote: ", out_tif)
  
  # Area by class (hectares), version-proof approach
  area_ha <- terra::cellSize(cls, unit = "ha")
  ztbl    <- terra::zonal(area_ha, cls, fun = "sum", na.rm = TRUE)
  a_df    <- as.data.frame(ztbl)
  names(a_df) <- c("class_id", "hectares")
  a_df$class  <- labels[match(a_df$class_id, seq_along(labels))]
  
  print(a_df[, c("class", "hectares")], row.names = FALSE)
  out_csv <- file.path(out_dir, paste0(base_name, "_area_ha.csv"))
  write.csv(a_df[, c("class","hectares")], out_csv, row.names = FALSE)
  message("Wrote: ", out_csv)
  
  # Quicklook PNG
  cols <- unname(pal[labels])
  out_png <- file.path(out_dir, paste0(base_name, "_class_unscaled_3035.png"))
  png(out_png, width = 1200, height = 900, res = 150)
  plot(cls, col = cols, plg = list(title = paste0(base_name, " burn severity")))
  dev.off()
  message("Wrote: ", out_png)
  
  invisible(cls)
}

# ===================== PALETTE =====================
pal <- c("Unchanged" = "#D9DDDC",
         "Low"       = "#ECEC0E",
         "Moderate"  = "#F5BE16",
         "Severe"    = "#FF0000")

labels <- c("Unchanged","Low","Moderate","Severe")

# ===================== LOAD RASTERS (OR MOSAIC) =====================
rdnbr_raw <- read_or_mosaic(rdnbr_file, pattern = "RdNBR.*\\.tif$")
dnbr_raw  <- read_or_mosaic(dnbr_file,  pattern = "dNBR.*\\.tif$")

# ===================== REPROJECT -> EPSG:3035, CROP & MASK =====================
rdnbr_3035 <- prep_continuous(rdnbr_raw, perim)
dnbr_3035  <- prep_continuous(dnbr_raw,  perim)

# ===================== CLASSIFICATION (UNSCALED) =====================
# RdNBR (unscaled):
#   Unchanged: < 0.069
#   Low:       0.069–0.315
#   Moderate:  0.315–0.640
#   Severe:    > 0.640
if (!is.null(rdnbr_3035)) {
  rcl_rdnbr_unscaled <- matrix(c(
    -Inf, 0.069, 1,
    0.069, 0.315, 2,
    0.315, 0.640, 3,
    0.640, Inf,   4
  ), ncol = 3, byrow = TRUE)
  
  rdnbr_cls <- classify_write_plot_area(
    x = rdnbr_3035,
    rcl = rcl_rdnbr_unscaled,
    labels = labels,
    base_name = "Carr_RdNBR",
    pal = pal
  )
}

# dNBR (unscaled):
#   Unchanged: < 0.100
#   Low:       0.100–0.269
#   Moderate:  0.269–0.439
#   Severe:    >= 0.439

if (!is.null(dnbr_3035)) {
  rcl_dnbr_unscaled <- matrix(c(
    -Inf, 0.100, 1,
    0.100, 0.269, 2,
    0.269, 0.439, 3,
    0.439, Inf,   4
  ), ncol = 3, byrow = TRUE)
  
  dnbr_cls <- classify_write_plot_area(
    x = dnbr_3035,
    rcl = rcl_dnbr_unscaled,
    labels = labels,
    base_name = "Carr_dNBR",
    pal = pal
  )
}
