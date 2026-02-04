###### Facet plot the three C emissions scenarios:
# Three side-by-side maps with the same colour scale
library(terra)
library(sf)
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggspatial)
library(grid)
library(scales)
library(here)

# --- 1) Load data -------------------------------------------------------------
csv <- paste0(here(),"/Dava_total_emissions_AG_BG_field_BD.csv")
fire_path <- paste0(here(),"/Data/burnt_area_effis/Dava_fire_perimeter.shp")

df <- data.table::fread(csv)
stopifnot(all(c("x","y",
                "totalCemissions_tC_Q25",
                "totalCemissions_tC_med",
                "totalCemissions_tC_Q75") %in% names(df)))

crs_epsg <- 27700
crs_str  <- paste0("EPSG:", crs_epsg)

# --- 2) Raster template -------------------------------------------------------
pts <- terra::vect(df, geom = c("x","y"), crs = crs_str)

dx <- stats::median(diff(sort(unique(df$x))), na.rm = TRUE)
dy <- stats::median(diff(sort(unique(df$y))), na.rm = TRUE)
if (!is.finite(dx) || dx <= 0) dx <- (max(df$x) - min(df$x)) / 200
if (!is.finite(dy) || dy <= 0) dy <- (max(df$y) - min(df$y)) / 200

ext <- terra::ext(min(df$x) - dx/2, max(df$x) + dx/2,
                  min(df$y) - dy/2, max(df$y) + dy/2)
r_tmpl <- terra::rast(ext, resolution = c(dx, dy), crs = crs_str)

# --- 3) Rasterise the three fields onto the same grid -------------------------
r_q25 <- terra::rasterize(pts, r_tmpl, field = "totalCemissions_tC_Q25", fun = "mean")
r_med <- terra::rasterize(pts, r_tmpl, field = "totalCemissions_tC_med", fun = "mean")
r_q75 <- terra::rasterize(pts, r_tmpl, field = "totalCemissions_tC_Q75", fun = "mean")
names(r_q25) <- "Q25"; names(r_med) <- "Median"; names(r_q75) <- "Q75"

r_stack <- c(r_q25, r_med, r_q75)

# --- 4) Fire perimeter + crop/mask (nice edges) --------------------------------
fire <- sf::st_read(fire_path, quiet = TRUE)
if (!is.na(sf::st_crs(fire)) && sf::st_crs(fire)$epsg != crs_epsg) {
  fire <- sf::st_transform(fire, crs_epsg)
}
r_stack <- terra::mask(terra::crop(r_stack, terra::vect(fire)), terra::vect(fire))

# --- 5) One long dataframe for faceting ---------------------------------------
r_df <- as.data.frame(r_stack, xy = TRUE, na.rm = FALSE) |>
  tidyr::pivot_longer(
    cols = c(Q25, Median, Q75),
    names_to = "scenario",
    values_to = "tC"
  )

# Order facets: Q25, Median, Q75
r_df$scenario <- factor(r_df$scenario, levels = c("Q25", "Median", "Q75"))

# Shared colour limits across all three
fill_limits <- range(r_df$tC, na.rm = TRUE)

bb <- sf::st_bbox(fire)
lab_km <- scales::label_number(scale = 1/1000, accuracy = 1, suffix = " km")

# --- 6) Plot: three facets side-by-side, same fill scale ----------------------
# keep only in-range raster cells
r_df_plot <- dplyr::filter(r_df, !is.na(tC))

p3 <- ggplot() +
  geom_raster(data = r_df_plot, aes(x = x, y = y, fill = tC)) +
  geom_sf(data = fire, fill = NA, colour = "black", linewidth = 0.6) +
  scale_fill_gradient(low = "#F7E8F4", high = "#A02B93",
                      limits = fill_limits, oob = scales::squish,
                      na.value = NA, name = "Total C (t C)") +
  coord_sf(xlim = c(bb["xmin"], bb["xmax"]),
           ylim = c(bb["ymin"], bb["ymax"]),
           crs = sf::st_crs(fire), datum = NA, expand = FALSE) +
  facet_wrap(~ scenario, nrow = 1) +
  # … your scale_x/y + annotations …
  theme_bw(base_size = 11) +
  theme(
    panel.grid        = element_blank(),
    panel.background  = element_rect(fill = "white", colour = NA),
    plot.background   = element_rect(fill = "white", colour = NA),
    strip.background  = element_rect(fill = "grey60", colour = "grey60")
  )

print(p3)






######### Facet plot with categories for field-measured peat burn depths

