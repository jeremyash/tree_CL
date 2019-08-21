## SPATIAL
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(maptools)

## DATA MANAGEMENT
library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
# library(zoo)
library(pryr)

## PLOTTING
library(scales)
library(units)
library(viridis)
library(extrafont)
library(gtable)
library(grid)
library(rasterVis)
library(RColorBrewer)
library(ComplexHeatmap)
#----------------------------------------------------------------------------

#############################################################################
## functions
#############################################################################


red_exc_plot <- function(VALUE, TITLE, COLS, BREAKS) {
  
  # plot states
  plot(states_sh)
  
  # add panel title
  title(TITLE, line = -1.2, cex = 0.8)
}


########################################
## load gis and raster data
########################################

#forown
# forown <- raster("gis/forown_latlong.tif") 
# forown <- projectRaster(forown, crs = CRS("+init=epsg:4326"))
# writeRaster(forown, "gis/forown_latlong.tif", format = "GTiff", overwrite = TRUE)
forown <- raster("gis/forown_binary_crop.tif") 
new_crs <- proj4string(forown)

# base states map
states_sh <- readOGR("gis/states")
states_sh <- spTransform(states_sh, new_crs)

# species codes and data
sp_names <- read_csv("data/spp_codes.csv")
colnames(sp_names)[4] <- "spp_code"

sp_names <- sp_names %>% 
  mutate(spp_code = paste("s", spp_code, sep = ""))



# This is derived from the full dataset, but I’ve averaged the response for trees of a given species within a plot. So each plot will have a number of rows equal to the number of species in the plot. And each row is the average species response within a plot (which may vary with tree size). I’ve included the responses excluding the increasers (labeled “Mean(PropRed…”, 4 columns for the four responses – N/S by growth/survival), and including the increasers (labeled “Mean(PropChange…”, also 4 columns). For species where the dep has gone below the curve, these are ignored.


red_dat <- read_csv("raw_data/RTI_Tree_Database_2017NOV14_CMC_Horn only_For JA_short.txt") %>% 
  mutate(spp_code = paste("s", SPCD, sep = ""))
colnames(red_dat)[10:13] <- c("red_s_n",
                               "red_s_s",
                               "red_g_n",
                               "red_g_s") 

# fia_plot_dat <- read_csv("raw_data/RTI_Tree_Database_2017NOV14_CMC_Horn only.txt") %>% 
#   mutate(spp_code = paste("s", SPCD, sep = ""))
# colnames(fia_plot_dat)[176] <- "tree_ba_cm"
# 
# 
# 
# plot_ba_dat <- fia_plot_dat %>% 
#   group_by(PLT_CN, LAT, LON) %>%
#   summarise(plot_ba = sum(tree_ba_cm/10000)) %>% 
#   ungroup()
# 
# ba_dat <- fia_plot_dat %>% 
#   group_by(spp_code, PLT_CN, LAT, LON) %>% 
#   summarise(avg_ba = mean(tree_ba_cm/10000)) %>% 
#   ungroup() %>% 
#   left_join(., plot_ba_dat) %>% 
#   mutate(prop_ba = avg_ba/plot_ba)
# 
# 
# plot_dat <- red_dat %>% 
#   left_join(., ba_dat)
# saveRDS(plot_dat, "data/fia_plotting_dat.RDS")
plot_dat <- readRDS("data/fia_plotting_dat.RDS") %>% # remove alaska plots 
  filter(LON > -129)
plot_dat <- SpatialPointsDataFrame(coords = data.frame(x = plot_dat$LON,
                                                          y = plot_dat$LAT),
                                   data = plot_dat,
                                   proj4string = CRS("+init=epsg:4326"))
plot_dat <- spTransform(plot_dat, new_crs)

plot_dat  <- as.data.frame(plot_dat)


########################################
## PLOTTING
########################################

##-------------
## basal area and proportional basal area
##-------------

