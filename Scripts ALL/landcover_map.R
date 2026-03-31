# --- Packages ---
library(terra)
library(sf)
library(dplyr)
library(ggplot2)
library(ggspatial)
library(grid)      # for unit()
library(cowplot)

# --- Inputs ---
perim_shp <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/burnt_area_effis/Dava_fire_perimeter.shp"
lc_path   <- "C:/Users/jscho/OneDrive - University of Cambridge/Moorayshire Wildfire Data/Land cover map/ukregion-scotland.tif"

# --- Original LC key (21 classes) ---
lc_codes <- 1:21
lc_names <- c(
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

# --- Load + clip to perimeter (fast path) ---
perim <- terra::vect(perim_shp)
lc    <- terra::rast(lc_path)
perim_lc <- if (!terra::same.crs(perim, lc)) terra::project(perim, terra::crs(lc)) else perim
lc_cm    <- terra::mask(terra::crop(lc, perim_lc, snap = "out"), perim_lc)
lc1      <- lc_cm[[1]]

# =========================
# A) Original land-cover map
# =========================
lc1_ll   <- terra::project(lc1, "EPSG:4326", method = "near")
perim_ll <- terra::project(perim_lc, "EPSG:4326") |> sf::st_as_sf()

df_orig <- as.data.frame(lc1_ll, xy = TRUE, na.rm = TRUE)
names(df_orig) <- c("lon", "lat", "lc_id")
df_orig$lc_id <- as.integer(df_orig$lc_id)

present_ids   <- sort(unique(df_orig$lc_id))
present_names <- lc_names[match(present_ids, lc_codes)]
present_cols  <- lc_cols [match(present_ids, lc_codes)]
names(present_cols) <- present_names

df_orig$lc_name <- factor(df_orig$lc_id, levels = present_ids, labels = present_names)

# Common bbox
bb <- sf::st_bbox(perim_ll)

# Helper: styled map with your requested placements
make_map <- function(df, fill_col, fill_name, col_vec, perim, bb) {
  ggplot() +
    geom_raster(
      data = df,
      aes(x = lon, y = lat, fill = .data[[fill_col]]),
      interpolate = FALSE, na.rm = TRUE
    ) +
    geom_sf(data = perim, fill = NA, colour = "black", linewidth = 0.01) +
    scale_fill_manual(values = col_vec, name = fill_name, drop = FALSE) +
    coord_sf(
      crs  = sf::st_crs(4326),
      xlim = c(bb["xmin"], bb["xmax"]),
      ylim = c(bb["ymin"], bb["ymax"]),
      expand = FALSE
    ) +
    labs(x = "Longitude (°)", y = "Latitude (°)", title = NULL) +
    theme_bw(base_size = 11) +
    theme(
      panel.grid           = element_blank(),
      # Legend: bottom-right inside panel
      legend.position      = c(0.97, 0.08),
      legend.justification = c("right", "bottom"),
      legend.direction     = "vertical",
      legend.background    = element_rect(fill = scales::alpha("white", 0.8),
                                          colour = "grey60"),
      legend.title         = element_text(),
      legend.key.height    = unit(0.45, "cm"),
      legend.key.width     = unit(0.45, "cm")
    ) +
    # Scale bar: bottom-centre (use BL anchor + big pad_x in 'npc' to push to centre)
    ggspatial::annotation_scale(
      location = "bl",
      width_hint = 0.25,
      pad_x = unit(0.7, "npc"),   # ~center; tweak 0.38–0.45 if needed
      pad_y = unit(0.35, "cm")
    ) +
    # North arrow: top-left
    ggspatial::annotation_north_arrow(
      location = "tl",
      which_north = "true",
      style = north_arrow_fancy_orienteering,
      pad_x = unit(0.35, "cm"),
      pad_y = unit(0.35, "cm")
    )
}

p_orig <- make_map(
  df = df_orig, fill_col = "lc_name",
  fill_name = "Land cover",
  col_vec = present_cols, perim = perim_ll, bb = bb
)

library(stringr)

legend_cols <- 2
wrap_width  <- 16  # or nudge smaller/bigger as you like

labs_wrapped <- str_wrap(present_names, width = wrap_width)

p_orig <- p_orig +
  scale_fill_manual(
    values = setNames(present_cols, present_names),
    breaks = present_names,
    labels = labs_wrapped,
    name   = "Land cover"
  ) +
  guides(
    fill = guide_legend(
      ncol      = legend_cols,
      byrow     = TRUE,
      title.position = "top",
      # widen each column but keep square keys
      keywidth  = unit(0.55, "cm"),
      keyheight = unit(0.55, "cm")
    )
  ) +
  theme(
    # keep keys square & a bit larger
    legend.key.width   = unit(0.55, "cm"),
    legend.key.height  = unit(0.55, "cm"),
    legend.key.size    = unit(0.55, "cm"),
    # add spacing BETWEEN columns
    legend.spacing.x   = unit(0.35, "cm"),
    # (optional) a touch of extra line spacing inside items
    legend.text        = element_text(lineheight = 1.05)
  )


# =========================
# B) Recoded 4-class map
# =========================
lc4 <- terra::ifel(lc1 == 11, 1,
                   terra::ifel(lc1 %in% c(9,10), 2,
                               terra::ifel(lc1 == 2, 3, 4)))

lc4_names <- c("Peatlands", "Moorlands and Heathlands",
               "Forests and woodlands", "Other Natural and Managed Lands")

lc4_cols <- c(
  "Peatlands"                       = "#008073",
  "Moorlands and Heathlands"        = "#801A80",
  "Forests and woodlands"           = "#006600",
  "Other Natural and Managed Lands" = "#D9D9D9"
)

lc4_ll  <- terra::project(lc4, "EPSG:4326", method = "near")
df_rec  <- as.data.frame(lc4_ll, xy = TRUE, na.rm = TRUE)
names(df_rec) <- c("lon","lat","class4")
df_rec$class4 <- factor(df_rec$class4, levels = 1:4, labels = lc4_names)
lc4_cols <- lc4_cols[levels(df_rec$class4)]

p_recoded <- make_map(
  df = df_rec, fill_col = "class4",
  fill_name = "Land cover (recoded)",
  col_vec = lc4_cols, perim = perim_ll, bb = bb
)

# =========================
# C) Stack vertically
# =========================
combo <- cowplot::plot_grid(
  p_orig, p_recoded,
  ncol = 1, rel_heights = c(1, 1),
  labels = c("a", "b"), label_size = 12, label_fontface = "bold"
)
print(combo)







# Optional save
# ggsave("C:/Users/jscho/Documents/Scotland Megafire/LC_original_vs_recoded_layout.png",
#        combo, width = 9, height = 12, dpi = 300)
