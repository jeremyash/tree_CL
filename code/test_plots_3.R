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

#----------------------------------------------------------------------------


########################################
## FUNCTIONS
########################################

##-------------
## proportion ba in exceedance
##-------------
# Create an empty raster for when there one is not processed via Python
# s832_n_growth_exc <- raster("test_2/s832_proportion_exc_n_growth.tif")
# empty_raster <- reclassify(s832_n_growth_exc, cbind(0, 10, NA))
# saveRDS(empty_raster, "test_2/empty_raster_exceedance.RDS")

# function to check if file exists and read in file; else is empty raster
read_exc_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    raster(FILE)
  } else {
    readRDS("test_2/empty_raster_exceedance.RDS")
  }
}


##-------------
## reduction
##-------------

# # Create an empty raster for when there one is not processed via Python
# s832_n_growth_red <- raster("test_2/s832_proportion_exc_n_growth_n_growth_reduction.tif")
# empty_raster <- reclassify(s832_n_growth_red, cbind(0, 10, NA))
# saveRDS(empty_raster, "test_2/empty_raster_reduction.RDS")

# function to check if file exists and read in file; else is empty raster
read_red_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    raster(FILE)
  } else {
    readRDS("test_2/empty_raster_reduction.RDS")
  }
}


##-------------
## plotting function for red/exc rasters
##-------------

red_exc_plot <- function(RASTER, TITLE) {
  
  # forest ownership
  plot(forown,
       
       # total pixels to plot
       # maxpixels = ncell(forown),
       
       # turn off plot features
       axes = FALSE,
       box = FALSE,
       legend = FALSE,
       
       # colors
       col = c("transparent", "grey85"))
  
  # plot reduction/exceedance raster
  plot(RASTER, 
       axes = FALSE, 
       box = FALSE, 
       col = red_cols, 
       breaks = red_breaks, 
       legend = FALSE,
       add = TRUE)
  
  # plot states
  plot(states_sh,
       add = TRUE)
  
  # add panel title
  title(TITLE, line = -2, cex = 0.8)
}




#----------------------------------------------------------------------------



########################################
## load gis and raster data
########################################

#forown
# forown <- raster("gis/forown.tif")
forown <- raster("gis/forown_binary_crop.tif") 
new_crs <- proj4string(forown)

# base states map
states_sh <- readOGR("gis/states")
states_sh <- spTransform(states_sh, new_crs)
# states_df <- broom::tidy(states_sh)
# states_sf <- st_as_sf(states_sh)





#----------------------------------------------------------------------------


########################################
## PLOT TESTING
########################################

##-------------
## forest ownership layer
##-------------
# plot(forown,
#      axes = FALSE,
#      box = FALSE,
#      legend = FALSE,
#      col = c("transparent", "grey85"))
# 
# plot(states_sh,
#      add = TRUE)
# 



##-------------
## basal area and proportional basal area
##-------------

# rasters
s832_ba <- raster("test_2/s832.tif") 
s832_prop <- raster("test_2/s832_proportion.tif") 


# plot pars
ba_cols <- rev(viridis(256))
prop_ba_cols <- rev(magma(256))


# multipanel plot 
pdf(file = "figures_base/ba_prop_s832.pdf",
    height = 5,
    width = 10)

par(mar = c(0,0,0,0), 
    mfrow = c(1,2), 
    oma = c(0,0,2,0),
    cex = 0.8)


# basal area
plot(forown,
     
     # total pixels to plot
     # maxpixels = ncell(forown),
     
     # turn off plot features
     axes = FALSE,
     box = FALSE,
     legend = FALSE,
     
     # colors
     col = c("transparent", "grey85"))

plot(s832_ba,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     legend = FALSE,
     
     # colors
     col = ba_cols,
     add = TRUE)
     

plot(states_sh,
     add = TRUE)

plot(s832_ba,
     
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
     # maxpixels = ncell(forown),
     
     # turn off plot features
     axes = FALSE,
     box = FALSE,
     legend = FALSE,
     
     # colors
     col = c("transparent", "grey85"))

plot(s832_prop,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     legend = FALSE,
     
     # colors
     col = prop_ba_cols,
     add = TRUE)


plot(states_sh,
     add = TRUE)

