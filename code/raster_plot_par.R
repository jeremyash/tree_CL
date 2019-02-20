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
library(RColorBrewer)
#----------------------------------------------------------------------------



r <- raster(nrows=5, ncols=5, vals=1:25)


r <- raster(volcano)

plot(r, axes = FALSE, box = FALSE, legend = FALSE)
plot(r, legend.only=TRUE, horizontal = TRUE, smallplot = c(0.1,0.9,0.1,0.15), legend.args = list(text='My values [m^3]'))


# basal area and prop basal area


# png(file = "figures_base/ba_prop_test.png",
#     height = 5,
#     width = 8.5,
#     units = "in",
#     res = 300)


pdf(file = "figures_base/ba_prop_test.pdf",
    height = 5,
    width = 9)
par(mar = c(0,0,0,0), mfrow = c(1,2), oma = c(0,0,2,0))
plot(r,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     legend = FALSE,
     
     # colors
     col = ba_cols)

plot(r,
     
     #legend properties
     legend.only = TRUE,
     horizontal = TRUE,
     legend.width = 1.5,
     
     # colors
     col = ba_cols,
     
     # legend title
     legend.args=list(text=expression(m^2), 
                      line = 0.5,
                      side = 2,
                      cex = 1.1,
                      # adj = -0.2,
                      las = 1),
     
     # legend labels
     axis.args = list(cex.axis = 1.1,
                      mgp = c(2.5,0.5,0),
                      tck = -0.25)
     
     # add = TRUE)
)

title("Basal Area", line = -2, cex = 0.8)

plot(states_sh,
     
     #turn off plot features
     axes = FALSE,
     box = FALSE,
     
     # title
     # main = "Basal Area",
     
     # colors
     col = ba_cols,
     
     #legend properties
     legend.args=list(text=expression(m^2), line = 0.4, cex=1, adj = -1),
     axis.args = list(cex.axis = 1,
                      mgp = c(3,0.5,0),
                      tck = -0.25),
     
     legend.width = 1,
     legend.shrink = 0.4)
title("Proportional Basal Area", line = -2, cex = 0.8)
mtext("Species", side = 3, line = -0.5, cex = 2, font = 3, outer = TRUE)
dev.off()
# 
# 
# 
# 
# #----------------------------------------------------------------------------
# 
# # reduction and exceedance plots
# 
z <- raster(nrows=5, ncols=5, vals=c(seq(0,1,l=22),2,3, 0.009))
# plot(z)
# 
# 
# # reduction colors, breaks and levels/labels
# red_cols <- rev(brewer_pal(palette = "RdYlBu")(6))
# display.brewer.pal(6, "RdYlBu")
# red_breaks <- c(0, 0.000001, 0.01,0.05, 0.1, 0.2, 3.5)
# red_levels <- c("0",  
#                 "0-0.01",
#                "0.01-0.05",
#                "0.05-0.1", 
#                "0.1-0.2",
#                ">0.2")
# plot(z,
#      
#      #turn off plot features
#      axes = FALSE,
#      box = FALSE,
#      
#      # title
#      main = "Exceedance/reduction",
#      
#      # colors
#      col = red_cols,
#      
#      # breaks
#      breaks = red_breaks,
#      
#      # total range of colors
#      zlim = c(0, 3.5))
# 
# 
# legend(
#   x = "right",
#   ncol = 1,
#   legend = rev(red_levels),
#   fill = rev(red_cols),
#   # title = "%",
#   bty = "n",
#   # inset = -0.175,
#   y.intersp = 0.5,
#   x.intersp = 0.25,
#   cex = 3,
#   text.width = 20
# 
# )
# 
# 
# ###CLOSEST ATTEMPT SO FAR
# # window()
# 
# 
pdf(file = "figures_base/exc_test.pdf",
    height = 5,
    width = 8)


par(mfrow=c(2,2),mar=c(0,0,0,0),oma=c(0,0,2,4), xpd = NA)


plot(states_sh, axes = FALSE, box = FALSE, col = red_cols, breaks = red_breaks, legend = FALSE)
title("Growth - N", line = -2, cex = 0.8)

plot(states_sh, axes = FALSE, box = FALSE, col = red_cols, breaks = red_breaks, legend = FALSE)
title("Survival - N", line = -2, cex = 0.8)

plot(states_sh, axes = FALSE, box = FALSE, col = red_cols, breaks = red_breaks, legend = FALSE)
title("Growth - S", line = -2, cex = 0.8)

plot(states_sh, axes = FALSE, box = FALSE,  col = red_cols, breaks = red_breaks, legend = FALSE)
title("Survival  -S", line = -2, cex = 0.8)

mtext("Proportion Reduction in:", side = 3, line = -0.5, cex = 1.5, font = 2, outer = TRUE)



# library(ComplexHeatmap)
# plot.new()
draw(Legend(labels = red_labels, 
            title = "%",
            title_position = "topleft",
            legend_gp = gpar(fill = red_cols), 
            # gap = unit(5, "mm"),
            grid_height = unit(5, "mm"), 
            grid_width = unit(5, "mm"), 
            ncol = 1),
     x = unit(7.75, "in"),
     y = unit(4.5, "in"))



par(mfrow=c(1,1),new=FALSE, oma=c(0,0,0,0), mgp = c(2.5,0.25,0))

legend(
  x = "bottom",
  # y = 2500000,
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
