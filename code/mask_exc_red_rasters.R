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



#############################################################################
## MASK EXCEEDANCE RASTER WITH BA RASTER
#############################################################################

ba_raster <- raster("rasters/s832.tif")

exc_raster <- raster("rasters/s832_")































