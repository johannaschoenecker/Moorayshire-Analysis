# ==========================================================
# Bivariate map: Land cover (hue) × Burn severity (brightness)
# - Fast crop/mask-first reprojection
# - Collapses rare LC classes into "Other (<3%)" (white)
# - Colour-blind–friendly hues for key LC classes
# - Clearer severity brightness (1.00, 0.80, 0.55, 0.30)
# - Legend (below map), ordered & robust
# - Area tables (ha and %) written to CSV and printed
# ==========================================================
library(terra)

# ---------- INPUTS ----------
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"
lc_path   <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Land cover map/ukregion-scotland.tif"
# classed burn-severity raster in EPSG:3035 (1..4 = Unchanged, Low, Moderate, Severe)
sev_path  <- "C:/Users/jscho/Documents/Scotland Megafire/Burn severity Sentinel-2/Carr_RdNBR_class_unscaled_3035.tif"

# OUTPUT
out_dir <- "C:/Users/jscho/Documents/Scotland Megafire/Burn severity Sentinel-2"
out_png <- file.path(out_dir, "Carr_bivariate_LC_RdNBR_RGB_3035_matrixLegend.png")

# Speed/IO options
Sys.setenv(GDAL_NUM_THREADS = "ALL_CPUS")
terraOptions(progress = 1, memfrac = 0.7)

# ---------- Helper: open a larger on-screen device ----------
open_big_device <- function(w=15, h=9){
  os <- Sys.info()[["sysname"]]
  if (os == "Windows") windows(width=w, height=h)
  else if (os == "Darwin") quartz(width=w, height=h)
  else x11(width=w, height=h)
}

# ---------- LOAD ----------
stopifnot(file.exists(perim_shp), file.exists(lc_path), file.exists(sev_path))
perim <- vect(perim_shp)   # perimeter (likely EPSG:3035)
sev   <- rast(sev_path)    # severity classes 1..4, EPSG:3035
lc    <- rast(lc_path)     # LCM2023

# ---------- FAST PATH: crop/mask first in LC CRS, THEN project ----------
# 1) Reproject perimeter to LC CRS (vector reprojection is fast)
perim_lc <- if (!same.crs(perim, lc)) project(perim, crs(lc)) else perim
# 2) Crop & mask LC in its native CRS (fast)
lc_crop_native <- mask(crop(lc, perim_lc, snap = "out"), perim_lc)
# 3) Reproject ONLY the cropped LC to the severity GRID (nearest neighbour)
lc_to_sev <- project(
  lc_crop_native, sev, method = "near",
  wopt = list(gdal = c("COMPRESS=LZW","TILED=YES"))
)
# 4) Also crop/mask severity to perimeter (in case sev extends beyond)
sev_cm <- mask(crop(sev, perim, snap = "out"), perim)

# ---------- Keep band 1 and drop categories before math ----------
lc1  <- lc_to_sev[[1]]
sev1 <- sev_cm[[1]]
levels(lc1)  <- NULL
levels(sev1) <- NULL

# ---------- LCM2023 classes and default colours (fallbacks) ----------
classes <- data.frame(
  id = 1:21,
  name = c("Broadleaved woodland","Coniferous Woodland","Arable and Horticulture",
           "Improved Grassland","Neutral Grassland","Calcareous Grassland","Acid grassland",
           "Fen, Marsh and Swamp","Heather","Heather grassland","Bog","Inland Rock",
           "Saltwater","Freshwater","Supralittoral Rock","Supralittoral Sediment",
           "Littoral Rock","Littoral sediment","Saltmarsh","Urban","Suburban")
)

rgb_mat <- rbind(
  c(255,  0,  0),   # 1  Broadleaved woodland
  c(  0,102,  0),   # 2  Coniferous Woodland
  c(115, 38,  0),   # 3  Arable and Horticulture
  c(  0,255,  0),   # 4  Improved Grassland
  c(127,229,127),   # 5  Neutral Grassland
  c(112,168,  0),   # 6  Calcareous Grassland
  c(153,129,  0),   # 7  Acid grassland
  c(255,255,  0),   # 8  Fen, Marsh and Swamp
  c(128, 26,128),   # 9  Heather
  c(230,140,166),   # 10 Heather grassland
  c(  0,128,115),   # 11 Bog
  c(210,210,255),   # 12 Inland Rock
  c(  0,  0,128),   # 13 Saltwater
  c(  0,  0,255),   # 14 Freshwater
  c(204,179,  0),   # 15 Supralittoral Rock
  c(204,179,  0),   # 16 Supralittoral Sediment
  c(255,255,128),   # 17 Littoral Rock
  c(255,255,128),   # 18 Littoral sediment
  c(128,128,255),   # 19 Saltmarsh
  c(  0,  0,  0),   # 20 Urban
  c(128,128,128)    # 21 Suburban
)