# Packages
library(data.table)
library(ggplot2)

# ---- Load data
csv <- paste0(here(),"/Data/Fieldwork and data/PDP_points_landcover_sev.csv")
dt  <- fread(csv)

stopifnot(all(c("Depth","landcover1","dNBR1") %in% names(dt)))
dt[, Depth := as.numeric(Depth)]     # ensure numeric
dt <- dt[!is.na(Depth) & !is.na(landcover1) & !is.na(dNBR1)]

# ---- Landcover names + colours (RGB -> hex)

lc_codes  <- 1:21
lc_names  <- c(
  "Broadleaved woodland","Coniferous Woodland","Arable and Horticulture",
  "Improved Grassland","Neutral Grassland","Calcareous Grassland",
  "Acid grassland","Fen, Marsh and Swamp","Heather","Heather grassland",
  "Bog","Inland Rock","Saltwater","Freshwater","Supralittoral Rock",
  "Supralittoral Sediment","Littoral Rock","Littoral sediment",
  "Saltmarsh","Urban","Suburban"
)
lc_cols <- c(
  "#FF0000","#006600","#732600","#00FF00","#7FE57F","#70A800","#998100",
  "#FFFF00","#801A80","#E68CA6","#008073","#D2D2FF","#000080","#0000FF",
  "#CCB300","#CCB300","#FFFF80","#FFFF80","#8080FF","#000000","#808080"
)
# factor with labels and a named colour vector
dt[, landcover1_f := factor(landcover1, levels = lc_codes, labels = lc_names)]
lc_col_vec <- setNames(lc_cols, lc_names)

# Exclude the one point in acid grassland
#dt <- dt %>%
#  filter(landcover1_f != 'Acid grassland')

# ---- dNBR1 as a factor so each unique value gets its own box
if (is.numeric(dt$dNBR_class_v1)) {
  dt[, dNBR1_f := factor(dNBR_class_v1, levels = sort(unique(dNBR_class_v1)))]
} else {
  dt[, dNBR1_f := factor(dNBR_class_v1)]
}

# ---- Precompute sample sizes and label positions
rng   <- range(dt$Depth, na.rm = TRUE)
pad   <- 0.03 * diff(rng)               # a little headroom for labels
n_lab <- dt[, .(n = .N, y_lab = max(Depth, na.rm = TRUE) + pad),
            by = .(landcover1_f, dNBR1_f)]

# ---- Plot (facets share the same y-scale)
p_facets <- ggplot(dt, aes(x = dNBR1_f, y = Depth)) +
  # box colour/fill reflect landcover (constant within facet; legend hidden)
  geom_boxplot(aes(fill = landcover1_f, colour = landcover1_f),
               outlier.shape = NA, width = 0.68, alpha = 0.6) +
  # scatter of individual measurements
  geom_jitter(aes(colour = landcover1_f),
              width = 0.18, height = 0, size = 0.9, alpha = 0.35) +
  # sample size above each box
  geom_text(data = n_lab,
            aes(x = dNBR1_f, y = y_lab, label = paste0("n=", n)),
            inherit.aes = FALSE, size = 3) +
  facet_wrap(~ landcover1_f, scales = "fixed") +   # same y for all facets
  scale_fill_manual(values = lc_col_vec, guide = "none") +
  scale_colour_manual(values = lc_col_vec, guide = "none") +
  scale_x_discrete(labels = c("2" = "low", "3" = "moderate", "4" = "severe"))+
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # top room for labels
  labs(x = "Burn severity (dNBR class)", y = "Peat burn depth (cm)",
       title = "") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.text  = element_text(face = "bold")
  )

p_facets


# --- save (A4 portrait-ish) ---
library(devEMF)
ggsave(
  filename  = "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Figures/PBD_facets_all.emf",
  plot      = p_facets,
  device    = function(filename, ...) devEMF::emf(filename, emfPlus = TRUE, family = "Arial", ...),
  width     = 8.27, height = 4.5, units = "in",
  bg        = "white",
  limitsize = FALSE
)


ggsave(
  filename = "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Figures/PDP_facets_all.pdf",
  plot     = p_facets,
  device   = cairo_pdf,        # vector PDF with good font support
  width    = 8.27, height = 6, units = "in",
  bg       = "white",
  limitsize = FALSE
)



################### Same facet plot, but landcover categories summarised into Sarah's categories: Forests and Woodlands, Moorlands and Heathlands, Peatland
# Packages
library(data.table)
library(dplyr)     # for filter()
library(ggplot2)

