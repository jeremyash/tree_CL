'''
 script #1. export rasters from folders to a single gdb for faster processing with arcpy

Create a root folder and put all the data into it, then this script will create a single output folder named 'output' to hold all outputs
---> subsequent scripts will create geodatabases within 'output' folder to hold outputs as needed

'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")  # TODO: TROUBLESHOOT need to add this line or get tool not licensed error even though imported sa
ap.env.parallelProcessingFactor = "100%"

# create path to directory holding data, call it root directory
root_dir = ('<your path to project folder containing all data to be processed>')
# create general output directory for all succeeding scripts / create directory if not already exists
out_dir = os.path.join(root_dir, 'output')
if not os.path.exists(out_dir):
    os.makedirs(out_dir)

# working on basal area files:
# create path within root dir to find .img files for export to single gdb
ba_data_path = os.path.join(root_dir, '<your path to source .img files >')

# create gdb within output folder to hold exported ba rasters /create if does not already exist
ba_gdb_path = os.path.join(out_dir, 'ba.gdb')
if not os.path.exists(ba_gdb_path):
    ap.CreateFileGDB_management(ba_gdb_path)

# record start time
start_time = timeit.default_timer()
# walk the root input path to get folder and file names
# hopefully this works for you, I think this was how mine unzipped and I didn't change the paths....
for (dirpath, dirnames, filenames) in os.walk(ba_data_path):
    if 'RasterMaps' in dirnames:
        print dirnames
        # set path to rasters
        raster_map_group_dir = os.path.join(dirpath, dirnames[0])
        # set input workspace so rasters can be found
        ap.env.workspace = raster_map_group_dir
        raster_list = ap.ListRasters()
        raster_count = len(raster_list)
        # loop thru raster list to export to gdb and convert from img to FGDB format
        for raster in raster_list:
            raster_path = os.path.join(ba_gdb_path, raster.replace('.img', ''))
            # check for existence so if code is not completed in one session doesn't waste time rewriting over if process restarted
            if ap.Exists(raster_path):
                print 'exists: ', raster
                pass
            else:
                ap.RasterToGeodatabase_conversion(raster, ba_gdb_path)

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'export to gdb', elapsed_min, 'minutes'



