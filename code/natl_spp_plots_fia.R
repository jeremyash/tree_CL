## SPATIAL
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(maptools)
library(sf)

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



# This is derived from the full dataset, but I’ve averaged the response for trees of a given species within a plot. So each plot will have a number of rows equal to the number of species in the plot. And each row is the average species response within a plot (which may vary with tree size). I’ve included the responses excluding the increasers (labeled “Mean(PropRed…”, 4 columns for the four responses – N/S by growth/survival), and including the increasers (labeled “Mean(PropChange…”, also 4 columns). For species where the dep has gone below the curve, these are ignored.


plot_dat <- read_csv("raw_data/RTI_Tree_Database_2017NOV14_CMC_Horn only_For JA_short.txt") %>% 
  mutate(spp_code = paste("s", spp_code, sep = ""))
colnames(plot_dat)[10:13] <- c("red_s_n",
                               "red_s_s",
                               "red_g_n",
                               "red_g_s") 