# ---------- Collapse rare land-cover classes into "Other (<3%)" ----------
threshold <- 0.03   # 3% of total area
lc_area_ha <- terra::cellSize(lc1, unit = "ha")
z_lc <- terra::zonal(lc_area_ha, lc1, fun = "sum", na.rm = TRUE)
names(z_lc) <- c("LC","ha")
total_ha <- sum(z_lc$ha, na.rm = TRUE)
z_lc$prop <- z_lc$ha / total_ha

rare_ids  <- z_lc$LC[ z_lc$prop < threshold ]
keep_ids  <- z_lc$LC[ z_lc$prop >= threshold ]

if (length(rare_ids) > 0) {
  # Recode rare classes to 999 = Other
  rcl <- rbind(
    cbind(keep_ids, keep_ids),
    cbind(rare_ids, rep(999L, length(rare_ids)))
  )
  lc_rec <- classify(lc1, rcl = rcl, include.lowest = TRUE)
  
  other_id   <- 999L
  other_name <- "Other (<3%)"
  other_rgb  <- c(255,255,255)  # white box
  
  keep_idx     <- match(keep_ids, classes$id)
  classes_map  <- rbind(
    data.frame(id = classes$id[keep_idx], name = classes$name[keep_idx]),
    data.frame(id = other_id,            name = other_name)
  )
  rgb_map <- rbind(
    rgb_mat[keep_idx, , drop = FALSE],
    matrix(other_rgb, nrow = 1)
  )
  lc1 <- lc_rec
} else {
  classes_map <- data.frame(id = classes$id, name = classes$name)
  rgb_map     <- rgb_mat
}

# ---------- Override hues with a colour-blind–friendly palette ----------
# Okabe–Ito inspired set: distinct & CVD-safe.
cb_hex <- c(
  "Coniferous Woodland" = "#009E73",  # bluish green
  "Heather"             = "#CC79A7",  # reddish purple
  "Heather grassland"   = "#E69F00",  # orange
  "Bog"                 = "#0072B2",  # blue
  "Other (<3%)"         = "#FFFFFF"   # white (as requested)
)
hex_to_rgb_vec <- function(hx) as.numeric(grDevices::col2rgb(hx))
for (i in seq_len(nrow(classes_map))) {
  nm <- classes_map$name[i]
  if (!is.na(cb_hex[nm])) {
    rgb_map[i, ] <- hex_to_rgb_vec(cb_hex[nm])
  }
}

# ---------- Map LC IDs -> base R/G/B rasters ----------
R_base <- subst(lc1, classes_map$id, rgb_map[,1])
G_base <- subst(lc1, classes_map$id, rgb_map[,2])
B_base <- subst(lc1, classes_map$id, rgb_map[,3])

# ---------- Map Severity IDs -> brightness factor raster ----------
sev_labels <- c("Unchanged","Low","Moderate","Severe")
# Clearer steps: Unchanged brightest → Severe darkest
sev_factor <- c("Unchanged"=1.00, "Low"=0.80, "Moderate"=0.55, "Severe"=0.30)
sev_fact_vec <- as.numeric(sev_factor[sev_labels]) # index 1..4
sev_ids <- 1:4
sev_fac <- subst(sev1, sev_ids, sev_fact_vec)  # per-pixel brightness factor

# ---------- Apply brightness to each channel ----------
R_out <- clamp(round(R_base * sev_fac), 0, 255)
G_out <- clamp(round(G_base * sev_fac), 0, 255)
B_out <- clamp(round(B_base * sev_fac), 0, 255)

# Stack into 3-band RGB
bi_rgb <- c(R_out, G_out, B_out)
names(bi_rgb) <- c("R","G","B")

# ---------- Legend contents: only combos that occur (robust, ordered) ----------
names(lc1)  <- "LC"
names(sev1) <- "SEV"

.to_int <- function(v) {
  v <- v[!is.na(v)]
  if (is.factor(v)) v <- as.character(v)
  suppressWarnings(as.integer(v))
}
xt <- try(terra::crosstab(lc1, sev1, long = TRUE, useNA = FALSE), silent = TRUE)
if (inherits(xt, "try-error") || is.null(xt) || nrow(xt) == 0) {
  vals <- terra::values(c(lc1, sev1), mat = TRUE)
  lc_vals_xt  <- unique(.to_int(vals[,1]))
  sev_vals_xt <- unique(.to_int(vals[,2]))
} else {
  lc_vals_xt  <- unique(.to_int(xt$LC))
  sev_vals_xt <- unique(.to_int(xt$SEV))
}
present_ids <- sort(intersect(lc_vals_xt, classes_map$id))
if (999L %in% present_ids) present_ids <- c(setdiff(present_ids, 999L), 999L)

