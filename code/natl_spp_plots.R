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


########################################
## FUNCTIONS
########################################

##-------------
## proportion ba in exceedance
##-------------
# Create an empty raster for when there one is not processed via Python
# s832_n_growth_exc <- raster("rasters/s832_proportion_exc_n_growth.tif")
# empty_raster <- reclassify(s832_n_growth_exc, cbind(0, 10, NA))
# saveRDS(empty_raster, "rasters/empty_raster_exceedance.RDS")

# function to check if file exists and read in file; else is empty raster
read_exc_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    raster(FILE)
  } else {
    readRDS("rasters/empty_raster_exceedance.RDS")
  }
}


##-------------
## reduction
##-------------

# # Create an empty raster for when there one is not processed via Python
# s832_n_growth_red <- raster("rasters/s832_proportion_exc_n_growth_n_growth_reduction.tif")
# empty_raster <- reclassify(s832_n_growth_red, cbind(0, 10, NA))
# saveRDS(empty_raster, "rasters/empty_raster_reduction.RDS")

# function to check if file exists and read in file; else is empty raster
read_red_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    raster(FILE)
  } else {
    readRDS("rasters/empty_raster_reduction.RDS")
  }
}


##-------------
## plotting function for red/exc rasters
##-------------

red_exc_plot <- function(RASTER, TITLE, COLS, BREAKS) {
  
  # forest ownership
  plot(forown,
       
       # total pixels to plot
       maxpixels = 1e8,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("transparent", "grey85"))
  
  # plot reduction/exceedance raster
  plot(RASTER, 
       # total pixels to plot
       maxpixels = ncell(RASTER),
       axes = FALSE, 
       box = FALSE, 
       col = COLS, 
       breaks = BREAKS, 
       legend = FALSE,
       add = TRUE)
  
  # plot states
  plot(states_sh,
       add = TRUE)
  
  # add panel title
  title(TITLE, line = -1.5, cex = 0.8)
}




#----------------------------------------------------------------------------



########################################
## load gis and raster data
########################################

#forown
forown <- raster("gis/forown_binary_crop.tif") 
new_crs <- proj4string(forown)

# base states map
states_sh <- readOGR("gis/states")
states_sh <- spTransform(states_sh, new_crs)

# species codes and data
sp_dat <- read_csv("data/spp_codes.csv")
colnames(sp_dat)[4] <- "spp_code"

sp_dat <- sp_dat %>% 
  mutate(spp_code = paste("s", spp_code, sep = ""))


#----------------------------------------------------------------------------


########################################
## PLOTTING
########################################

##-------------
## basal area and proportional basal area
##-------------

