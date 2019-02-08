library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
library(sp)
library(rgeos)
library(raster)
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

raster_to_df <- function(RASTER) {
  # test_spdf <- as(RASTER, "SpatialPixelsDataFrame")
  # test_df <- as.data.frame(test_spdf)
  # colnames(test_df) <- c("value", "x", "y")
  # return(test_df)
  # 
  
  test_df <- rasterToPoints(RASTER)
  test_df <- data.frame(test_df)
  colnames(test_df) <- c("x", "y", "value")
  return(test_df)
}

########################################
## functions + font misc
########################################


theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text(family = "Ubuntu", color = "#22211d"),
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


# For Windows - in each session
# Adjust the path to match your installation of Ghostscript
Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.23/bin/gswin64.exe")

# load font for plotting
windowsFonts(Times=windowsFont("Ubuntu"))

#----------------------------------------------------------------------------

########################################
## load data
########################################

# s survival
s531_s_survival_red <- raster("test/s531_proportion_exc_s_survival_s_survival_reduction.tif")



#----------------------------------------------------------------------------


########################################
## reclassify
########################################


#---
# s survival reduction

system.time(s531_s_survival_red[s531_s_survival_red == 0] <- NA) # remove zero values
system.time(s531_s_survival_red[s531_s_survival_red < 0] <- "0")
system.time(s531_s_survival_red[s531_s_survival_red < 0.01 & s531_s_survival_red > 0] <- "0-0.01")
system.time(s531_s_survival_red[s531_s_survival_red < 0.05 & s531_s_survival_red >= 0.01] <- "0.01-0.05")
system.time(s531_s_survival_red[s531_s_survival_red < 0.1 & s531_s_survival_red >= 0.05] <- "0.05-0.1")
system.time(s531_s_survival_red[s531_s_survival_red < 0.2 & s531_s_survival_red >= 0.1] <- "0.1-0.2")
system.time(s531_s_survival_red[s531_s_survival_red >= 0.2] <- ">0.2")


levels(s531_s_survival_red) <- data.frame(ID = 1:6, 
                                          red_levels = c("0", 
                                                         "0-0.01",
                                                         "0.01-0.05",
                                                         "0.05-0.1", 
                                                         "0.1-0.2",
                                                         ">0.2"))


rec_mat <- matrix(c(-50, 0.000001, 0.01, 0.05, 0.1, 0.2,
                    0, 0.0099999999, 0.0499999999, 0.099999999, 0.1999999999, 50,
                    "0", "0-0.01", "0.01-0.05", "0.05-0.1", "0.1-0.2", ">0.2"),
                  nrow = 6,
                  ncol= 3)

system.time(temp_rc <- reclassify(s531_s_survival_red, rcl = rec_mat))




col_pal <- brewer_pal(palette = "RdYlBu")(6)




#----------------------------------------------------------------------------









