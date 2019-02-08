'''
6-20-18
STATS script #2
searches data from output folder in project folder


outputs reduction mean and reduction mean percentage as csv to folder 'mean_spp_exceedance_reduction'
'''


import os
import timeit

import arcpy as ap
import arcpy.sa
import pandas as pd

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# set paths to directories
root_dir = ('<your path to project folder>')
stats_out_dir = os.path.join(root_dir, 'mean_spp_exceedance_reduction')
# check for and create out_dir for stats if not exists
if not ap.Exists(stats_out_dir):
    ap.CreateFolder_management(root_dir, 'mean_spp_exceedance_reduction')
# set input path to reduction rasters for nitrogen
rdxn_root_dir = os.path.join(root_dir, 'output')
n_rdxn_path = os.path.join(rdxn_root_dir, 'N_reduction.gdb')
# set scratch workspace
ap.env.scratchWorkspace = os.path.join(rdxn_root_dir, 'scratch.gdb')
# set workspace so arcpy finds rasters in reduction gdb
ap.env.workspace = n_rdxn_path

# record start time
start_time = timeit.default_timer()
rdxn_means_tups_list = []
ras_list_n = ap.ListRasters()
for ras in ras_list_n:
    print ras
    spp = ras[:4].strip('_')
    var = ras.split('_')[-2]
    ras2 = ap.sa.SetNull(ras, ras, "VALUE=0")
    result_rdxn_mean = ap.GetRasterProperties_management(ras2, 'MEAN')
    rdxn_mean = result_rdxn_mean.getOutput(0)
    tup = tuple([spp, rdxn_mean, var])
    rdxn_means_tups_list.append(tup)

d = dict([ (spp, [rdxn_mean, var]) for spp, rdxn_mean, var in rdxn_means_tups_list ])
# use pandas to export dict to table and then to csv
df = pd.DataFrame.from_dict(d, orient='index')
df.columns = ['rdxn_mean', 'variable']
# handle variable formatting that ends up in csv
df['rdxn_mean'] = df['rdxn_mean'].astype('float64')
# add column for percentage calc
rdxn_pct_mean_col = df['rdxn_mean'].multiply(100)
df.insert(1, 'rdxn_percentage_mean', rdxn_pct_mean_col, allow_duplicates=False)
df.index.name = 'spp_code'

csv_out_path = os.path.join(stats_out_dir, 'nitrogen_mean_spp_exceedance_rdxn.csv')
df.to_csv(csv_out_path, float_format='%.6f')

#------------------
# work on sulfur stats

# set input path and workspace to reduction rasters location for sulfur
s_rdxn_path = os.path.join(rdxn_root_dir, 'S_reduction.gdb')
ap.env.workspace = s_rdxn_path

rdxn_means_tups_list = []
ras_list_s = ap.ListRasters()
for ras in ras_list_s:
    print ras
    spp = ras[:4].strip('_')
    var = ras.split('_')[-2]
    ras2 = ap.sa.SetNull(ras, ras, "VALUE=0")
    result_rdxn_mean = ap.GetRasterProperties_management(ras2, 'MEAN')
    rdxn_mean = result_rdxn_mean.getOutput(0)
    tup = tuple([spp, rdxn_mean, var])
    rdxn_means_tups_list.append(tup)

d = dict([ (spp, [rdxn_mean, var]) for spp, rdxn_mean, var in rdxn_means_tups_list ])
df = pd.DataFrame.from_dict(d, orient='index')
df.columns = ['rdxn_mean', 'variable']
df['rdxn_mean'] = df['rdxn_mean'].astype('float64')
rdxn_pct_mean_col = df['rdxn_mean'].multiply(100)
df.insert(1, 'rdxn_percentage_mean', rdxn_pct_mean_col, allow_duplicates=False)
df.index.name = 'spp_code'

csv_out_path = os.path.join(stats_out_dir, 'sulfur_mean_spp_exceedance_rdxn.csv')
df.to_csv(csv_out_path, float_format='%.6f')



# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'getting means from reduction rasters took: ', elapsed_min, 'minutes'
