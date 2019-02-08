# jen j 12-30-17
# 2. this creates the national forest basal area (sums all the basal area rasters, whether Wilson or not)

'''
we want ALL the species whether wilson or not for the national forest total, as I recall... right?
'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.env.parallelProcessingFactor = "100%"

# path to root directory for processed ba rasters
user_path = os.path.expanduser('~')
ba_out_dir = os.path.join(user_path, '<your path to ba out dir>')
ba_gdb_path = os.path.join(ba_out_dir, 'ba.gdb')

# set input workspace so arcpy can find basal area rasters
ap.env.workspace = ba_gdb_path

# start summing process
start_time = timeit.default_timer()

ba_raster_list = ap.ListRasters()
print len(ba_raster_list) # all are there, 324 rasters
# if the process gets interrupted there will be an extra temp raster in the gdb, check for these
if len(ba_raster_list) == 324:
    outCellStatistics = ap.sa.CellStatistics(ba_raster_list, "SUM", "DATA")
    outCellStatistics.save(os.path.join(ba_copy_gdb_path, 'ba_natl_forest'))
else:
    # code will stop here if finds extra raster(s) leftover from previous runs, delete manually and restart
    # can do this programatically , could add to code later if seems needed
    pass

elapsed_min = (timeit.default_timer() - start_time)/60
print 'summing rasters took ', elapsed_min, 'minutes' # took 53 minutes on my machine


print 'debug'



