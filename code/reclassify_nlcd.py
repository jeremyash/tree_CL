# Name: reclassify_example02.py
# Description: Reclassifies the values in a raster.
# Requirements: Spatial Analyst Extension

# Import system modules
import arcpy
from arcpy import env
from arcpy.sa import *

# Set environment settings
env.workspace = "C:/Users/jash/Documents/projects/tree_CL/gis/forestown_v11"

# Set local variables
inRaster = "forestown.tif"
reclassField = "VALUE"
remap = RemapValue([[1,1], [2,1], [3,1], [9,0], [10,0], [11,0], [12,0], [13,0], [14,0], [15,0], [16,0], [17,0], [18,0], [19,0], [20,0]])

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

# Execute Reclassify
outReclassify = Reclassify(inRaster, reclassField, remap, "NODATA")

# Save the output 
outReclassify.save("C:/Users/jash/Documents/projects/tree_CL/gis/forownmask")