plot(s832_prop,

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
mtext("Quercus prinus", side = 3, line = -0.5, cex = 2, font = 3, outer = TRUE)
dev.off()


##-------------
## exceedance----proportion basal area
##-------------

display.brewer.pal(5, "Spectral")
display.brewer.all(5)


# color palette and breaks for creating categorical variable
exc_col_pal <- brewer_pal(palette = "YlOrRd")(5)
exc_theme <- rasterTheme(region=exc_col_pal)
exc_breaks <- c(0, 0.2 ,0.4, 0.6, 0.8, 1.0)
exc_df <- data.frame(ID = 1:5, 
                     exc_levels = c("0-0.2",
                                    "0.2-0.4",
                                    "0.4-0.6", 
                                    "0.6-0.8",
                                    "0.8-1.0"))





# n growth
s832_n_growth_exc <- read_cut_exc_raster("test_2/s832_proportion_exc_n_growth.tif")                         

# n survival
s832_n_survival_exc <- read_cut_exc_raster("test_2/s832_proportion_exc_n_survival.tif")

# s growth
s832_s_growth_exc <- read_cut_exc_raster("test_2/s832_proportion_exc_s_growth.tif")                         

# n survival
s832_s_survival_exc <- read_cut_exc_raster("test_2/s832_proportion_exc_s_survival.tif")


# create a raster stack
exc_stack <- stack(s832_n_growth_exc,
                   s832_n_survival_exc,
                   s832_s_growth_exc,
                   s832_s_survival_exc)

names(exc_stack) <- c("Proportion Basal Area in Exceedance for Growth - N",
                      "Proportion Basal Area in Exceedance for Survival - N",
                      "Proportion Basal Area in Exceedance for Growth - S",
                      "Proportion Basal Area in Exceedance for Survival - S")

# remove input files
rm(s832_n_growth_exc,
   s832_n_survival_exc,
   s832_s_growth_exc,
   s832_s_survival_exc)



# create base plot
exc <- levelplot(exc_stack,
                 
                 # maximum pixels...set for lower resolution to avoid memory
                 maxpixels = 1e5,
                 
                 #plot title
                 main = list("Proportion of Basal Area in Exceedance for:"), 
                 
                 # panel titles
                 names.attr = c("Growth - N",
                                "Survival - N",
                                "Growth - S",
                                "Survival - S"),
                 
                 # par settings
                 par.settings = exc_theme,
                 
                 # turn off margin plots
                 margin = FALSE,
                 
                 # legend title
                 colorkey = list(title = "%"),
                 
                 #turn off axis labels
                 xlab=NULL, 
                 ylab=NULL, 
                 scales=list(draw=FALSE),
                 
                 # change color scale
                 pretty = TRUE) +
  
  # states outline
  layer(sp.polygons(states_sh))


# add in forest ownership
exc_plot <- exc + as.layer(forown_plot, under = TRUE)


pdf(file = "figures/s832_exceedance_BA.pdf",
    height = 8,
    width = 8)
exc_plot
dev.off()


##-------------
## reduction...look at zlim in raster::plot for same scale
##-------------

# rasters

s832_n_growth_red <- read_red_raster("test_2/s832_proportion_exc_n_growth_n_growth_reduction.tif")                
s832_n_survival_red <- read_red_raster("test_2/s832_proportion_exc_n_survival_n_survival_reduction.tif")
s832_s_growth_red <- read_red_raster("test_2/s832_proportion_exc_s_growth_s_growth_reduction.tif") 
s832_s_survival_red <- read_red_raster("test_2/s832_proportion_exc_s_survival_s_survival_reduction.tif")

# stack and name rasters
red_stack <- stack(s832_n_growth_red,
                   s832_n_survival_red,
                   s832_s_growth_red,
                   s832_s_survival_red)

names(red_stack) <- c("Growth_N",
                      "Survival_N",
                      "Growth_S",
                      "Survival_S")

# remove input files
rm(s832_n_growth_red,
   s832_n_survival_red,
   s832_s_growth_red,
   s832_s_survival_red)


# color palette and breaks for creating categorical variable
red_cols <- rev(brewer_pal(palette = "RdYlBu")(6))
red_breaks <- c(0, 0.000001, 0.01, 0.05, 0.1, 0.2, 3.5)
red_labels <- c("0", "0-0.01", "0.01-0.05", "0.05-0.1", "0.1-0.2", ">0.2")


# multipanel reduction plots
pdf(file = "figures_base/exc_test.pdf",
    height = 5,
    width = 8)

# set up multipanel par
par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,8))

# plot the individual rasters
red_exc_plot(red_stack[[1]], "Growth - N")
red_exc_plot(red_stack[[2]], "Survival - N")
red_exc_plot(red_stack[[3]], "Growth - S")
red_exc_plot(red_stack[[4]], "Survival - S")

# add in the title
mtext("Proportion Reduction in:", side = 3, line = -0.5, cex = 1.2, font = 2, outer = TRUE)

# add legend for all plots
par(mfrow=c(1,1),new=FALSE, oma=c(0,0,0,0), mgp = c(2.5,0.25,0))

legend(
  x = 1850000,
  y = 2500000,
  ncol = 1,
  
  # legend colors and sizes
  legend = rev(red_labels),
  pch = 22,
  col = "grey15",
  pt.bg = rev(red_cols),
  pt.cex = 5,
  
  # title
  title = "%",
  title.adj = 0.1,
  
  # turn off box
  bty = "n",
  
  #size and location
  # inset = -.075,
  # y.intersp = 1,
  x.intersp = 1.5,
  cex = 1.2,
  # text.width = 40,
  xpd = NA)


dev.off()




