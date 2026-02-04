# ------------------------------------------------------------------
# Calculation of carbon emissions from aboveground and belowground
# biomass combustion in the 2025 Dava Moor Fire (Scotland)
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Fractional land cover around centre points (10 m grid in 240 m square)
# Files required
#   - CSV of centre coordinates: x, y (EPSG:27700 by default)
#   - Categorical land-cover GeoTIFF (band 1 has classes 1..21)
#   - Raster of burn severity classes
#
# Outputs:
#   *_LC_10m_points.csv     (optional raw sampled points)
#   *_LC_10m_counts.csv     (per-centre counts per class)
#   *_LC_10m_fractions.csv  (per-centre fractions per class; rows sum ~1)
# ------------------------------------------------------------------

library(terra)
library(sf)
library(data.table)
library(dplyr)
library(tidyr)
library(here)

# ---- Inputs ----
###### Emissions calculated using Baker (2025) model
csv_path    <- paste0(here(),"/Data/C Emissions Sarah/C_emissions_Dava_moor_fire.csv") 

##### Landcover map of Scotland from Morton (2024) at 10m spatial resolution
tif_path    <- paste0(here(),"/Data/Land cover map/ukregion-scotland.tif")

square_size <- 240   # metres (edge length of the square)
interval    <- 10    # metres (spacing of the sample grid)
center_epsg <- 27700 # EPSG of x/y in the CSV (BNG = 27700)

write_raw_points <- TRUE  # set FALSE if you don't want the big points CSV

# ---- Read raster (band 1) ----
r <- terra::rast(tif_path)
if (terra::nlyr(r) > 1) r <- r[[1]]
r_crs <- terra::crs(r)
cat("Raster CRS:", r_crs, "\n")

# ---- Read cell centre coordinates of 250m burned raster cell (CSV must have columns x and y; ID optional) ----
centres <- data.table::fread(csv_path)
stopifnot(all(c("x","y") %in% names(centres)))
if (!"ID" %in% names(centres)) centres[, ID := .I]

# Centres as sf in their declared CRS
pts_csv <- sf::st_as_sf(centres, coords = c("x","y"), crs = paste0("EPSG:", center_epsg))

# Reproject centres to raster CRS (safe for sampling)
pts_r <- sf::st_transform(pts_csv, r_crs)

# ---- Build a 10 m grid inside a 240 m square around each centre (in raster CRS) ----
# Grid offsets relative to centre
offsets <- seq(-square_size/2, +square_size/2, by = interval)
n_side  <- length(offsets)  # e.g. 25
cat("Points per square:", n_side, "x", n_side, "=", n_side^2, "\n")

xy <- sf::st_coordinates(pts_r)
n_centres <- nrow(pts_r)

# Build grid for all centres (vectorised via lapply)
grid_list <- lapply(seq_len(n_centres), function(i) {
  cx <- xy[i, 1]; cy <- xy[i, 2]
  # expand.grid creates all combinations of offsets
  g  <- expand.grid(dx = offsets, dy = offsets)
  data.frame(
    ID = centres$ID[i],
    x  = cx + g$dx,
    y  = cy + g$dy
  )
})

points_df <- data.table::rbindlist(grid_list, use.names = TRUE)
rm(grid_list); gc()

# ---- Extract land-cover value at each grid point ----
# (terra::extract with matrix of xy; returns a data.frame with one column = values)
vals <- terra::extract(r, as.matrix(points_df[, c("x","y")]))
# name of the value column (first/only column)
val_col <- names(vals)[1]
points_df[, lc := as.integer(vals[[val_col]])]
rm(vals); gc()

# ---- Write raw sampled points (in raster CRS) ----
if (write_raw_points) {
  out_points <- sub("\\.csv$", "_LC_10m_points.csv", csv_path)
  data.table::fwrite(points_df, out_points)
  cat("Wrote raw points:", out_points, "\n")
}

# ---- Summarise: counts per centre per land cover class ----
counts_long <- points_df[!is.na(lc), .N, by = .(ID, lc)]
setnames(counts_long, "N", "count")

# Wide table of counts: one column per class value present in the raster
counts_wide <- tidyr::pivot_wider(
  counts_long,
  names_from  = lc,
  values_from = count,
  names_prefix = "class_",
  values_fill = 0
) |>
  as.data.table()