plot_ba_propba <- function(SP) {
  
  # plot pars
  ba_cols <- rev(viridis(6))
  prop_ba_cols <- c("khaki2", rev(inferno(6))[2:6])
  
  # ba breaks
  sp_ba <- plot_dat %>% 
    filter(spp_code == SP) %>% 
    pull(avg_ba)
  ba_breaks <- quantile(sp_ba, probs = seq(0,1,length.out = 7), na.rm = TRUE)
  
  # prop_ba breaks and labels
  prop_breaks <- c(0,0.05,0.10,0.20,0.40, 0.60, 1)
  prop_labels <- c("<5", "5-10", "10-20", "20-40", "40-60", ">60")
  
  # species plot data
  sp_dat <- plot_dat %>% 
    filter(spp_code == SP) %>% 
    mutate(ba_col = ba_cols[as.numeric(cut(avg_ba, breaks = ba_breaks))],
           prop_ba_col = prop_ba_cols[as.numeric(cut(prop_ba, breaks = prop_breaks, labels = prop_labels))])
  
  # basal area breaks
  ba_levels <- as.data.frame( str_split_fixed(levels(cut(sp_dat$avg_ba, breaks = ba_breaks)), ",", 2)) %>% 
    mutate(low = formatC(round(as.numeric(str_sub(V1, start = 2)), 2), format = 'f', digits = 2),
           high  = formatC(round(as.numeric(str_sub(V2, end = -2)), 2), format = 'f', digits = 2),
           range = paste(low, high, sep = "-")) %>% 
    select(low:range)
  
 
  # species title
  sp_latin <- with(sp_names, paste(GENUS[spp_code == SP], 
                                 SPECIES[spp_code == SP], 
                                 sep = " "))
  
  sp_common <- with(sp_names, COMMON_NAME[spp_code == SP])
  

  
  # multipanel plot 
  pdf(file = paste("figures_md_fia/ba/", SP, "_ba_propba.pdf", sep = ""),
      height = 5,
      width = 10)
  
  par(mar = c(0,0,0,4), 
      mfrow = c(1,2), 
      oma = c(0,0,2,0),
      cex = 0.8)
  
  
  # basal area
  plot(forown,
       
       # total pixels to plot
       # maxpixels = 1e7,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("grey70", "transparent" ))
  
  points(sp_dat$x,
       sp_dat$y,
       
       pch = 16,
       cex = 0.3,
       # colors
       col = sp_dat$ba_col)
  
  plot(states_sh,
       add = TRUE)
  
  # plot(little,
  #      lty = 1,
  #      add = TRUE)
  
  legend(1950000, 2600000,
         legend = ba_levels$range,
         title = expression(m^2), 
         bty = "n", 
         xpd=TRUE, 
         cex = 1,
         pt.cex = 2,
         pch = 16,
         col = ba_cols) 
  
  title("Basal Area", line = -5, cex = 1)
  
  # proportional basal area
  plot(forown,
       
       # total pixels to plot
       # maxpixels = 1e7,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("grey70", "transparent"))
  
  plot(states_sh,
       add = TRUE)
  
  points(sp_dat$x,
         sp_dat$y,
         
         pch = 16,
         cex = 0.3,
         # colors
         col = sp_dat$prop_ba_col)
  
  plot(states_sh,
       add = TRUE)
  
  legend(2050000, 2600000,
         legend = prop_labels,
         title = "%", 
         bty = "n", 
         xpd=TRUE, 
         cex = 1,
         pt.cex = 2,
         pch = 16,
         col = prop_ba_cols) 
  
  title("Proportional Basal Area", line = -5, cex = 1)
  
  # species title
  mtext(bquote(italic(.(sp_latin))~"("*.(sp_common)*")"),
        side = 3, line = -0.5, cex = 2, font = 3, outer = TRUE)
  
  # NLCD legend
  draw(Legend(labels = c("Forested", "Non-forested"), 
              title = ,
              title_position = "topleft",
              legend_gp = gpar(fill = c("grey70", "White")),
              border = "grey15", 
              ncol = 2,
              labels_gp = gpar(fontsize = 14),
              title_gp = gpar(fontsize = 12),
              grid_height = unit(8, "mm"), 
              grid_width = unit(8, "mm")),
       x = unit(5, "in"),
       y = unit(0.5, "in"))
  dev.off()
  
  # remove files
  # rm(sp_ba)
  # rm(sp_prop)
}


# id test species 
test_sp <- c("s832", "s93", "s132", "s73", "s901", "s833", "s711", "s263", "s129")

#bt_sp
bt_sp <- c("s108", "s202", "s746", "s93")

# generate pdfs of plots
lapply(test_sp, function(x) plot_ba_propba(x))

#   plot_ba_propba("s93")

#############################################################################
## reduction plots
#############################################################################

# color palette and breaks for creating categorical variable
# red_cols <- c("steelblue3", brewer_pal(palette = "YlOrRd")(6)[2:6])
red_cols <- c("#B3B3B3", "#E5E5E5","#FFD700", "#FFA500", "#EE4000", "#8B0000")
# red_cols <- c("grey70", "grey90","gold1", "orange", "black", "darkred")
red_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
red_labels <- c("0", "0-1", "1-5", "5-10", "10-20", ">20")



plot_dat <- plot_dat %>% 
  mutate(red_s_n_col = red_cols[as.numeric(cut(red_s_n, breaks = red_breaks, labels = red_labels))],
         red_s_s_col = red_cols[as.numeric(cut(red_s_s, breaks = red_breaks, labels = red_labels))],
         red_g_n_col = red_cols[as.numeric(cut(red_g_n, breaks = red_breaks, labels = red_labels))],
         red_g_s_col = red_cols[as.numeric(cut(red_g_s, breaks = red_breaks, labels = red_labels))])

reduction_plot("s93")

red_exc_plot <- function(VAR, SORT, TITLE, DAT) {
  
  
  DAT <- DAT %>% 
    dplyr::arrange_(SORT)
  
  plot(states_sh,
       
       # total pixels to plot
       # maxpixels = 1e7,
       
       # turn off plot features
       axes = FALSE)
   
  # plot reduction/exceedance points
   points(DAT$x,
       DAT$y,
       
       cex = 0.3,
       pch = 16, 
       
       # colors
       col = DAT[, c(VAR)])
  
 
  # add panel title
  title(TITLE, line = -1.2, cex = 0.8)
}



reduction_plot <- function(SP) {
  
  sp_dat <- plot_dat %>% 
    filter(spp_code == SP) 
  
  # multipanel reduction plots
  pdf(file = paste("figures_md_fia/red/", SP, "_red.pdf", sep = ""),
      height = 5,
      width = 8)
  
  # set up multipanel par
  par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4.5), xpd = NA)
  
  # plot the individual rasters
  red_exc_plot("red_g_n_col", "red_g_n", "Growth - N Deposition", sp_dat)
  red_exc_plot("red_s_n_col", "red_s_n", "Survival - N Deposition", sp_dat)
  red_exc_plot("red_g_s_col", "red_g_s", "Growth - S Deposition", sp_dat)
  red_exc_plot("red_s_s_col", "red_s_s", "Survival - S Deposition", sp_dat)
  
  # add in the title
  mtext("Percent Reduction in Rate of:", side = 3, line = 0, cex = 1.2, font = 2, outer = TRUE)
  

  # add legend
  legend(2200000, 4800000,
         legend = red_labels,
         title = "%", 
         bty = "n", 
         xpd=NA, 
         cex = 1.4,
         pt.cex = 3,
         pch = 16,
         col = red_cols) 
  
  # add legend for all plots
  # draw(Legend(labels = rev(red_labels), 
  #             title = "%",
  #             title_position = "topleft",
  #             legend_gp = gpar(fill = rev(red_cols)), 
  #             # gap = unit(5, "mm"),
  #             grid_height = unit(8, "mm"), 
  #             grid_width = unit(8, "mm"), 
  #             ncol = 1),
  #      x = unit(7.45, "in"),
  #      y = unit(2.6, "in"))
  # 
  dev.off()
}


# generate pdfs of plots
lapply(test_sp, function(x) reduction_plot(x))
reduction_plot("s93")

