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



r <- raster(nrows=5, ncols=5, vals=1:25)

plot(r)


plot(r, col=topo.colors(100), legend=TRUE, axes=TRUE)
r.range <- c(minValue(r), maxValue(r))
plot(r, legend.only=TRUE, col=topo.colors(100),
     legend.width=1, legend.shrink=0.75,
     axis.args=list(at=seq(r.range[1], r.range[2], 1),
                    labels=seq(r.range[1], r.range[2], 1), 
                    cex.axis=8),
     legend.args=list(text='Elevation (m)', side=4, font=2, line=2.5, cex=0.8))




# basal area and prop basal area

par(mar = c(0,0,0,0))
plot(r,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     
     # title
     main = "Basal Area",
     
     # colors
     col = ba_cols,
     
     #legend properties
     legend.args=list(text=expression(m^2), line = 0.4, cex=1, adj = -1),
     axis.args = list(cex.axis = 1,
                      mgp = c(3,0.5,0),
                      tck = -0.25),
     
     legend.width = 1,
     legend.shrink = 0.4)




# reduction and exceedance plots

z <- raster(nrows=5, ncols=5, vals=seq(0,1,l=25))
plot(z)


# reduction colors, breaks and levels/labels
red_cols <- rev(brewer_pal(palette = "RdYlBu")(6))
red_breaks <- c(0, 0.01,0.05, 0.1, 0.2, 3)
red_levels <- c("0",  
                "0-0.01",
               "0.01-0.05",
               "0.05-0.1", 
               "0.1-0.2",
               ">0.2")
plot(z,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     
     # title
     main = "Exceedance/reduction",
     
     # colors
     col = red_cols,
     
     # breaks
     breaks = red_breaks,
     
     legend = FALSE)


legend(
  x = "right",
  ncol = 1,
  legend = rev(red_levels),
  fill = rev(red_cols),
  # title = "%",
  bty = "n",
  # inset = -0.175,
  y.intersp = 0.5,
  x.intersp = 0.25,
  cex = 3,
  text.width = 20

)


###CLOSEST ATTEMPT SO FAR
# window()


pdf(file = "figures_base/exc_test.pdf",
    height = 5,
    width = 8)

par(mfrow=c(2,2),mar=c(0,0,1,1),oma=c(0,0,0,8))
plot(states_sh, axes = FALSE, box = FALSE, main = "Exceedance/reduction", col = red_cols, breaks = red_breaks, legend = FALSE)
plot(states_sh, axes = FALSE, box = FALSE, main = "Exceedance/reduction", col = red_cols, breaks = red_breaks, legend = FALSE)
plot(states_sh, axes = FALSE, box = FALSE, main = "Exceedance/reduction", col = red_cols, breaks = red_breaks, legend = FALSE)
plot(states_sh, axes = FALSE, box = FALSE, main = "Exceedance/reduction", col = red_cols, breaks = red_breaks, legend = FALSE)

par(mfrow=c(1,1),new=FALSE, oma=c(0,0,0,0))

legend(
  x = 1750000,
  y = 2750000,
  ncol = 1,
  
  # legend colors and sizes
  legend = rev(red_levels),
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
  # x.intersp = 0.25,
  cex = 1.5,
  text.width = 30,
  xpd = NA)

dev.off()






plot(z,legend.only=TRUE ,legend.shrink=1, legend.width=1, zlim=c(0, 1),
     axis.args=list(at=c(0.01, 0.05, 0.1, 0.2,  3), labels=red_levels,col=red_cols),
     legend.args=list(text='Whatever',"bottom", font=2, line=2.3))

red_raster <- raster(nrows = 2, ncols = 4, vals = c(0,1,2,3,4,5,6,6))
plot(red_raster,legend.only=TRUE ,legend.shrink=1, legend.width=1, zlim=c(0, 1), col = red_cols,
     axis.args=list(at=c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5), labels=red_levels)) 