# Total sampled (non-NA) points per centre (sanity check- should be 625 for every centre)
totals <- points_df[, .(n_sampled = sum(!is.na(lc))), by = ID]

# Join totals
counts_wide <- totals[counts_wide, on = "ID"]

# ---- Fractions per class (rows sum to ~1; may be <1 near raster edges/NoData) ----
# Compute fractions only over the class_* columns
class_cols <- grep("^class_", names(counts_wide), value = TRUE)
fracs_wide <- copy(counts_wide)
for (cc in class_cols) {
  fracs_wide[[cc]] <- ifelse(
    fracs_wide$n_sampled > 0, fracs_wide[[cc]] / fracs_wide$n_sampled, NA_real_
  )
}


# ---- Write outputs ----
out_counts <- sub("\\.csv$", "_LC_10m_counts.csv",    csv_path)
out_fracs  <- sub("\\.csv$", "_LC_10m_fractions.csv", csv_path)

data.table::fwrite(counts_wide, out_counts)
data.table::fwrite(fracs_wide[, c("ID","n_sampled", class_cols, setdiff(names(fracs_wide), c("ID","n_sampled", class_cols))), with = FALSE],
                   out_fracs)

cat("Wrote counts:   ", out_counts, "\n")
cat("Wrote fractions:", out_fracs,  "\n")



# ────────────────────────────────────────────────────────────────────────────────
# ADD: dNBR classes at the same 10 m grid points + LC × Severity fractions
# ────────────────────────────────────────────────────────────────────────────────

# ---- 1) Load dNBR classes (categorical) ----
dnbr_path <- paste0(here(),"/Data/Burn severity Sentinel-2/Carr_dNBR_class_unscaled_3035.tif")
dnbr <- terra::rast(dnbr_path)
if (terra::nlyr(dnbr) > 1) dnbr <- dnbr[[1]]         # band 1
dnbr_crs <- terra::crs(dnbr)
cat("dNBR CRS:", dnbr_crs, "\n")

# ---- 2) Reproject the sampling points (points created as grid around centre coordinates) to the dNBR CRS (fast) and extract ----
# points_df has x,y in the LC raster CRS (r_crs). Make sf -> transform -> coords.
pts_all_sf <- sf::st_as_sf(points_df[, c("x","y")], coords = c("x","y"), crs = r_crs)
pts_all_d  <- sf::st_transform(pts_all_sf, dnbr_crs)
xy_d       <- sf::st_coordinates(pts_all_d)

# Extract dNBR class at each grid point (no ID column returned)
sev_vals <- terra::extract(dnbr, xy_d)
sev_col  <- names(sev_vals)[1]
points_df[, sev := as.integer(sev_vals[[sev_col]])]   # add severity to the big table
rm(pts_all_sf, pts_all_d, xy_d, sev_vals); gc()

# (Optional) Write raw points with both lc and sev
out_points_lc_sev <- sub("\\.csv$", "_LCxSEV_10m_points.csv", csv_path)
if (write_raw_points) {
  data.table::fwrite(points_df, out_points_lc_sev)
  cat("Wrote LC×SEV points:", out_points_lc_sev, "\n")
}

# ---- 3) Per-centre LC × Severity counts and fractions ----
# Keep only rows where both lc and sev are present
pairs <- points_df[!is.na(lc) & !is.na(sev)]

# Counts per (centre, LC, Sev)
combo_counts <- pairs[, .N, by = .(ID, lc, sev)]
data.table::setnames(combo_counts, "N", "count")

# Denominator: number of valid LC×SEV samples per centre
denom <- pairs[, .N, by = ID]
data.table::setnames(denom, "N", "n_valid")

# Attach denominator and compute fractions
combo_counts <- denom[combo_counts, on = "ID"]
combo_counts[, frac := ifelse(n_valid > 0, count / n_valid, NA_real_)]