# ---- Load data
csv <- paste0(here(),"/Data/Fieldwork and data/PDP_points_landcover_sev.csv")
dt  <- fread(csv)

stopifnot(all(c("Depth","landcover1") %in% names(dt)))
dt[, Depth := as.numeric(Depth)]     # ensure numeric
dt <- dt[!is.na(Depth) & !is.na(landcover1)]

# ---- Landcover names + colours
# 'Bog' replaced with 'Peatland'
lc_codes  <- 1:21
lc_names  <- c(
  "Broadleaved woodland","Forests and Woodlands","Arable and Horticulture",
  "Improved Grassland","Neutral Grassland","Calcareous Grassland",
  "Acid grassland","Fen, Marsh and Swamp","Heather","Heather grassland",
  "Bog","Inland Rock","Saltwater","Freshwater","Supralittoral Rock",
  "Supralittoral Sediment","Littoral Rock","Littoral sediment",
  "Saltmarsh","Urban","Suburban"
)
lc_cols <- c(
  "#FF0000","#006600","#732600","#00FF00","#7FE57F","#70A800","#998100",
  "#FFFF00","#801A80","#E68CA6","#008073","#D2D2FF","#000080","#0000FF",
  "#CCB300","#CCB300","#FFFF80","#FFFF80","#8080FF","#000000","#808080"
)

# Collapse Heather (9) + Heather grassland (10) -> "Moorlands and Heathlands"
# Use Heather colour (#801A80) for the collapsed class
# Build a clean level order/palette to match
level_order <- lc_names
level_order <- append(level_order[-c(9,10)], "Moorlands and Heathlands", after = 8)

cols_ordered <- lc_cols[-c(9,10)]
cols_ordered <- append(cols_ordered, "#801A80", after = 8)  # Heather colour

collapsed_pal <- setNames(cols_ordered, level_order)

# Attach collapsed factor
dt[, landcover1_code := as.integer(landcover1)]
name_by_code <- setNames(lc_names, lc_codes)
dt[, landcover_name_orig := name_by_code[as.character(landcover1_code)]]
dt[, landcover_f := ifelse(landcover1_code %in% c(9,10),
                           "Moorlands and Heathlands",
                           landcover_name_orig)]
dt[, landcover_f := factor(landcover_f, levels = level_order)]

# Optional: drop the one point in Acid grassland (as in your original script)
dt <- dt %>% filter(landcover_f != "Acid grassland")

# ---- dNBR as factor (accept either dNBR_class_v1 or dNBR1)
dnbr_col <- if ("dNBR_class_v1" %in% names(dt)) "dNBR_class_v1" else
  if ("dNBR1" %in% names(dt)) "dNBR1" else
    stop("Neither 'dNBR_class_v1' nor 'dNBR1' found in the data.")
dt <- dt[!is.na(get(dnbr_col))]

dnbr_vals <- dt[[dnbr_col]]
if (is.numeric(dnbr_vals)) {
  dt[, dNBR1_f := factor(get(dnbr_col), levels = sort(unique(dnbr_vals)))]
} else {
  dt[, dNBR1_f := factor(get(dnbr_col))]
}

# ---- Precompute sample sizes and label positions
rng   <- range(dt$Depth, na.rm = TRUE)
pad   <- 0.03 * diff(rng)               # a little headroom for labels
n_lab <- dt[, .(n = .N, y_lab = max(Depth, na.rm = TRUE) + pad),
            by = .(landcover_f, dNBR1_f)]

# ---- Plot (facets share the same y-scale)
p_facets <- ggplot(dt, aes(x = dNBR1_f, y = Depth)) +
  # box colour/fill reflect landcover (constant within facet; legend hidden)
  geom_boxplot(aes(fill = landcover_f, colour = landcover_f),
               outlier.shape = NA, width = 0.68, alpha = 0.6) +
  # scatter of individual measurements
  geom_jitter(aes(colour = landcover_f),
              width = 0.18, height = 0, size = 0.9, alpha = 0.35) +
  # sample size above each box
  geom_text(data = n_lab,
            aes(x = dNBR1_f, y = y_lab, label = paste0("n=", n)),
            inherit.aes = FALSE, size = 3) +
  facet_wrap(~ landcover_f, scales = "fixed") +   # same y for all facets
  scale_fill_manual(values = collapsed_pal, guide = "none", drop = FALSE) +
  scale_colour_manual(values = collapsed_pal, guide = "none", drop = FALSE) +
  scale_x_discrete(labels = c("2" = "low", "3" = "moderate", "4" = "severe")) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # top room for labels
  labs(x = "Burn severity (dNBR class)", y = "Peat burn depth (cm)", title = "") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.text  = element_text(face = "bold")
  )