plot_ba_propba <- function(SP) {

  # rasters
  sp_ba <- raster(paste("rasters/", SP, ".tif", sep = "")) 
  sp_prop <- raster(paste("rasters/", SP, "_proportion.tif", sep = "")) 
  
  # plot pars
  ba_cols <- rev(viridis(256))
  prop_ba_cols <- rev(magma(256))
  
  # species title
  sp_title <- with(sp_dat, paste(GENUS[spp_code == SP], SPECIES[spp_code == SP], sep = " "))
  
  # multipanel plot 
  pdf(file = paste("figures_md/ba/", SP, "_ba_propba.pdf", sep = ""),
      height = 5,
      width = 10)
  
  par(mar = c(0,0,0,0), 
      mfrow = c(1,2), 
      oma = c(0,0,2,0),
      cex = 0.8)
  
  
  # basal area
  plot(forown,
       
       # total pixels to plot
       maxpixels = 1e8,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("transparent", "grey85"))
  
  plot(sp_ba,
       
       # total pixels to plot
       maxpixels = 1e8,
       
       #turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = ba_cols,
       add = TRUE)
       
  plot(states_sh,
       add = TRUE)
  
  plot(sp_ba,
       
       # colors
       col = ba_cols,
       
       #legend properties
       # legend.shrink = 0.4,
       legend.only = TRUE,
       horizontal = TRUE,
       # legend.width = 1.5,
       # cex = 1.2,
       smallplot = c(0.1,0.9,0.1,0.15),
       
       # legend title
       legend.args=list(text=expression(m^2), 
                        line = 0.5,
                        side = 2,
                        cex = 1.1,
                        las = 1),
       
       # legend labels
       axis.args = list(cex.axis = 1.1,
                        mgp = c(2.5,0.5,0),
                        tck = -0.25),
       
       add = TRUE)
  
  
  title("Basal Area", line = -5, cex = 0.8)
  
  # proportional basal area
  plot(forown,
       
       # total pixels to plot
       # total pixels to plot
       maxpixels = 1e8,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("transparent", "grey85"))
  
  plot(sp_prop,
       
       # total pixels to plot
       maxpixels = 1e8,
       
       #turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = prop_ba_cols,
       add = TRUE)
  
  
  plot(states_sh,
       add = TRUE)
  
  plot(sp_prop,
  
       # colors
       col = prop_ba_cols,
       
       #legend properties
       # legend.shrink = 0.4,
       legend.only = TRUE,
       horizontal = TRUE,
       # legend.width = 1.5,
       # cex = 1.2,
       smallplot = c(0.1,0.9,0.1,0.15),
       
       # legend title
       legend.args=list(text="%", 
                        line = 0.5,
                        side = 2,
                        cex = 1.1,
                        las = 1),
       
       # legend labels
       axis.args = list(cex.axis = 1.1,
                        mgp = c(2.5,0.5,0),
                        tck = -0.25),
       
       add = TRUE)
  
  
  title("Proportional Basal Area", line = -5, cex = 0.8)
  
  # species title
  mtext(sp_title, side = 3, line = -0.5, cex = 2, font = 3, outer = TRUE)
  dev.off()
  
  # remove files
  rm(sp_ba)
  rm(sp_prop)
}


test_sp <- c("s832", "s93", "s132", "s73", "s901", "s833", "s711", "s263", "s129")

lapply(test_sp, function(x) plot_ba_propba(x))


##-------------
## exceedance----proportion basal area
##-------------

exceedance_plot <- function(SP) {

  # rasters
  sp_n_growth_exc <- read_exc_raster(paste("rasters/", SP, "_proportion_exc_n_growth.tif", sep = ""))              
  sp_n_survival_exc <- read_exc_raster(paste("rasters/", SP, "_proportion_exc_n_survival.tif", sep = ""))
  sp_s_growth_exc <- read_exc_raster(paste("rasters/", SP, "_proportion_exc_s_growth.tif", sep = ""))                   
  sp_s_survival_exc <- read_exc_raster(paste("rasters/", SP, "_proportion_exc_s_survival.tif", sep = ""))
  
  # create a raster stack
  exc_stack <- stack(sp_n_growth_exc,
                     sp_n_survival_exc,
                     sp_s_growth_exc,
                     sp_s_survival_exc)
  
  names(exc_stack) <- c("Growth_N",
                        "Survival_N",
                        "Growth_S",
                        "Survival_S")
  
  # remove input files
  rm(sp_n_growth_exc,
     sp_n_survival_exc,
     sp_s_growth_exc,
     sp_s_survival_exc)
  
  
  # color palette and breaks for creating categorical variable
  exc_cols <- brewer_pal(palette = "YlOrRd")(6)
  exc_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
  exc_labels <- c("0", "0-0.01", "0.01-0.05", "0.05-0.1", "0.1-0.2", ">0.2")
  
  # create pdf file
  pdf(file = paste("figures_md/exc/", SP, "_exc.pdf", sep = ""),
      height = 5,
      width = 8)
  
  # set up multipanel par
  par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4.5), xpd = NA)
  
  # plot the individual rasters
  red_exc_plot(exc_stack[[1]], "Growth - N", exc_cols, exc_breaks )
  red_exc_plot(exc_stack[[2]], "Survival - N", exc_cols, exc_breaks)
  red_exc_plot(exc_stack[[3]], "Growth - S", exc_cols, exc_breaks)
  red_exc_plot(exc_stack[[4]], "Survival - S", exc_cols, exc_breaks)
  
  # add in the title
  mtext("Proportion of Basal Area in Exceedance for:", side = 3, line = 0, cex = 1.2, font = 2, outer = TRUE)
  
  # add legend for all plots using COmplexHeatmap::Legend
  draw(Legend(labels = rev(exc_labels), 
              title = "%",
              title_position = "topleft",
              legend_gp = gpar(fill = rev(exc_cols)), 
              # gap = unit(5, "mm"),
              grid_height = unit(8, "mm"), 
              grid_width = unit(8, "mm"), 
              ncol = 1),
       x = unit(7.45, "in"),
       y = unit(2.6, "in"))
  
  dev.off()
}