# ---- 4) (Optional) add LC and Severity labels for readability ----
lc_codes <- 1:21
lc_names <- c(
  "Broadleaved woodland","Coniferous Woodland","Arable and Horticulture",
  "Improved Grassland","Neutral Grassland","Calcareous Grassland",
  "Acid grassland","Fen, Marsh and Swamp","Heather","Heather grassland",
  "Bog","Inland Rock","Saltwater","Freshwater","Supralittoral Rock",
  "Supralittoral Sediment","Littoral Rock","Littoral sediment",
  "Saltmarsh","Urban","Suburban"
)
lc_lookup <- setNames(lc_names, lc_codes)
combo_counts[, lc_name := lc_lookup[as.character(lc)]]

# Adjust if your dNBR classes use different codes/labels
sev_lookup <- setNames(c("Unchanged","Low","Moderate","Severe"), 1:4)
combo_counts[, sev_name := sev_lookup[as.character(sev)]]

# ---- 5) Wide tables ----
# a) Fractions wide: one column per LC×Sev combo (e.g., lc11_s2)
combo_frac_wide <- tidyr::pivot_wider(
  combo_counts[, .(ID, lc, sev, frac)],
  names_from  = c(lc, sev),
  values_from = frac,
  names_glue  = "lc{lc}_s{sev}",
  values_fill = 0
) |>
  as.data.table()

# b) Counts wide (same columns, but counts instead of fractions)
combo_count_wide <- tidyr::pivot_wider(
  combo_counts[, .(ID, lc, sev, count)],
  names_from  = c(lc, sev),
  values_from = count,
  names_glue  = "lc{lc}_s{sev}",
  values_fill = 0
) |>
  as.data.table()

# Also keep the denominators
combo_frac_wide <- denom[combo_frac_wide, on = "ID"]
combo_count_wide <- denom[combo_count_wide, on = "ID"]



############## Summarise landcover groups

# Add grouped land-cover name
combo_counts[, grp_lc_name := fcase(
  lc_name %in% c("Broadleaved woodland", "Coniferous Woodland"), "Forests and Woodlands",
  lc_name %in% c("Heather", "Heather grassland"),               "Moorlands and Heathlands",
  lc_name == "Bog",                                             "Peatlands",
  default = "Other Natural and Managed Lands"
)]



counts_peatlands <- combo_counts %>%
  filter(grp_lc_name == 'Peatlands')

counts_peatlands_unchanged <- counts_peatlands %>%
  filter(sev == 1)
counts_peatlands_low <- counts_peatlands %>%
  filter(sev == 2)
counts_peatlands_moderate <- counts_peatlands %>%
  filter(sev == 3)
counts_peatlands_high <- counts_peatlands %>%
  filter(sev == 4)

counts_forest <- combo_counts %>%
  filter(grp_lc_name == 'Forests and Woodlands')
counts_forest_unchanged <- counts_forest %>%
  filter(sev == 1)
counts_forest_low <- counts_forest %>%
  filter(sev == 2)
counts_forest_moderate <- counts_forest %>%
  filter(sev == 3)
counts_forest_high <- counts_forest %>%
  filter(sev == 4)

counts_moorlands <- combo_counts %>%
  filter(grp_lc_name == "Moorlands and Heathlands")
counts_moorlands_unchanged <- counts_moorlands %>%
  filter(sev == 1)
counts_moorlands_low <- counts_moorlands %>%
  filter(sev == 2)
counts_moorlands_moderate <- counts_moorlands %>%
  filter(sev == 3)
counts_moorlands_high <- counts_moorlands %>%
  filter(sev == 4)

counts_other <- combo_counts %>%
  filter(grp_lc_name == "Other Natural and Managed Lands")
counts_other_unchanged <- counts_other %>%
  filter(sev == 1)
counts_other_low <- counts_other %>%
  filter(sev == 2)
counts_other_moderate <- counts_other %>%
  filter(sev == 3)
counts_other_high <- counts_other %>%
  filter(sev == 4)




####### Calculate belowground emissions for Peatlands and Moorlands- Scenario I: field burn depths, national BD average, peat emissions over heathlands and bogs

# Variables

### CARBON bulk densities (carbon concentration x soil bulk density) in kg/m3
bulk_density_peat <- 68.64 #38  # From Abernethy
bulk_density_moorlands <- 68.64 #58 # From Glenmore
combustion_coeff <- 0.5


# Include field-measured mean burn depths for peatlands and moorlands, for each severity class

