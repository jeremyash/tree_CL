'''
script #2. creates the national forest basal area (sums all the basal area rasters, whether Horn/characterized by Wilson or not)
'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

root_dir = ('<your path to project folder containing all data to be processed>')
out_dir = os.path.join(root_dir, 'output')

# set scratch workspace manually to store temporary rasters from calcualations
# so that remnants are not stored in output gdb if process is interrupted
# create scratch gdb first
scratch_gdb_path = os.path.join(out_dir, 'scratch.gdb')
if not ap.Exists(scratch_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'scratch.gdb')
ap.env.scratchWorkspace = os.path.join(root_dir, 'scratch.gdb')

# start summing process to derive national forest raster
start_time = timeit.default_timer()

# set output path for summed raster
ba_gdb_path = os.path.join(out_dir, 'ba.gdb')
# set input workspace so arcpy can find basal area rasters
ap.env.workspace = ba_gdb_path

ba_raster_list = ap.ListRasters()
print 'raster count should be 324 / raster count == ', len(ba_raster_list) #check raster count
# make sure all rasters are present or no left-over intermediary calculaion rasters from copy process (script #1)
if len(ba_raster_list) == 324:
    print 'summing rasters...'
    outCellStatistics = ap.sa.CellStatistics(ba_raster_list, "SUM", "DATA")
    outCellStatistics.save(os.path.join(ba_gdb_path, 'ba_natl_forest'))
else:
    print 'raster list count incorrect'
    # if raster count != 324, will break out of loop: needs troubleshooting
    pass

elapsed_min = (timeit.default_timer() - start_time)/60
print 'summing rasters to get national forest raster took ', elapsed_min, 'minutes'