# severity in fixed order but keep only ones that appear
all_order <- c("Unchanged","Low","Moderate","Severe")
valid_sev_ids <- seq_along(sev_labels)
present_sev <- intersect(sev_vals_xt, valid_sev_ids)
present_sev_labels  <- sev_labels[present_sev]
present_sev_factors <- sev_fact_vec[present_sev]
o <- order(match(present_sev_labels, all_order))
present_sev_labels  <- present_sev_labels[o]
present_sev_factors <- present_sev_factors[o]

# ---------- Adaptive horizontal matrix legend (below the map) ----------
draw_matrix_legend_horizontal <- function(present_ids, classes_map, rgb_map,
                                          sev_labels, sev_fact_vec,
                                          title = "Land cover × Severity",
                                          abbrev_len = 22) {
  lc_names_full <- classes_map$name[match(present_ids, classes_map$id)]
  lc_names <- ifelse(nchar(lc_names_full) > abbrev_len,
                     paste0(substr(lc_names_full, 1, abbrev_len-1), "…"),
                     lc_names_full)
  
  n_col <- length(present_ids); n_row <- length(sev_labels)
  cex_cols <- if (n_col <= 8) 0.9 else if (n_col <= 14) 0.75 else if (n_col <= 20) 0.62 else 0.55
  bmar <- if (n_col <= 12) 5 else if (n_col <= 20) 4 else 3
  lmar <- 4
  
  op <- par(mar = c(bmar, lmar, 2, 1), xpd = NA)
  on.exit(par(op), add = TRUE)
  
  plot.new()
  plot.window(xlim = c(-0.35, n_col), ylim = c(0, n_row))
  
  # Cells
  for (j in seq_len(n_col)) {
    row_idx <- match(present_ids[j], classes_map$id)
    base <- rgb_map[row_idx, ]
    for (i in seq_len(n_row)) {
      f   <- sev_fact_vec[i]
      col <- rgb(round(base[1]*f), round(base[2]*f), round(base[3]*f), maxColorValue = 255)
      rect(j-1, n_row-i, j, n_row-i+1, col = col, border = NA)
    }
  }
  
  # Grid
  segments(0:n_col, 0, 0:n_col, n_row, col = gray(0.85))
  segments(0, 0:n_row, n_col, 0:n_row, col = gray(0.85))
  
  # Title
  mtext(title, side = 3, line = 0.3, cex = 1, font = 2)
  
  # Column labels (LC)
  for (j in seq_len(n_col)) {
    text(x = j-0.5, y = -0.25, labels = lc_names[j], srt = 30, adj = 1, cex = cex_cols)
  }
  mtext("Land cover →", side = 1, line = bmar-1.5, cex = 0.9)
  
  # Row labels (Severity) — draw slightly inside to avoid clipping
  for (i in seq_len(n_row)) {
    text(x = -0.15, y = n_row - i + 0.5, labels = sev_labels[i], adj = 1, cex = 0.9)
  }
  mtext("Severity ↓", side = 2, line = 1.2, cex = 0.9)
  
  box()
}

# ---------- PLOT TO SCREEN ----------
graphics.off()
open_big_device(15, 9)
layout(matrix(c(1,2), 2, 1), heights = c(3.2, 1))
par(mar = c(3,3,3,1), oma = c(0,0,0,0))
plotRGB(bi_rgb, r=1, g=2, b=3, scale=255,
        main="Dava–Carrbridge: Land cover (hue) × Severity (brightness)")
lines(perim, lwd=1.2)
draw_matrix_legend_horizontal(present_ids, classes_map, rgb_map,
                              present_sev_labels, present_sev_factors)

# ---------- SAVE PNG (same layout) ----------
png(out_png, width = 1800, height = 1200, res = 150)
layout(matrix(c(1,2), 2, 1), heights = c(3.2, 1))
par(mar = c(3,3,3,1), oma = c(0,0,0,0))
plotRGB(bi_rgb, r=1, g=2, b=3, scale=255,
        main="Dava–Carrbridge: Land cover (hue) × Severity (brightness)")
lines(perim, lwd=1.2)
draw_matrix_legend_horizontal(present_ids, classes_map, rgb_map,
                              present_sev_labels, present_sev_factors)
dev.off()
message("Wrote PNG: ", out_png)