bd_field_peat_low_25 <- 0
bd_field_peat_low_med <- 0
bd_field_peat_low_75 <- 0

bd_field_peat_mod_25 <- 0
bd_field_peat_mod_med <- 0.005
bd_field_peat_mod_75 <- 0.015

bd_field_peat_high_25 <- 0
bd_field_peat_high_med <- 0.01
bd_field_peat_high_75 <- 0.025

bd_field_heath_low_25 <- 0.01
bd_field_heath_low_med <- 0.01
bd_field_heath_low_75 <- 0.01

bd_field_heath_mod_25 <- 0
bd_field_heath_mod_med <- 0.01
bd_field_heath_mod_75 <- 0.0225

bd_field_heath_high_25 <- 0.01
bd_field_heath_high_med <- 0.015
bd_field_heath_high_75 <- 0.025

# Formula to calculate C emission per pixel: C_emission = burn_depth_m * bulk_density * burn_area_m2 * combustion_coeff


counts_peatlands_low$BG_C_Q25 <- bd_field_peat_low_25 * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000
counts_peatlands_low$BG_C_med <- bd_field_peat_low_med * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000
counts_peatlands_low$BG_C_Q75 <- bd_field_peat_low_75 * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000

counts_peatlands_moderate$BG_C_Q25 <- bd_field_peat_mod_25 * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000
counts_peatlands_moderate$BG_C_med <- bd_field_peat_mod_med * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000
counts_peatlands_moderate$BG_C_Q75 <- bd_field_peat_mod_75 * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000

counts_peatlands_high$BG_C_Q25 <- bd_field_peat_high_25 * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000
counts_peatlands_high$BG_C_med <- bd_field_peat_high_med * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000
counts_peatlands_high$BG_C_Q75 <- bd_field_peat_high_75 * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000



counts_moorlands_low$BG_C_Q25 <- bd_field_heath_low_25 * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000
counts_moorlands_low$BG_C_med <- bd_field_heath_low_med * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000
counts_moorlands_low$BG_C_Q75 <- bd_field_heath_low_75 * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000

counts_moorlands_moderate$BG_C_Q25 <- bd_field_heath_mod_25 * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000
counts_moorlands_moderate$BG_C_med <- bd_field_heath_mod_med * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000
counts_moorlands_moderate$BG_C_Q75 <- bd_field_heath_mod_75 * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000

counts_moorlands_high$BG_C_Q25 <- bd_field_heath_high_25 * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000
counts_moorlands_high$BG_C_med <- bd_field_heath_high_med * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000
counts_moorlands_high$BG_C_Q75 <- bd_field_heath_high_75 * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000





###### Join the dataframes for complete BG emissions

# All moorlands BG emissions scenarios
library(dplyr)

clean_one <- function(df){
  df %>%
    dplyr::select(ID, BG_C_Q25, BG_C_med, BG_C_Q75) %>%
    mutate(across(c(BG_C_Q25, BG_C_med, BG_C_Q75), as.numeric)) %>%
    group_by(ID) %>%
    summarise(across(c(BG_C_Q25, BG_C_med, BG_C_Q75), ~sum(.x, na.rm = TRUE)), .groups = "drop")
}

