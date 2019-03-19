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
## read in exceedance/redcution rasters
##-------------
# Create an empty raster for when one is not processed via Python
# s832_ba <- raster("rasters/s832.tif")
# empty_raster <- raster(vals = NA,
#                        nrows = nrow(s832_ba),
#                        ncols = ncol(s832_ba),
#                        ext = extent(s832_ba),
#                        crs = proj4string(s832_ba))
# saveRDS(empty_raster, "rasters/empty_raster.RDS")

# function to check if file exists and read in file; else is empty raster
read_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    raster(FILE)
  } else {
    # readRDS("rasters/empty_raster_exceedance.RDS")
    readRDS("rasters/empty_raster.RDS")
  }
}



##-------------
## plotting function for reduction/exceedance rasters
##-------------

red_exc_plot <- function(RASTER, TITLE, COLS, BREAKS) {
  
  # forest ownership
  plot(forown,
       
       # total pixels to plot
       # maxpixels = 1e5,
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("grey70", "transparent"))
  
  # plot reduction/exceedance raster
  plot(RASTER, 
       # total pixels to plot
       # maxpixels = ncell(RASTER),
       
       # turn off plot features
       axes = FALSE, 
       box = FALSE, 
       legend = FALSE,
       
       # colors and bins
       col = COLS, 
       breaks = BREAKS, 
      
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
  prop_ba_cols <- c("khaki2", rev(inferno(6))[2:6])
  
  # species title
  sp_latin <- with(sp_dat, paste(GENUS[spp_code == SP], 
                                 SPECIES[spp_code == SP], 
                                 sep = " "))
  
  sp_common <- with(sp_dat, COMMON_NAME[spp_code == SP])
  
  # prop_ba breaks and labels
  prop_breaks <- c(0,0.05,0.10,0.20,0.40, 0.60, 1)
  prop_labels <- c("<5", "5-10", "10-20", "20-40", "40-60", ">60")
  
  # multipanel plot 
  pdf(file = paste("figures_md/ba/", SP, "_ba_propba.pdf", sep = ""),
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
  
  plot(sp_ba,
       
       # total pixels to plot
       # maxpixels = 1e7,
       
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
       horizontal = FALSE,
       # legend.width = 1.5,
       # cex = 1.2,
       smallplot = c(0.85,0.89,0.18,0.76),
       
       # legend title
       legend.args=list(text=expression(m^2), 
                        line = 0.3,
                        side = 3,
                        cex = 1.1,
                        las = 1),
       
       # legend labels
       axis.args = list(cex.axis = 1.1,
                        mgp = c(2.5,0.5,0),
                        tck = -0.25),
       
       add = TRUE)
  
  
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
  
  plot(sp_prop,
       
       # total pixels to plot
       # maxpixels = 1e7,
       
       #turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = prop_ba_cols,
       
       # breaks
       breaks = prop_breaks,
       
       add = TRUE)
  
  
  plot(states_sh,
       add = TRUE)

  
  # add legend for prop_ba using COmplexHeatmap::Legend
  draw(Legend(labels = rev(prop_labels), 
              title = "%",
              title_position = "topleft",
              legend_gp = gpar(fill = rev(prop_ba_cols)), 
              labels_gp = gpar(fontsize = 12),
              title_gp = gpar(fontsize = 12),
              grid_height = unit(12, "mm"), 
              grid_width = unit(5, "mm"), 
              ncol = 1),
       x = unit(9.59, "in"),
       y = unit(2.275, "in"))
  
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
  rm(sp_ba)
  rm(sp_prop)
}


# id test species 
test_sp <- c("s832", "s93", "s132", "s73", "s901", "s833", "s711", "s263", "s129")

# generate pdfs of plots
lapply(test_sp, function(x) plot_ba_propba(x))

##-------------
## exceedance----proportion basal area
##-------------

exceedance_plot <- function(SP) {

  # rasters
  sp_n_growth_exc <- read_raster(paste("rasters/", SP, "_proportion_exc_n_growth.tif", sep = ""))              
  sp_n_survival_exc <- read_raster(paste("rasters/", SP, "_proportion_exc_n_survival.tif", sep = ""))
  sp_s_growth_exc <- read_raster(paste("rasters/", SP, "_proportion_exc_s_growth.tif", sep = ""))                   
  sp_s_survival_exc <- read_raster(paste("rasters/", SP, "_proportion_exc_s_survival.tif", sep = ""))
  
  # basal area for mask
  sp_ba <- raster(paste("rasters/", SP, ".tif", sep = "")) 
  
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
  
  # mask the raster stack with the basal area raster and then remove original
  exc_stack_mask <- mask(exc_stack, sp_ba)
  rm(exc_stack)
  
  
  # color palette and breaks for creating categorical variable
  exc_cols <- c("steelblue3", brewer_pal(palette = "YlOrRd")(6)[2:6])
  exc_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
  exc_labels <- c("0", "0-1", "1-5", "5-10", "10-20", ">20")
  
  # create pdf file
  pdf(file = paste("figures_md/exc/", SP, "_exc.pdf", sep = ""),
      height = 5,
      width = 8)
  
  # set up multipanel par
  par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4.5), xpd = NA)
  
  # plot the individual rasters
  red_exc_plot(exc_stack_mask[[1]], "Growth - N Deposition", exc_cols, exc_breaks )
  red_exc_plot(exc_stack_mask[[2]], "Survival - N Deposition", exc_cols, exc_breaks)
  red_exc_plot(exc_stack_mask[[3]], "Growth - S Deposition", exc_cols, exc_breaks)
  red_exc_plot(exc_stack_mask[[4]], "Survival - S Deposition", exc_cols, exc_breaks)
  
  # add in the title
  mtext("Percent of Basal Area in Exceedance of Critical Load for:", side = 3, line = 0, cex = 1.2, font = 2, outer = TRUE)
  
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
  sp_n_growth_red <- read_raster(paste("rasters/", SP, "_proportion_exc_n_growth_n_growth_reduction.tif", sep = ""))
  sp_n_survival_red <- read_raster(paste("rasters/", SP, "_proportion_exc_n_survival_n_survival_reduction.tif", sep = ""))
  sp_s_growth_red <- read_raster(paste("rasters/", SP, "_proportion_exc_s_growth_s_growth_reduction.tif", sep = ""))
  sp_s_survival_red <- read_raster(paste("rasters/", SP, "_proportion_exc_s_survival_s_survival_reduction.tif", sep = ""))
  
  # basal area raster for mask
  sp_ba <- raster(paste("rasters/", SP, ".tif", sep = "")) 
  
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
  
  
  # mask the raster stack with the basal area raster and then remove original
  red_stack_mask <- mask(red_stack, sp_ba)
  rm(red_stack)
  
  # color palette and breaks for creating categorical variable
  red_cols <- c("steelblue3", brewer_pal(palette = "YlOrRd")(6)[2:6])
  red_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
  red_labels <- c("0", "0-1", "1-5", "5-10", "10-20", ">20")
  
  
  # multipanel reduction plots
  pdf(file = paste("figures_md/red/", SP, "_red.pdf", sep = ""),
      height = 5,
      width = 8)
  
  # set up multipanel par
  par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4.5), xpd = NA)
  
  # plot the individual rasters
  red_exc_plot(red_stack_mask[[1]], "Growth - N Deposition", red_cols, red_breaks)
  red_exc_plot(red_stack_mask[[2]], "Survival - N Deposition", red_cols, red_breaks)
  red_exc_plot(red_stack_mask[[3]], "Growth - S Deposition", red_cols, red_breaks)
  red_exc_plot(red_stack_mask[[4]], "Survival - S Deposition", red_cols, red_breaks)
  
  # add in the title
  mtext("Percent Reduction in:", side = 3, line = 0, cex = 1.2, font = 2, outer = TRUE)
  
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