p_facets

# --- save (A4 portrait-ish) ---
library(devEMF)
ggsave(
  filename  = "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Figures/PBD_facets.emf",
  plot      = p_facets,
  device    = function(filename, ...) devEMF::emf(filename, emfPlus = TRUE, family = "Arial", ...),
  width     = 8.27, height = 4.5, units = "in",
  bg        = "white",
  limitsize = FALSE
)


ggsave(
  filename = "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Figures/PBD_facets_grouped.pdf",
  plot     = p_facets,
  device   = cairo_pdf,        # vector PDF with good font support
  width    = 8.27, height = 4.5, units = "in",
  bg       = "white",
  limitsize = FALSE
)

##### Statistical summary by landcover AND burn severity
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(forcats)
  library(readr)
  library(knitr)
})

# 1) Make sure dNBR classes match your plot labels
dt_sum_base <- dt %>%
  filter(!is.na(Depth), !is.na(landcover_f), !is.na(dNBR1_f)) %>%
  mutate(
    dNBR_class = factor(as.character(dNBR1_f),
                        levels = c("2","3","4"),
                        labels = c("low","moderate","severe"))
  )

# 2) Summary by land cover (facet) x dNBR class (x-axis)
summary_tbl <- dt_sum_base %>%
  group_by(landcover_f, dNBR_class) %>%
  summarise(
    n      = dplyr::n(),
    mean   = mean(Depth, na.rm = TRUE),
    sd     = sd(Depth, na.rm = TRUE),
    median = median(Depth, na.rm = TRUE),
    q25    = quantile(Depth, 0.25, na.rm = TRUE),
    q75    = quantile(Depth, 0.75, na.rm = TRUE),
    iqr    = IQR(Depth, na.rm = TRUE),
    min    = min(Depth, na.rm = TRUE),
    max    = max(Depth, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # 95% CI on the mean (t-based; NA if n <= 1)
  mutate(
    se        = sd / sqrt(pmax(n, 1)),
    t_mult    = ifelse(n > 1, qt(0.975, df = n - 1), NA_real_),
    ci95_low  = mean - t_mult * se,
    ci95_high = mean + t_mult * se
  ) %>%
  arrange(landcover_f, dNBR_class)

# 3) Print a compact table (Depth in cm)
knitr::kable(
  summary_tbl,
  digits = c(NA, NA, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
  caption = "Peat burn depth (cm) by land cover (facets) and dNBR class (x-axis)"
)

# 4) Also write a CSV next to your working file (edit path if you like)
out_csv <- "C:/Users/jscho/Documents/Scotland Megafire/Depth_summary_by_landcover_dNBR.csv"
readr::write_csv(summary_tbl, out_csv)
cat("Wrote summary to:\n", normalizePath(out_csv), "\n", sep = "")

# (Optional) quick “wide” tables you might want for reports:

# Medians per class, wide across dNBR levels
med_wide <- summary_tbl %>%
  select(landcover_f, dNBR_class, median) %>%
  pivot_wider(names_from = dNBR_class, values_from = median)

# Sample sizes per class, wide
n_wide <- dt_sum_base %>%
  count(landcover_f, dNBR_class) %>%
  pivot_wider(names_from = dNBR_class, values_from = n, values_fill = 0)

# Print quick peeks
knitr::kable(med_wide, digits = 2, caption = "Medians (cm) by land cover × dNBR class")
knitr::kable(n_wide, caption = "Sample sizes by land cover × dNBR class")


####### Statistical summary for only landcover
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(knitr)
})

# Filter to valid rows
dt_depth <- dt %>%
  filter(!is.na(Depth), !is.na(landcover_f))

# Summary by land cover only
lc_summary <- dt_depth %>%
  group_by(landcover_f, .drop = TRUE) %>%
  summarise(
    n      = n(),
    mean   = mean(Depth, na.rm = TRUE),
    sd     = sd(Depth, na.rm = TRUE),
    median = median(Depth, na.rm = TRUE),
    q25    = quantile(Depth, 0.25, na.rm = TRUE),
    q75    = quantile(Depth, 0.75, na.rm = TRUE),
    iqr    = IQR(Depth, na.rm = TRUE),
    min    = min(Depth, na.rm = TRUE),
    max    = max(Depth, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    se        = sd / sqrt(pmax(n, 1)),
    t_mult    = ifelse(n > 1, qt(0.975, df = n - 1), NA_real_),
    ci95_low  = mean - t_mult * se,
    ci95_high = mean + t_mult * se
  ) %>%
  arrange(landcover_f)

# Print a neat table
knitr::kable(
  lc_summary,
  digits = c(NA, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
  caption = "Peat burn depth (cm) by land cover"
)





# Faceted maps of total C emissions (tC): Total, Q25, Median, Q75
# Produces a single PNG with 4 facets using ggplot2

suppressPackageStartupMessages({
  library(terra)
  library(data.table)
  library(tidyverse)
})

# --- 1) Load data --------------------------------------------------------------
#csv <- "C:/Users/jscho/Documents/Scotland Megafire/C_emissions_Dava_field.csv"
csv <- paste0(here(),"/Dava_total_emissions_AG_BG_field_BD.csv")
df  <- data.table::fread(csv)

metrics <- c("totalCemissions_tC",
             "totalCemissions_tC_Q25",
             "totalCemissions_tC_med",
             "totalCemissions_tC_Q75")

missing <- setdiff(c("x","y", metrics), names(df))
if (length(missing)) {
  stop("Missing required columns in CSV: ", paste(missing, collapse = ", "))
}

# --- 2) CRS (edit if needed) ---------------------------------------------------
crs_epsg <- 27700                    # OSGB36 / British National Grid
crs_str  <- paste0("EPSG:", crs_epsg)

# Points as SpatVector
pts <- terra::vect(df, geom = c("x","y"), crs = crs_str)

# --- 3) Grid template ----------------------------------------------------------
# Try to infer spacing from unique coords; fall back to a 200×200 grid if needed
dx <- stats::median(diff(sort(unique(df$x))), na.rm = TRUE)
dy <- stats::median(diff(sort(unique(df$y))), na.rm = TRUE)

if (!is.finite(dx) || dx <= 0) dx <- (max(df$x, na.rm = TRUE) - min(df$x, na.rm = TRUE)) / 200
if (!is.finite(dy) || dy <= 0) dy <- (max(df$y, na.rm = TRUE) - min(df$y, na.rm = TRUE)) / 200

# If you know it's exactly 250 m cells, uncomment the next line:
# dx <- dy <- 250

ext <- terra::ext(min(df$x, na.rm = TRUE) - dx/2, max(df$x, na.rm = TRUE) + dx/2,
                  min(df$y, na.rm = TRUE) - dy/2, max(df$y, na.rm = TRUE) + dy/2)

r_tmpl <- terra::rast(ext, resolution = c(dx, dy), crs = crs_str)

# --- 4) Rasterize each metric (point -> cell mean) -----------------------------
rs <- lapply(metrics, function(m) {
  terra::rasterize(pts, r_tmpl, field = m, fun = "mean")
})
r_stack <- terra::rast(rs)
names(r_stack) <- c("Total (tC)", "Q25 (tC)", "Median (tC)", "Q75 (tC)")

# --- 5) (Optional) Save a multi-band GeoTIFF -----------------------------------
out_dir <- dirname(csv)
out_mb  <- file.path(out_dir, "C_emissions_Dava_facets_multiband.tif")
terra::writeRaster(r_stack, out_mb, overwrite = TRUE)

# --- 6) Convert to data frame for ggplot facets --------------------------------
df_r <- as.data.frame(r_stack, xy = TRUE, na.rm = FALSE)

df_long <- df_r |>
  tidyr::pivot_longer(cols = all_of(names(r_stack)),
                      names_to = "metric", values_to = "tC")

metric_levels <- c("Total (tC)", "Q25 (tC)", "Median (tC)", "Q75 (tC)")
df_long <- df_long |>
  mutate(metric = factor(metric, levels = metric_levels))

# --- 7) Plot facets -------------------------------------------------------------
p <- ggplot(df_long, aes(x = x, y = y, fill = tC)) +
  geom_raster(na.rm = FALSE) +
  coord_equal() +
  scale_fill_viridis_c(option = "inferno", na.value = NA, name = "t C") +
  facet_wrap(~ metric, ncol = 2, scales = "fixed") +
  labs(title = "Total C emissions (t C)",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold")
  )

out_png <- file.path(out_dir, "C_emissions_Dava_facets.png")
ggsave(out_png, p, width = 9, height = 7, dpi = 300)

cat("Wrote:\n - ", out_mb, "\n - ", out_png, "\n", sep = "")