# ==========================================================
# AREA TABLES: LC × Severity (ha) and (%)
# ==========================================================
area_ha_r <- terra::cellSize(lc1, unit = "ha")
vals <- cbind(
  LC  = as.integer(values(lc1)),
  SEV = as.integer(values(sev1)),
  HA  = as.numeric(values(area_ha_r))
)
vals <- vals[stats::complete.cases(vals), , drop = FALSE]
area_long <- aggregate(HA ~ LC + SEV, data = as.data.frame(vals), FUN = sum, na.rm = TRUE)
total_ha_all <- sum(area_long$HA, na.rm = TRUE)

# keep only IDs actually in map
area_long <- subset(area_long, SEV %in% intersect(unique(area_long$SEV), seq_along(sev_labels)) &
                      LC  %in% classes_map$id)

# label columns
lc_lookup <- setNames(classes_map$name, classes_map$id)
area_long$LandCover <- lc_lookup[as.character(area_long$LC)]
area_long$Severity  <- sev_labels[area_long$SEV]
area_long$Percent   <- (area_long$HA / total_ha_all) * 100

# nice ordering
lc_order <- setdiff(sort(unique(area_long$LandCover)), "Other (<3%)")
if ("Other (<3%)" %in% area_long$LandCover) lc_order <- c(lc_order, "Other (<3%)")
sev_order <- c("Unchanged","Low","Moderate","Severe")
sev_order <- sev_order[sev_order %in% area_long$Severity]
area_long$LandCover <- factor(area_long$LandCover, levels = lc_order)
area_long$Severity  <- factor(area_long$Severity,  levels = sev_order)
area_long <- area_long[order(area_long$LandCover, area_long$Severity), ]

# Pretty strings
fmt_num <- function(x) format(round(x, 1), trim = TRUE, nsmall = 1, big.mark = ",")
fmt_pct <- function(x) format(round(x, 1), trim = TRUE, nsmall = 1)
area_long$Label <- paste0(fmt_num(area_long$HA), " (", fmt_pct(area_long$Percent), "%)")

# Wide matrix version (strings in cells)
LCxSEV_matrix <- reshape(area_long[, c("LandCover","Severity","Label")],
                         timevar = "Severity", idvar = "LandCover", direction = "wide")
names(LCxSEV_matrix) <- sub("^Label\\.", "", names(LCxSEV_matrix))

# Marginals
by_LC <- aggregate(HA ~ LandCover, data = area_long, sum)
by_LC$Percent <- (by_LC$HA / total_ha_all) * 100
by_LC <- by_LC[order(by_LC$LandCover), ]
by_LC$Label <- paste0(fmt_num(by_LC$HA), " (", fmt_pct(by_LC$Percent), "%)")

by_SEV <- aggregate(HA ~ Severity, data = area_long, sum)
by_SEV$Percent <- (by_SEV$HA / total_ha_all) * 100
by_SEV <- by_SEV[match(sev_order, by_SEV$Severity, nomatch = 0), ]
by_SEV$Label <- paste0(fmt_num(by_SEV$HA), " (", fmt_pct(by_SEV$Percent), "%)")

# Save CSVs
out_csv_long   <- file.path(out_dir, "Carr_area_by_LC_x_Severity_long.csv")
out_csv_wide   <- file.path(out_dir, "Carr_area_by_LC_x_Severity_wide_strings.csv")
out_csv_by_lc  <- file.path(out_dir, "Carr_area_by_LC.csv")
out_csv_by_sev <- file.path(out_dir, "Carr_area_by_Severity.csv")
write.csv(area_long[, c("LandCover","Severity","HA","Percent")], out_csv_long, row.names = FALSE)
write.csv(LCxSEV_matrix, out_csv_wide, row.names = FALSE)
write.csv(by_LC[, c("LandCover","HA","Percent")], out_csv_by_lc, row.names = FALSE)
write.csv(by_SEV[, c("Severity","HA","Percent")], out_csv_by_sev, row.names = FALSE)

message("Wrote area tables:\n  - ", out_csv_long,
        "\n  - ", out_csv_wide,
        "\n  - ", out_csv_by_lc,
        "\n  - ", out_csv_by_sev)

# Console summary
cat("\nTotal area (ha): ", fmt_num(total_ha_all), "\n\n")
cat("By Land cover:\n"); print(by_LC[, c("LandCover","Label")], row.names = FALSE)
cat("\nBy Severity:\n"); print(by_SEV[, c("Severity","Label")], row.names = FALSE)
cat("\nLC × Severity (each cell = ha ( % )):\n"); print(LCxSEV_matrix, row.names = FALSE)