counts_moorlands_total <- bind_rows(
  clean_one(counts_moorlands_low),
  clean_one(counts_moorlands_moderate),
  clean_one(counts_moorlands_high)
) %>%
  group_by(ID) %>%
  summarise(
    BG_C_Q25 = sum(BG_C_Q25, na.rm = TRUE),
    BG_C_med = sum(BG_C_med, na.rm = TRUE),
    BG_C_Q75 = sum(BG_C_Q75, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ID)

counts_moorlands_total


# All peatland BG emissions scenarios

# reuse your clean_one() defined above

counts_peatlands_total <- bind_rows(
  clean_one(counts_peatlands_low),
  clean_one(counts_peatlands_moderate),
  clean_one(counts_peatlands_high)
) %>%
  group_by(ID) %>%
  summarise(
    BG_C_Q25 = sum(BG_C_Q25, na.rm = TRUE),
    BG_C_med = sum(BG_C_med, na.rm = TRUE),
    BG_C_Q75 = sum(BG_C_Q75, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ID)

counts_peatlands_total





#### Join the BG emissions to the main emissions dataframe
library(data.table)
library(dplyr)

# --- Inputs ---
base_path <- paste0(here(),"/Data/C Emissions Sarah/C_emissions_Dava_moor_fire.csv")


# counts_peatlands_total and counts_moorlands_total are assumed to be
# already in your R session and to contain columns:
#   ID, BG_C_Q25, BG_C_med, BG_C_Q75 (or BG_C_75)

# Helper to prefix non-ID columns; also converts "BG_C_" -> "<prefix>"
prefix_metrics <- function(df, prefix = "BG_peat_") {
  stopifnot("ID" %in% names(df))
  nm <- names(df)
  is_metric <- nm != "ID"
  nm_new <- nm
  nm_new[is_metric] <- ifelse(startsWith(nm[is_metric], "BG_C_"),
                              sub("^BG_C_", prefix, nm[is_metric]),
                              paste0(prefix, nm[is_metric]))
  names(df) <- nm_new
  df
}

# Make sure the expected metric cols exist (handle BG_C_Q75 vs BG_C_75)
norm_cols <- function(df) {
  nm <- names(df)
  # If BG_C_75 is present, standardise to BG_C_Q75
  if ("BG_C_75" %in% nm && !("BG_C_Q75" %in% nm)) {
    names(df)[match("BG_C_75", nm)] <- "BG_C_Q75"
  }
  df
}

# 1) Read base table
base_df <- fread(base_path)

# 2) Normalise and prefix peatlands table
counts_peatlands_total <- norm_cols(counts_peatlands_total)
peat_pref <- prefix_metrics(counts_peatlands_total, "BG_peat_")

# 3) Normalise and prefix moorlands table
counts_moorlands_total <- norm_cols(counts_moorlands_total)
moor_pref <- prefix_metrics(counts_moorlands_total, "BG_moor_")

# 4) Join by ID (cast to character to avoid type mismatch)
out <- base_df %>%
  mutate(ID = as.character(ID)) %>%
  left_join(peat_pref %>% mutate(ID = as.character(ID)), by = "ID") %>%
  left_join(moor_pref %>% mutate(ID = as.character(ID)), by = "ID")


## Add AG and BG emissions

# fill all numeric columns' NAs with 0
out <- out %>%
  mutate(across(where(is.numeric), ~ replace(.x, is.na(.x), 0)))


out$peat_AG_BG_Q25 <- out$`AG peatland`+out$BG_peat_Q25
out$peat_AG_BG_med <- out$`AG peatland`+out$BG_peat_med
out$peat_AG_BG_Q75 <- out$`AG peatland`+out$BG_peat_Q75

out$moor_AG_BG_Q25 <- out$`Moorland and Heathland`+out$BG_moor_Q25
out$moor_AG_BG_med <- out$`Moorland and Heathland`+out$BG_moor_med
out$moor_AG_BG_Q75 <- out$`Moorland and Heathland`+out$BG_moor_Q75

out$totalCemissions_tC_Q25 <- out$Woodland + out$Other + out$peat_AG_BG_Q25 + out$moor_AG_BG_Q25
out$totalCemissions_tC_med <- out$Woodland + out$Other + out$peat_AG_BG_med + out$moor_AG_BG_med
out$totalCemissions_tC_Q75 <- out$Woodland + out$Other + out$peat_AG_BG_Q75 + out$moor_AG_BG_Q75


fwrite(out, paste0(here(),"/Data/Dava_total_emissions_AG_BG_field_BD_CBD_national_average.csv"))

sum(out$totalCemissions_tC)
sum(out$totalCemissions_tC_Q25)
sum(out$totalCemissions_tC_med)
sum(out$totalCemissions_tC_Q75)




####### Calculate belowground emissions for Peatlands and Moorlands- Scenario II: field burn depths, field measured BD average, peat emissions over heathlands and bogs

# Variables

### CARBON bulk densities (carbon concentration x soil bulk density) in kg/m3
bulk_density_peat <- 38  # From Abernethy
bulk_density_moorlands <- 58 # From Glenmore
combustion_coeff <- 0.5


# Include field-measured mean burn depths for peatlands and moorlands, for each severity class

bd_field_peat_low_25 <- 0
bd_field_peat_low_med <- 0
bd_field_peat_low_75 <- 0

bd_field_peat_mod_25 <- 0
bd_field_peat_mod_med <- 0.005
bd_field_peat_mod_75 <- 0.015

bd_field_peat_high_25 <- 0
bd_field_peat_high_med <- 0.01
bd_field_peat_high_75 <- 0.025

bd_field_heath_low_25 <- 0.01
bd_field_heath_low_med <- 0.01
bd_field_heath_low_75 <- 0.01

bd_field_heath_mod_25 <- 0
bd_field_heath_mod_med <- 0.01
bd_field_heath_mod_75 <- 0.0225

bd_field_heath_high_25 <- 0.01
bd_field_heath_high_med <- 0.015
bd_field_heath_high_75 <- 0.025

# Formula to calculate C emission per pixel: C_emission = burn_depth_m * bulk_density * burn_area_m2 * combustion_coeff


counts_peatlands_low$BG_C_Q25 <- bd_field_peat_low_25 * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000
counts_peatlands_low$BG_C_med <- bd_field_peat_low_med * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000
counts_peatlands_low$BG_C_Q75 <- bd_field_peat_low_75 * bulk_density_peat * (counts_peatlands_low$count * 100) * combustion_coeff / 1000

counts_peatlands_moderate$BG_C_Q25 <- bd_field_peat_mod_25 * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000
counts_peatlands_moderate$BG_C_med <- bd_field_peat_mod_med * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000
counts_peatlands_moderate$BG_C_Q75 <- bd_field_peat_mod_75 * bulk_density_peat * (counts_peatlands_moderate$count * 100) * combustion_coeff / 1000

counts_peatlands_high$BG_C_Q25 <- bd_field_peat_high_25 * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000
counts_peatlands_high$BG_C_med <- bd_field_peat_high_med * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000
counts_peatlands_high$BG_C_Q75 <- bd_field_peat_high_75 * bulk_density_peat * (counts_peatlands_high$count * 100) * combustion_coeff / 1000



counts_moorlands_low$BG_C_Q25 <- bd_field_heath_low_25 * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000
counts_moorlands_low$BG_C_med <- bd_field_heath_low_med * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000
counts_moorlands_low$BG_C_Q75 <- bd_field_heath_low_75 * bulk_density_moorlands * (counts_moorlands_low$count * 100) * combustion_coeff / 1000

counts_moorlands_moderate$BG_C_Q25 <- bd_field_heath_mod_25 * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000
counts_moorlands_moderate$BG_C_med <- bd_field_heath_mod_med * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000
counts_moorlands_moderate$BG_C_Q75 <- bd_field_heath_mod_75 * bulk_density_moorlands * (counts_moorlands_moderate$count * 100) * combustion_coeff / 1000

counts_moorlands_high$BG_C_Q25 <- bd_field_heath_high_25 * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000
counts_moorlands_high$BG_C_med <- bd_field_heath_high_med * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000
counts_moorlands_high$BG_C_Q75 <- bd_field_heath_high_75 * bulk_density_moorlands * (counts_moorlands_high$count * 100) * combustion_coeff / 1000





###### Join the dataframes for complete BG emissions

# All moorlands BG emissions scenarios
library(dplyr)

clean_one <- function(df){
  df %>%
    dplyr::select(ID, BG_C_Q25, BG_C_med, BG_C_Q75) %>%
    mutate(across(c(BG_C_Q25, BG_C_med, BG_C_Q75), as.numeric)) %>%
    group_by(ID) %>%
    summarise(across(c(BG_C_Q25, BG_C_med, BG_C_Q75), ~sum(.x, na.rm = TRUE)), .groups = "drop")
}

counts_moorlands_total <- bind_rows(
  clean_one(counts_moorlands_low),
  clean_one(counts_moorlands_moderate),
  clean_one(counts_moorlands_high)
) %>%
  group_by(ID) %>%
  summarise(
    BG_C_Q25 = sum(BG_C_Q25, na.rm = TRUE),
    BG_C_med = sum(BG_C_med, na.rm = TRUE),
    BG_C_Q75 = sum(BG_C_Q75, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ID)

counts_moorlands_total


# All peatland BG emissions scenarios

# reuse your clean_one() defined above

counts_peatlands_total <- bind_rows(
  clean_one(counts_peatlands_low),
  clean_one(counts_peatlands_moderate),
  clean_one(counts_peatlands_high)
) %>%
  group_by(ID) %>%
  summarise(
    BG_C_Q25 = sum(BG_C_Q25, na.rm = TRUE),
    BG_C_med = sum(BG_C_med, na.rm = TRUE),
    BG_C_Q75 = sum(BG_C_Q75, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ID)

counts_peatlands_total





#### Join the BG emissions to the main emissions dataframe
library(data.table)
library(dplyr)

# --- Inputs ---
base_path <- paste0(here(),"/Data/C Emissions Sarah/C_emissions_Dava_moor_fire.csv")


# counts_peatlands_total and counts_moorlands_total are assumed to be
# already in your R session and to contain columns:
#   ID, BG_C_Q25, BG_C_med, BG_C_Q75 (or BG_C_75)

# Helper to prefix non-ID columns; also converts "BG_C_" -> "<prefix>"
prefix_metrics <- function(df, prefix = "BG_peat_") {
  stopifnot("ID" %in% names(df))
  nm <- names(df)
  is_metric <- nm != "ID"
  nm_new <- nm
  nm_new[is_metric] <- ifelse(startsWith(nm[is_metric], "BG_C_"),
                              sub("^BG_C_", prefix, nm[is_metric]),
                              paste0(prefix, nm[is_metric]))
  names(df) <- nm_new
  df
}

# Make sure the expected metric cols exist (handle BG_C_Q75 vs BG_C_75)
norm_cols <- function(df) {
  nm <- names(df)
  # If BG_C_75 is present, standardise to BG_C_Q75
  if ("BG_C_75" %in% nm && !("BG_C_Q75" %in% nm)) {
    names(df)[match("BG_C_75", nm)] <- "BG_C_Q75"
  }
  df
}

# 1) Read base table
base_df <- fread(base_path)

# 2) Normalise and prefix peatlands table
counts_peatlands_total <- norm_cols(counts_peatlands_total)
peat_pref <- prefix_metrics(counts_peatlands_total, "BG_peat_")

# 3) Normalise and prefix moorlands table
counts_moorlands_total <- norm_cols(counts_moorlands_total)
moor_pref <- prefix_metrics(counts_moorlands_total, "BG_moor_")

# 4) Join by ID (cast to character to avoid type mismatch)
out <- base_df %>%
  mutate(ID = as.character(ID)) %>%
  left_join(peat_pref %>% mutate(ID = as.character(ID)), by = "ID") %>%
  left_join(moor_pref %>% mutate(ID = as.character(ID)), by = "ID")


## Add AG and BG emissions

# fill all numeric columns' NAs with 0
out <- out %>%
  mutate(across(where(is.numeric), ~ replace(.x, is.na(.x), 0)))


out$peat_AG_BG_Q25 <- out$`AG peatland`+out$BG_peat_Q25
out$peat_AG_BG_med <- out$`AG peatland`+out$BG_peat_med
out$peat_AG_BG_Q75 <- out$`AG peatland`+out$BG_peat_Q75

out$moor_AG_BG_Q25 <- out$`Moorland and Heathland`+out$BG_moor_Q25
out$moor_AG_BG_med <- out$`Moorland and Heathland`+out$BG_moor_med
out$moor_AG_BG_Q75 <- out$`Moorland and Heathland`+out$BG_moor_Q75

out$totalCemissions_tC_Q25 <- out$Woodland + out$Other + out$peat_AG_BG_Q25 + out$moor_AG_BG_Q25
out$totalCemissions_tC_med <- out$Woodland + out$Other + out$peat_AG_BG_med + out$moor_AG_BG_med
out$totalCemissions_tC_Q75 <- out$Woodland + out$Other + out$peat_AG_BG_Q75 + out$moor_AG_BG_Q75


fwrite(out, paste0(here(),"/Data/Dava_total_emissions_AG_BG_field_BD_CBD_field_measured.csv"))

sum(out$totalCemissions_tC)
sum(out$totalCemissions_tC_Q25)
sum(out$totalCemissions_tC_med)
sum(out$totalCemissions_tC_Q75)
