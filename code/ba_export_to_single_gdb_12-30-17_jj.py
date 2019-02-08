#  jen j  12-30-17
# 1. export rasters from folders to a single gdb for faster processing with arcpy


import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True

# working on basal area files:
# create root input path to find .img files for export to gdb
user_path = os.path.expanduser('~')
ba_data_path = os.path.join(user_path, '<your path to source .img files >')

# create folder for single gdb output / create if not already exists
ba_out_dir = os.path.join(user_path, '<your path to output folder>')
if not os.path.exists(ba_out_dir):
    os.makedirs(ba_out_dir)

# create gdb within output folder to hold exported ba rasters /create if not already exists
ba_gdb_path = os.path.join(ba_out_dir, 'ba.gdb')
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
print 'export to gdb', elapsed_min, 'minutes'  # took about three hours

# print 'debug'