lapply(test_sp, function(x) exceedance_plot(x))
##-------------
## reduction
##-------------


reduction_plot <- function(SP) {
  
  # rasters
  sp_n_growth_red <- read_red_raster(paste("rasters/", SP, "_proportion_exc_n_growth_n_growth_reduction.tif", sep = ""))
  sp_n_survival_red <- read_red_raster(paste("rasters/", SP, "_proportion_exc_n_survival_n_survival_reduction.tif", sep = ""))
  sp_s_growth_red <- read_red_raster(paste("rasters/", SP, "_proportion_exc_s_growth_s_growth_reduction.tif", sep = ""))
  sp_s_survival_red <- read_red_raster(paste("rasters/", SP, "_proportion_exc_s_survival_s_survival_reduction.tif", sep = ""))
  
  # stack and name rasters
  red_stack <- stack(sp_n_growth_red,
                     sp_n_survival_red,
                     sp_s_growth_red,
                     sp_s_survival_red)
  
  names(red_stack) <- c("Growth_N",
                        "Survival_N",
                        "Growth_S",
                        "Survival_S")
  
  # remove input files
  rm(sp_n_growth_red,
     sp_n_survival_red,
     sp_s_growth_red,
     sp_s_survival_red)
  
  
  # color palette and breaks for creating categorical variable
  red_cols <- rev(brewer_pal(palette = "RdYlBu")(6))
  red_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
  red_labels <- c("0", "0-0.01", "0.01-0.05", "0.05-0.1", "0.1-0.2", ">0.2")
  
  
  # multipanel reduction plots
  pdf(file = paste("figures_md/red/", SP, "_red.pdf", sep = ""),
      height = 5,
      width = 8)
  
  # set up multipanel par
  par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4.5), xpd = NA)
  
  # plot the individual rasters
  red_exc_plot(red_stack[[1]], "Growth - N", red_cols, red_breaks)
  red_exc_plot(red_stack[[2]], "Survival - N", red_cols, red_breaks)
  red_exc_plot(red_stack[[3]], "Growth - S", red_cols, red_breaks)
  red_exc_plot(red_stack[[4]], "Survival - S", red_cols, red_breaks)
  
  # add in the title
  mtext("Proportion Reduction in:", side = 3, line = 0, cex = 1.2, font = 2, outer = TRUE)
  
  # add legend for all plots
  draw(Legend(labels = rev(red_labels), 
              title = "%",
              title_position = "topleft",
              legend_gp = gpar(fill = rev(red_cols)), 
              # gap = unit(5, "mm"),
              grid_height = unit(8, "mm"), 
              grid_width = unit(8, "mm"), 
              ncol = 1),
       x = unit(7.45, "in"),
       y = unit(2.6, "in"))
 
  dev.off()
}

lapply(test_sp, function(x) reduction_plot(x))

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#############################################################################
## testing
#############################################################################


