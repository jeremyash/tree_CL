library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
library(sp)
library(rgeos)
library(raster) ###REQUIRES RASTER 2.17-15
library(rgdal)
library(scales)
library(units)
library(rasterVis)
library(viridis)
library(maps)
library(sf)
library(extrafont)
library(RColorBrewer)
#----------------------------------------------------------------------------


########################################
## FUNCTIONS
########################################
# 
# raster_to_df <- function(RASTER) {
#   # test_spdf <- as(RASTER, "SpatialPixelsDataFrame")
#   # test_df <- as.data.frame(test_spdf)
#   # colnames(test_df) <- c("value", "x", "y")
#   # return(test_df)
#   # 
#   
#   test_df <- rasterToPoints(RASTER)
#   test_df <- data.frame(test_df)
#   colnames(test_df) <- c("x", "y", "value")
#   return(test_df)
# }



raster_to_df <- function(x) {
  nl <- nlayers(x)
  # x <- sampleRegular(x, maxpixels, asRaster=TRUE)
  coords <- xyFromCell(x, seq_len(ncell(x)))
  ## Extract values 
  dat <- stack(as.data.frame(getValues(x)))
  names(dat) <- c('value', 'variable')
  dat <- cbind(coords, dat[1])
}




########################################
## functions + font misc
########################################


theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text(family = "Rockwell", color = "#22211d"),
      plot.title = element_text(face = "bold"),
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "#ebebe5", size = 0.4),
      # panel.grid.major = element_line(color = "#ebebe5", size = 0.8),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      plot.background = element_rect(fill = "white", color = NA), 
      panel.background = element_rect(fill = "white", color = NA), 
      legend.background = element_rect(fill = "white", color = NA),
      panel.border = element_blank(),
      legend.position = "bottom",
      ...
    )
}



#----------------------------------------------------------------------------



########################################
## load gis and raster data
########################################

