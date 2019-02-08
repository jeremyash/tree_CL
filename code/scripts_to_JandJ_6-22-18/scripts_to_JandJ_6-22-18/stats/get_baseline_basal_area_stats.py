'''
6-20-18
STATS script #1
searches data from output folder in project folder

gets stats for basal area for horn species: 
sum for basal area for species across CONUS and
the max basal area value for the species [ba_sum_SQ_Meters', 'ba_max_SQ_Meters']
> outputs to spreadsheet in folder named 'stats_basal_area'
'''


import os
import timeit

import arcpy as ap
import arcpy.sa
import numpy as np
import pandas as pd

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# set paths to directories
root_dir = ('<your path to project folder>')
out_dir = os.path.join(root_dir, 'stats_basal_area')
# check for and create out_dir for stats if not exists
stats_dir_path = os.path.join(root_dir, 'stats_basal_area')
if not ap.Exists(stats_dir_path):
    ap.CreateFolder_management(root_dir, 'stats_basal_area')
# set input path to reduction rasters for nitrogen
ba_root_dir = os.path.join(root_dir, 'output')
ba_path = os.path.join(ba_root_dir, 'ba.gdb')


# set scratch workspace
ap.env.scratchWorkspace = os.path.join(ba_root_dir, 'scratch.gdb')
# set workspace so arcpy finds rasters in reduction gdb
ap.env.workspace = ba_path

# record start time
start_time = timeit.default_timer()
ba_stats_tups_list = []

# sum all of the floating point values in each raster
# get other stats also
ras_list = ap.ListRasters()
for ras in ras_list:
    if not 'ba' in ras:
        spp = ras[:4].strip('_')
        print 'processing: ', ras
        # arr = ap.RasterToNumPyArray(ras, nodata_to_value=-9999)  # NOT SURE WHAT SHOULD SET NO DATA TO
        arr = ap.RasterToNumPyArray(ras)
        arr_sum = arr.sum()
        arr_max = arr.max()
        tup = tuple([spp, arr_sum, arr_max])
        ba_stats_tups_list.append(tup)
    else:
        spp = ras
        print 'processing: ', ras
        arr = ap.RasterToNumPyArray(ras, nodata_to_value=0)
        arr_sum = arr.sum()
        arr_max = arr.max()
        tup = tuple([spp, arr_sum, arr_max])
        ba_stats_tups_list.append(tup)

d = dict([ (spp, [arr_sum, arr_max]) for spp, arr_sum, arr_max in ba_stats_tups_list ])
df = pd.DataFrame.from_dict(d, orient='index')
df.columns = ['ba_sum_SQ_Meters', 'ba_max_SQ_Meters']
df.index.name = 'spp_code'
csv_out_path = os.path.join(out_dir, 'source_basal_area_sums.csv')
df.to_csv(csv_out_path, float_format='%.6f')

# print 'debug'

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'getting stats for basal area rasters took: ', elapsed_min, 'minutes'