library(rosm)
library(terra)
library(sp)

# Convert perimeter to WGS84 + sp, as rosm expects
perim_wgs <- if (!terra::same.crs(perim, "EPSG:4326")) terra::project(perim, "EPSG:4326") else perim
perim_sp  <- methods::as(perim_wgs, "Spatial")

# Try a few built-in providers; first that works is used
candidate_types <- c("stamenterrain", "osm", "cartolight")
basemap_brick <- NULL
for (t in candidate_types) {
  cat("Trying basemap type:", t, "...\n")
  basemap_brick <- try(rosm::osm.raster(perim_sp, type = t, zoomin = 0), silent = TRUE)
  if (!inherits(basemap_brick, "try-error")) { basemap_type <- t; break }
}
if (is.null(basemap_brick) || inherits(basemap_brick, "try-error")) {
  stop("All basemap providers failed. Run rosm::osm.types() to see available types.")
}

# Reproject to your severity raster grid (so it aligns with your EPSG:3035 stack)
bm_merc <- terra::rast(basemap_brick)            # Web Mercator
bm_3035 <- terra::project(bm_merc, sev, method = "bilinear")
bm_base <- terra::mask(terra::crop(bm_3035, perim, snap = "out"), perim)

# Optional: add transparency to your bivariate RGB
alpha_val <- 120
A <- terra::rast(bi_rgb[[1]]); terra::values(A) <- alpha_val
bi_rgba <- c(bi_rgb, A); names(bi_rgba) <- c("R","G","B","A")

# Plot (screen)
graphics.off(); open_big_device(15, 9)
layout(matrix(c(1,2), 2, 1), heights = c(3.2, 1))
par(mar = c(3,3,3,1), oma = c(0,0,0,0))

terra::plotRGB(bm_base, r=1, g=2, b=3, scale=255,
               main = paste0("LC × Severity over basemap (", basemap_type, ")"))
terra::plotRGB(bi_rgba, r=1, g=2, b=3, scale=255, alpha=TRUE, add=TRUE)
lines(perim, lwd = 1.2)

draw_matrix_legend_horizontal(present_ids, classes_map, rgb_map,
                              present_sev_labels, present_sev_factors)










library(terra)

# ---------- INPUTS ----------
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"
lc_path   <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Land cover map/ukregion-scotland.tif"
dnbr_path <- "C:/Users/jscho/Documents/Scotland Megafire/Burn severity Sentinel-2/Carr_dNBR_class_3035.tif"

# ---------- OUTPUT ----------
out_tif <- "C:/Users/jscho/Documents/Scotland Megafire/Burn severity Sentinel-2/LC_where_dNBR_eq4.tif"

# ---------- Speed/IO options ----------
Sys.setenv(GDAL_NUM_THREADS = "ALL_CPUS")
terraOptions(progress = 1, memfrac = 0.7)

# ---------- LOAD ----------
stopifnot(file.exists(perim_shp), file.exists(lc_path), file.exists(dnbr_path))
perim <- vect(perim_shp)     # fire perimeter (likely EPSG:3035)
dnbr  <- rast(dnbr_path)     # dNBR classes in EPSG:3035 (1..4 etc.)
lc    <- rast(lc_path)       # land cover

# ---------- FAST PATH: crop/mask first in LC CRS, THEN project ----------
# 1) Reproject perimeter to LC CRS (vector reprojection is fast)
perim_lc <- if (!same.crs(perim, lc)) project(perim, crs(lc)) else perim

# 2) Crop & mask LC in its native CRS (fast)
lc_crop_native <- mask(crop(lc, perim_lc, snap = "out"), perim_lc)

# 3) Reproject ONLY the cropped LC to the dNBR grid (categorical -> nearest neighbour)
lc_to_dnbr <- project(
  lc_crop_native, dnbr, method = "near",
  wopt = list(gdal = c("COMPRESS=LZW","TILED=YES"))
)

# 4) Also crop/mask dNBR to perimeter (in case dnbr extends beyond)
dnbr_cm <- mask(crop(dnbr, perim, snap = "out"), perim)

# ---------- KEEP ONLY lc cells where dNBR == 3 ----------
# Use ifel(): keep landcover where condition is TRUE, otherwise NA
lc_where_dnbr3 <- ifel(dnbr_cm == 4, lc_to_dnbr, NA)

# ---------- SAVE ----------
writeRaster(
  lc_where_dnbr3,
  filename = out_tif,
  overwrite = TRUE,
  wopt = list(gdal = c("COMPRESS=LZW","TILED=YES"))
)

message("Wrote: ", out_tif)