# base states map
states_sh <- readOGR("gis/lower_48")
states_sh <- spTransform(states_sh, CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
states_df <- broom::tidy(states_sh)
states_sf <- st_as_sf(states_sh)

#forown
forown <- raster("gis/forown.tif")


########################################
## s531
########################################

# basal area
s531_ba <- raster("test/s531.tif") 
# plot(s531_ba)
s531_ba_df <- raster_to_df(s531_ba) # 5gb 


# proportion basal area
s531_prop <- raster("test/s531_proportion.tif") 
# plot(s531_prop)

##Exceedance
# s growth
s531_s_growth <- raster("test/s531_proportion_exc_s_growth.tif")
# plot(s531_s_growth)

# s survival
s531_s_survival <- raster("test/s531_proportion_exc_s_survival.tif")
# plot(s531_s_survival)

# n growth
s531_n_growth <- raster("test/s531_proportion_exc_n_growth.tif")
# plot(s531_n_growth)

# n survival
s531_n_survival <- raster("test/s531_proportion_exc_n_survival.tif")
# plot(s531_n_survival)

##Magnitude of reduction
# s growth
s531_s_growth_red <- raster("test/s531_proportion_exc_s_growth_s_growth_reduction.tif")
# plot(s531_s_growth)

# s survival
s531_s_survival_red <- raster("test/s531_proportion_exc_s_survival_s_survival_reduction.tif")
# plot(s531_s_survival)

# n growth
s531_n_growth_red <- raster("test/s531_proportion_exc_n_growth_n_growth_reduction.tif")
# plot(s531_n_growth_red)

# n survival
s531_n_survival_red <- raster("test/s531_proportion_exc_n_survival_n_survival_reduction.tif")
# plot(s531_n_survival)


# generate lower res data for developing plots
# base_plot_test <- raster::aggregate(s531_s_growth, fact = 20)
# saveRDS(base_plot_test, "data/plot_test_data.RDS")
test_dat <- readRDS("data/plot_test_data.RDS")


#----------------------------------------------------------------------------



 ########################################
 ## PLOT TESTING
 ########################################
 

# basal area
s531_ba[s531_ba == 0] <- NA # remove zero values
# s531_ba <- crop(s531_ba, states_sh)

ggplot() +
  geom_tile(aes(x,y,fill = s531), data  = s531_ba_df)


ba_gg <- gplot(s531_ba) +
  geom_tile(aes(fill = value)) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Basal Area") +
  theme_map() +
  theme(
    legend.position = c(0.5, 0.02),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
  scale_fill_viridis(option = "viridis", 
                     na.value="transparent",
                     name = expression(paste(m^2, "/ha", sep = "")),
                     direction = -1,
                     guide = guide_colorbar(
                       direction = "horizontal",
                       barheight = unit(5, units = "mm"),
                       barwidth = unit(150, units = "mm"),
                       draw.ulim = F,
                       title.position = 'left',
                       # some shifting around
                       title.hjust = 0.5,
                       title.vjust = 1,
                       label.hjust = 0.5,
                       label.position = "bottom"
                     )) 
  
ggsave("figures/test_ba.jpg",
        height = 8.5,
        width = 11, 
        units = "in")

# embed_fonts(file="figures/test_ba.pdf", outfile="figures/test_ba_embed.pdf") 
#-----

# proportional basal area

s531_prop[s531_prop == 0] <- NA # remove zero values

pba_gg <- gplot(s531_prop) +
  geom_tile(aes(fill = value)) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Proportional Basal Area") +
  theme_map() +
  theme(
    legend.position = c(0.5, 0.02),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
  scale_fill_viridis(option = "viridis", 
                     na.value="transparent",
                     name = "%",
                     direction = -1,
                     guide = guide_colorbar(
                       direction = "horizontal",
                       barheight = unit(5, units = "mm"),
                       barwidth = unit(150, units = "mm"),
                       draw.ulim = F,
                       title.position = 'left',
                       # some shifting around
                       title.hjust = 0.5,
                       title.vjust = 1,
                       label.hjust = 0.5,
                       label.position = "bottom"
                     ))

ggsave("figures/test_propba.jpg",
       height = 8.5,
       width = 11, 
       units = "in")

#---
# s growth reduction
s531_s_growth_red[s531_s_growth_red == 0] <- NA # remove zero values

col_pal <- brewer_pal(palette = "RdYlBu")(6)


s531_s_growth_red[s531_s_growth_red < 0] <- "0"
s531_s_growth_red[s531_s_growth_red < 0.01 & s531_s_growth_red > 0] <- "0-0.01"
s531_s_growth_red[s531_s_growth_red < 0.05 & s531_s_growth_red >= 0.01] <- "0.01-0.05"
s531_s_growth_red[s531_s_growth_red < 0.1 & s531_s_growth_red >= 0.05] <- "0.05-0.1"
s531_s_growth_red[s531_s_growth_red < 0.2 & s531_s_growth_red >= 0.1] <- "0.1-0.2"
s531_s_growth_red[s531_s_growth_red >= 0.2] <- ">0.2"

levels(s531_s_growth_red) <- data.frame(ID = 1:6, 
                                        red_levels = c("0", 
                               "0-0.01",
                               "0.01-0.05",
                               "0.05-0.1", 
                               "0.1-0.2",
                               ">0.2"))

# levelplot(s531_s_growth_red)

red_labels <- c("0", 
                "0-0.01",
                "0.01-0.05",
                "0.05-0.1", 
                "0.1-0.2",
                ">0.2",
                "")

s_gr_red_gg <- gplot(s531_s_growth_red) +
  geom_tile(aes(fill = factor(value))) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Proportion Reduction in Growth - S") +
  theme_map() +
  theme(
    legend.position = c(0.55, 0.03),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
    scale_fill_manual(
      values = rev(col_pal),
      # breaks = red_labels,
      name = NULL,
      drop = FALSE,
      labels = red_labels,
      guide = guide_legend(
        direction = "horizontal",
        keyheight = unit(5, units = "mm"),
        keywidth = unit(25, units = "mm"),
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 1,
        nrow = 1,
        byrow = T,
        reverse = F,
        label.position = "bottom"
      )
    )
  # scale_fill_viridis(option = "inferno", 
  #                    na.value="transparent",
  #                    name = "%",
  #                    direction = -1,
  #                    guide = guide_colorbar(
  #                      direction = "horizontal",
  #                      barheight = unit(5, units = "mm"),
  #                      barwidth = unit(150, units = "mm"),
  #                      draw.ulim = F,
  #                      title.position = 'left',
  #                      # some shifting around
  #                      title.hjust = 0.5,
  #                      title.vjust = 1,
  #                      label.hjust = 0.5,
  #                      label.position = "bottom"
  #                    ))



ggsave("figures/test_red_growth_s.jpg",
       plot = s_gr_red_gg,
       height = 8.5,
       width = 11, 
       units = "in")


# Extract legend from ggplot object
extractLegend <- function(gg) {
  grobs <- ggplot_gtable(ggplot_build(gg))
  foo <- which(sapply(grobs$grobs, function(x) x$name) == "guide-box")
  grobs$grobs[[foo]]
}

# Extract wanted legend
wantedLegend <- extractLegend(s_gr_red_gg)
# saveRDS(wantedLegend, "data/reduction_plot_legend.RDS")


#---
# s survival reduction
s531_s_survival_red[s531_s_survival_red == 0] <- NA # remove zero values

col_pal <- brewer_pal(palette = "RdYlBu")(6)


s531_s_survival_red[s531_s_survival_red < 0] <- "0"
s531_s_survival_red[s531_s_survival_red < 0.01 & s531_s_survival_red > 0] <- "0-0.01"
s531_s_survival_red[s531_s_survival_red < 0.05 & s531_s_survival_red >= 0.01] <- "0.01-0.05"
s531_s_survival_red[s531_s_survival_red < 0.1 & s531_s_survival_red >= 0.05] <- "0.05-0.1"
s531_s_survival_red[s531_s_survival_red < 0.2 & s531_s_survival_red >= 0.1] <- "0.1-0.2"
s531_s_survival_red[s531_s_survival_red >= 0.2] <- ">0.2"

levels(s531_s_survival_red) <- data.frame(ID = 1:6, 
                                        red_levels = c("0", 
                                                       "0-0.01",
                                                       "0.01-0.05",
                                                       "0.05-0.1", 
                                                       "0.1-0.2",
                                                       ">0.2"))

# levelplot(s531_s_survival_red)

red_labels <- c("0", 
                "0-0.01",
                "0.01-0.05",
                "0.05-0.1", 
                "0.1-0.2",
                ">0.2",
                "")

s_su_red_gg <- gplot(s531_s_survival_red) +
  geom_tile(aes(fill = factor(value))) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Proportion Reduction in Survival - S") +
  theme_map() +
  theme(
    legend.position = c(0.55, 0.03),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
  scale_fill_manual(
    values = c(rev(col_pal), "white"),
    # breaks = red_labels,
    name = NULL,
    drop = FALSE,
    labels = red_labels,
    guide = guide_legend(
      direction = "horizontal",
      keyheight = unit(5, units = "mm"),
      keywidth = unit(25, units = "mm"),
      title.position = 'top',
      title.hjust = 0.5,
      label.hjust = 1,
      nrow = 1,
      byrow = T,
      reverse = F,
      label.position = "bottom"
    )
  )
# scale_fill_viridis(option = "inferno", 
#                    na.value="transparent",
#                    name = "%",
#                    direction = -1,
#                    guide = guide_colorbar(
#                      direction = "horizontal",
#                      barheight = unit(5, units = "mm"),
#                      barwidth = unit(150, units = "mm"),
#                      draw.ulim = F,
#                      title.position = 'left',
#                      # some shifting around
#                      title.hjust = 0.5,
#                      title.vjust = 1,
#                      label.hjust = 0.5,
#                      label.position = "bottom"
#                    ))


# Extract grobs from plot
s_su_red_gg_update <- ggplot_gtable(ggplot_build(s_su_red_gg))
foo <- which(sapply(s_su_red_gg_update$grobs, function(x) x$name) == "guide-box")
# Replace legend with wanted legend
wantedLegend <- readRDS("data/reduction_plot_legend.RDS")
s_su_red_gg_update$grobs[[foo]] <- wantedLegend
plot(s_su_red_gg_update)


ggsave("figures/test_red_survival_s.jpg",
       s_su_red_gg_update,
       height = 8.5,
       width = 11, 
       units = "in")
#---
# n growth reduction
s531_n_growth_red[s531_n_growth_red == 0] <- NA # remove zero values

col_pal <- brewer_pal(palette = "RdYlBu")(6)


s531_n_growth_red[s531_n_growth_red < 0] <- "0"
s531_n_growth_red[s531_n_growth_red < 0.01 & s531_n_growth_red > 0] <- "0-0.01"
s531_n_growth_red[s531_n_growth_red < 0.05 & s531_n_growth_red >= 0.01] <- "0.01-0.05"
s531_n_growth_red[s531_n_growth_red < 0.1 & s531_n_growth_red >= 0.05] <- "0.05-0.1"
s531_n_growth_red[s531_n_growth_red < 0.2 & s531_n_growth_red >= 0.1] <- "0.1-0.2"
s531_n_growth_red[s531_n_growth_red >= 0.2] <- ">0.2"

levels(s531_n_growth_red) <- data.frame(ID = 1:6, 
                                        red_levels = c("0", 
                                                       "0-0.01",
                                                       "0.01-0.05",
                                                       "0.05-0.1", 
                                                       "0.1-0.2",
                                                       ">0.2"))

# levelplot(s531_n_growth_red)

red_labels <- c("0", 
                "0-0.01",
                "0.01-0.05",
                "0.05-0.1", 
                "0.1-0.2",
                ">0.2",
                "")

n_gr_red_gg <- gplot(s531_n_growth_red) +
  geom_tile(aes(fill = factor(value))) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Proportion Reduction in Growth - N") +
  theme_map() +
  theme(
    legend.position = c(0.55, 0.03),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
  scale_fill_manual(
    values = rev(col_pal),
    # breaks = red_labels,
    name = NULL,
    drop = FALSE,
    labels = red_labels,
    guide = guide_legend(
      direction = "horizontal",
      keyheight = unit(5, units = "mm"),
      keywidth = unit(25, units = "mm"),
      title.position = 'top',
      title.hjust = 0.5,
      label.hjust = 1,
      nrow = 1,
      byrow = T,
      reverse = F,
      label.position = "bottom"
    )
  )
# scale_fill_viridis(option = "inferno", 
#                    na.value="transparent",
#                    name = "%",
#                    direction = -1,
#                    guide = guide_colorbar(
#                      direction = "horizontal",
#                      barheight = unit(5, units = "mm"),
#                      barwidth = unit(150, units = "mm"),
#                      draw.ulim = F,
#                      title.position = 'left',
#                      # some shifting around
#                      title.hjust = 0.5,
#                      title.vjust = 1,
#                      label.hjust = 0.5,
#                      label.position = "bottom"
#                    ))

# Extract grobs from plot
s531_n_growth_red_plot_update <- ggplot_gtable(ggplot_build(s531_n_growth_red_plot))
foo <- which(sapply(s531_n_growth_red_plot_update$grobs, function(x) x$name) == "guide-box")
# Replace legend with wanted legend
s531_n_growth_red_plot_update$grobs[[foo]] <- wantedLegend
plot(s531_n_growth_red_plot_update)

ggsave("figures/test_red_growth_n.jpg",
       plot = s531_n_growth_red_plot_update,
       height = 8.5,
       width = 11, 
       units = "in")



#---
# n survival reduction
s531_n_survival_red[s531_n_survival_red == 0] <- NA # remove zero values

col_pal <- brewer_pal(palette = "RdYlBu")(6)


s531_n_survival_red[s531_n_survival_red < 0] <- "0"
s531_n_survival_red[s531_n_survival_red < 0.01 & s531_n_survival_red > 0] <- "0-0.01"
s531_n_survival_red[s531_n_survival_red < 0.05 & s531_n_survival_red >= 0.01] <- "0.01-0.05"
s531_n_survival_red[s531_n_survival_red < 0.1 & s531_n_survival_red >= 0.05] <- "0.05-0.1"
s531_n_survival_red[s531_n_survival_red < 0.2 & s531_n_survival_red >= 0.1] <- "0.1-0.2"
s531_n_survival_red[s531_n_survival_red >= 0.2] <- ">0.2"

levels(s531_n_survival_red) <- data.frame(ID = 1:6, 
                                          red_levels = c("0", 
                                                         "0-0.01",
                                                         "0.01-0.05",
                                                         "0.05-0.1", 
                                                         "0.1-0.2",
                                                         ">0.2"))

# levelplot(s531_n_survival_red)

red_labels <- c("0", 
                "0-0.01",
                "0.01-0.05",
                "0.05-0.1", 
                "0.1-0.2",
                ">0.2",
                "")

s531_n_survival_red_plot <- gplot(s531_n_survival_red) +
  geom_tile(aes(fill = factor(value))) +
  geom_polygon(aes(long, lat, group = group), 
               fill = NA, 
               size = 0.8, 
               color = "grey15", 
               data = states_df) +
  labs(title = "Proportion Reduction in Survival - N") +
  theme_map() +
  theme(
    legend.position = c(0.55, 0.03),
    legend.text.align = 0,
    legend.background = element_rect(fill = alpha('white', 0.0)),
    legend.text = element_text(size = 14, hjust = 0, color = "#4e4d47", face = "bold"),
    plot.title = element_text(size = 40, hjust = 0.5, vjust = -15, color = "black", face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                 margin = margin(b = -0.1, 
                                                 t = -0.1, 
                                                 l = 2, 
                                                 unit = "cm"), 
                                 debug = F),
    legend.title = element_text(size = 16),
    plot.margin = unit(c(0.2,.2,.2,.2), "cm"),
    panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
    panel.border = element_blank(),
    plot.caption = element_text(size = 6, 
                                hjust = 0.92, 
                                margin = margin(t = 0.2, 
                                                b = 0, 
                                                unit = "cm"), 
                                color = "#939184")) +
  scale_fill_manual(
    values = c(rev(col_pal), "white"),
    # breaks = red_labels,
    name = NULL,
    drop = FALSE,
    labels = red_labels,
    guide = guide_legend(
      direction = "horizontal",
      keyheight = unit(5, units = "mm"),
      keywidth = unit(25, units = "mm"),
      title.position = 'top',
      title.hjust = 0.5,
      label.hjust = 1,
      nrow = 1,
      byrow = T,
      reverse = F,
      label.position = "bottom"
    )
  )
# scale_fill_viridis(option = "inferno", 
#                    na.value="transparent",
#                    name = "%",
#                    direction = -1,
#                    guide = guide_colorbar(
#                      direction = "horizontal",
#                      barheight = unit(5, units = "mm"),
#                      barwidth = unit(150, units = "mm"),
#                      draw.ulim = F,
#                      title.position = 'left',
#                      # some shifting around
#                      title.hjust = 0.5,
#                      title.vjust = 1,
#                      label.hjust = 0.5,
#                      label.position = "bottom"
#                    ))


# Extract grobs from plot
s531_n_survival_red_plot_update <- ggplot_gtable(ggplot_build(s531_n_survival_red_plot))
foo <- which(sapply(s531_n_survival_red_plot_update$grobs, function(x) x$name) == "guide-box")
# Replace legend with wanted legend
s531_n_survival_red_plot_update$grobs[[foo]] <- wantedLegend
plot(s531_n_survival_red_plot_update)


ggsave("figures/test_red_survival_n.jpg",
       s531_n_survival_red_plot_update,
       height = 8.5,
       width = 11, 
       units = "in")
 #----------------------------------------------------------------------------
 
 
########################################
## other attempts
########################################

plot(states_sh, 
     col = "grey80",
     border = NA)

plot(test_dat,
     col = viridis(10, direction = -1),
     asp=1, 
     axes=FALSE, 
     xaxs="i", 
     xaxt='n', 
     yaxt='n',
     add=TRUE)



# with rastervis

colr <- colorRampPalette(brewer.pal(11, 'RdYlBu'))

system.time(
  levelplot(test_dat, 
            margin=FALSE,                       # suppress marginal graphics
            colorkey=list(
              space='bottom',                   # plot legend at bottom
              labels=list(at=-5:5, font=4)      # legend ticks and labels 
            ),    
            par.settings=list(
              axis.line=list(col='transparent') # suppress axes and legend outline
            ),
            main = "Basal Area",
            scales=list(draw=FALSE),            # suppress axis labels
            col.regions=colr,                   # colour ramp
            at=seq(-5, 5, len=101)) +            # colour ramp breaks
    layer(sp.polygons(states_sh, lwd=3))           # add oregon SPDF with latticeExtra::layer
)






# usa <- map_data("usa")
# usa_mat <- matrix(c(usa$long, usa$lat), ncol = 2)
# usa_poly <- Polygon(usa_mat)
# usa_polys <- Polygons(list(usa_poly), 1)
# usa_sp_poly <- SpatialPolygons(list(usa_polys), proj4string = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))



#----------------------------------------------------------------------------






