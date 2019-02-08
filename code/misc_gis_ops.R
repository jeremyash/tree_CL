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
#----------------------------------------------------------------------------


#############################################################################
## create landcover mask with nlcd
#############################################################################

nlcd <- raster("gis/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10.img")

nlcd_table <- read_csv("raw_data/nlcd_lookup_table.csv") %>% 
  mutate(mask = ifelse(Value %in% c(41, 42, 43, 51, 52, 71, 72, 73, 74, 90, 95), 0, 1))


nlcd_table %>% 
  mutate(python_stat = paste("[", Value, ",", mask, "]", sep = "")) %>% 
  pull(python_stat)



gc()
nlcd_subs <- subs(nlcd, nlcd_table, by = "Value", which = "mask")


#############################################################################
## create landcover mask with https://databasin.org/datasets/c16721f4f9b04bd494e03bceaf94fbf4
#############################################################################
# forown  <- raster("gis/forestown_v11/forestown.tif")
# 
# forown_table <- read.csv("gis/forestown_v11/forown_table.txt") %>% 
#   mutate(mask = ifelse(VALUE %in% c(1,2,3), 1, 0)) %>% 
#   select(VALUE, mask) #started at 1147AM
# 
# forown_mask <- forown_table %>% 
#   filter(mask == 0) %>% 
#   pull(VALUE)
# 
# forown[forown == 2] <- 1 
# forown[forown == 3] <- 1 
# 
# forown[forown %in% forown_mask] <- 0
# 
# writeRaster(forown, 
#             filename = "gis/forown_binary.tif")
# 
# forown <- raster("gis/forown_binary.tif")
# new_crs <- proj4string(forown)
# 
# 
# # forown_poly <- rasterToPolygons(forown, fun = function(x) {x == 1}, dissolve = TRUE) #started at 0938
# 
# 
# states_sh <- readOGR("gis/states")
# states_sh <- spTransform(states_sh, new_crs)
# 
# 
# 
# 
# cr <- crop(forown, extent(states_sh), snap="out")                    
# fr <- rasterize(states_sh, cr)   
# lr <- mask(x=cr, mask=fr)  


writeRaster(lr,
            filename = "gis/forown_binary_crop.tif")

# after conversion to polygons in Arc
forestown_poly <- readOGR("gis/forestown_poly")

system.time(forestown_sh <- sf::read_sf("gis/forestown_poly"))

ggplot(forestown_sh) +
  geom_sf()





#############################################################################
## lower 48 with state boundaries
#############################################################################
states <- readOGR("gis/tl_2017_us_state")

states_vec <- states@data %>% 
  pull(NAME)


states_48 <- subset(states, !(NAME %in% c("United States Virgin Islands",
                                          "Commonwealth of the Northern Mariana Islands",
                                          "Hawaii",
                                          "American Samoa",
                                          "Guam",
                                          "Puerto Rico",
                                          "Alaska")))




