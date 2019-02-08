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

## PLOTTING
library(scales)
library(units)
library(viridis)
library(extrafont)
library(gtable)
library(grid)
library(rasterVis)

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
# empty_raster <- raster::cut(empty_raster,
#                             breaks = exc_breaks,
#                             include.lowest = TRUE)
# levels(empty_raster) <- exc_df
# saveRDS(empty_raster, "test_2/empty_raster_exceedance.RDS")

# function to check if file exists and read in file; else is empty raster
read_cut_exc_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    dat <- raster(FILE)
    dat <- raster::cut(dat, 
                       breaks = exc_breaks,
                       include.lowest = TRUE)
    levels(dat) <- exc_df
    return(dat)
    
  } else {
    readRDS("test_2/empty_raster_exceedance.RDS")
  }
}


##-------------
## reduction
##-------------

# # Create an empty raster for when there one is not processed via Python
# s832_n_growth_red <- read_raster_fun("test_2/s832_proportion_exc_n_growth_n_growth_reduction.tif")
# empty_raster <- reclassify(s832_n_growth_red, cbind(0, 10, NA))
# empty_raster <- raster::cut(empty_raster, 
#                             breaks = red_breaks,
#                             include.lowest = TRUE)
# levels(empty_raster) <- red_df
# saveRDS(empty_raster, "test_2/empty_raster_reduction.RDS")

# function to check if file exists and read in file; else is empty raster
read_cut_red_raster <- function(FILE) {
  if(file.exists(FILE) == TRUE){
    dat <- raster(FILE)
    dat <- raster::cut(dat, 
                       breaks = red_breaks,
                       include.lowest = TRUE)
    levels(dat) <- red_df
    return(dat)
    
  } else {
    readRDS("test_2/empty_raster_reduction.RDS")
  }
}

#----------------------------------------------------------------------------



########################################
## load gis and raster data
########################################

# base states map
states_sh <- readOGR("gis/states")
states_sh <- spTransform(states_sh, CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
# states_df <- broom::tidy(states_sh)
# states_sf <- st_as_sf(states_sh)

#forown
# forown <- raster("gis/forown.tif")
forown <- raster("gis/forown_binary_crop.tif") 



#----------------------------------------------------------------------------


 ########################################
 ## PLOT TESTING
 ########################################
 
##-------------
## forest ownership layer
##-------------

forown_theme <- rasterTheme(region = c("transparent", "grey85"))

forown_plot <- levelplot(forown,
                         
                         # maximum pixels...set for lower resolution to avoid memory
                         maxpixels = 1e5,
                         
                         # plot title
                         main = list("Basal Area"), 
                         
                         # turn off margin plots
                         margin = FALSE,
                         
                         # turn off scales and axis labels
                         xlab=NULL, 
                         ylab=NULL, 
                         scales=list(draw=FALSE),
                         
                         # color settings
                         par.settings = forown_theme)



##-------------
## basal area
##-------------

# basal area
s832_ba <- raster("test_2/s832.tif") 


ba_theme <- rasterTheme(region = rev(viridis(10)))

ba <- levelplot(s832_ba,
                     
                     # maximum pixels...set for lower resolution to avoid memory
                     maxpixels = 1e5,
                
                     par.settings = ba_theme,
                     
                     #plot title
                     main = list("Basal Area"), 
                     
                     # turn off margin plots
                     margin = FALSE,
                      
                     # legend title
                     colorkey = list(title = expression(atop(m^2, " ")),
                                     title.gpar = list(cex = 0.9)),
                     
                     #turn off axis labels
                     xlab=NULL, 
                     ylab=NULL, 
                     scales=list(draw=FALSE),
                     
                     # change color scale
                     pretty = TRUE) +
            
            # states outline
            layer(sp.polygons(states_sh))


ba_plot <- ba + as.layer(forown_plot, under = TRUE)

pdf(file = "figures/s832_ba.pdf",
    height = 4,
    width = 4)
ba_plot
dev.off()

##-------------
## proportional basal area
##-------------

# proportion basal area
s832_prop <- raster("test_2/s832_proportion.tif") 

prop_ba_theme <- rasterTheme(region = rev(magma(10)))

prop_ba <- levelplot(s832_prop,
                     
                     # maximum pixels...set for lower resolution to avoid memory
                     maxpixels = 1e5,
                     
                     par.settings = prop_ba_theme,
                     
                     #plot title
                     main = list("Proportional Basal Area"), 
                     
                     # turn off margin plots
                     margin = FALSE,
                     
                     # legend title
                     colorkey = list(title = "%",
                       # title = expression(atop("%", "")),
                                     title.gpar = list(cex = 0.9)),
                     
                     #turn off axis labels
                     xlab=NULL, 
                     ylab=NULL, 
                     scales=list(draw=FALSE),
                     
                     # change color scale
                     pretty = TRUE) +
  
  # states outline
  layer(sp.polygons(states_sh))


prop_ba_plot <- prop_ba + as.layer(forown_plot, under = TRUE)

pdf(file = "figures/s832_prop_ba.pdf",
    height = 4,
    width = 4)
prop_ba_plot
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
## reduction
##-------------

# color palette and breaks for creating categorical variable
red_col_pal <- brewer_pal(palette = "RdYlBu")(6)
red_theme <- rasterTheme(region=rev(red_col_pal))
red_breaks <- c(0, 0.01,0.05, 0.1, 0.2, Inf)
red_df <- data.frame(ID = 1:6, 
                     red_levels = c("0", 
                                    "0-0.01",
                                    "0.01-0.05",
                                    "0.05-0.1", 
                                    "0.1-0.2",
                                    ">0.2"))


# n growth
s832_n_growth_red <- read_cut_red_raster("test_2/s832_proportion_exc_n_growth_n_growth_reduction.tif")                         
# n survival
s832_n_survival_red <- read_cut_red_raster("test_2/s832_proportion_exc_n_survival_n_survival_reduction.tif")

# s growth
s832_s_growth_red <- read_cut_red_raster("test_2/s832_proportion_exc_s_growth_s_growth_reduction.tif") 

# s survival
s832_s_survival_red <- read_cut_red_raster("test_2/s832_proportion_exc_s_survival_s_survival_reduction.tif")


# create a raster stack
red_stack <- stack(s832_n_growth_red,
                   s832_n_survival_red,
                   s832_s_growth_red,
                   s832_s_survival_red)

names(red_stack) <- c("Proportion Reduction in Growth - N",
                      "Proportion Reduction in Survival - N",
                      "Proportion Reduction in Growth - S",
                      "Proportion Reduction in Survival - S")

# remove input files
rm(s832_n_growth_red,
   s832_n_survival_red,
   s832_s_growth_red,
   s832_s_survival_red)



# create base plot
red <- levelplot(red_stack,
          
          # maximum pixels...set for lower resolution to avoid memory
          maxpixels = 1e5,
          
          #plot title
          main = list("Proportion Reduction in:"), 
          
          # panel titles
          names.attr = c("Growth - N",
            "Survival - N",
            "Growth - S",
            "Survival - S"),
          
          # par settings
          par.settings = red_theme,
          
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
red_plot <- red + as.layer(forown_plot, under = TRUE)


pdf(file = "figures/s832_reduction.pdf",
    height = 8,
    width = 8)
red_plot
dev.off()




















