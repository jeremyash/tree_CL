'''
script #5
output from this script: basal area where exceedance occurs outside range tabled wilson curve values (< min or > max) relative to values in tdep rasters

4-28-18
Chris updated table [Chris changed values for @max cols so that if response to @max was not flat or increasing AND if @max was NA >>  NA == n_min or s_min
also found some values in table, that are denoted as max or min, dont match values in tdep rasters [for 2013-2015] since those data are newer than
what was used to create max and min CLs for in the table

This code is to handle that: excludes vals outside max and min according to table, and outputs where that occurs
>> later Chris will decide how will use these rasters to characterize what is happening for spp where extrapolation
occurs outside range of species' response curves [which are associated with values in table, but disconnected now from updated tdep rasters]
'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"
# TODO -troubleshoot- why errors if scratch workspace setting here - work around: put down below into loop

# set path general output directory
root_dir = ('<your path to project folder>')
out_dir = os.path.join(root_dir, 'output')

# set path to input proportional rasters created in #3: select_horn_spp_calc_proportion
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')
# set path to tdep rasters
tdep_gdb_path = os.path.join(out_dir, 'tdep.gdb')

## loop thru all variables for N and S
# create output gdbs for extrapolation rasters
n_out_path_extrap = os.path.join(out_dir, 'N_dep_extrap.gdb')
if not ap.Exists(n_out_path_extrap):
    ap.CreateFileGDB_management(out_dir, 'N_dep_extrap.gdb')

s_out_path_extrap = os.path.join(out_dir, 'S_dep_extrap.gdb')
if not ap.Exists(s_out_path_extrap):
    ap.CreateFileGDB_management(out_dir, 'S_dep_extrap.gdb')


# record start time
start_time = timeit.default_timer()

# create variable lists for looping thru
response_variables = ['growth', 'survival']
elements = ['n', 's']

# set tdep raster paths n_tw_0002  or s_tw_0002  <or>  n_tw_13150  or s_tw_13150
for element in elements:
    tdep_Raster = os.path.join(tdep_gdb_path, '{}_tw_0002'.format(element))
    for response_variable in response_variables:
        # set input workspace so arcpy can find proportional rassters
        ap.env.workspace = spp_prop_ba_gdb_path
        # set save paths (will be either of the S_dep or N_dep geodatabases we created above)
        gdb_save_path_extrap = os.path.join(out_dir, '{}'.format(element).capitalize() + '_dep_extrap.gdb')
        ap.env.scratchWorkspace = os.path.join(out_dir, 'scratch.gdb')

        # list proportional rasters for looping thru
        spp_prop_ba_raster_list = ap.ListRasters()
        for spp_raster in spp_prop_ba_raster_list:
            # save names for extrapolated values output
            out_raster_name_extrap = '{0}_exc_{1}_{2}_tdep_extrap'.format(spp_raster, element, response_variable)
            out_raster_save_path_extrap = (os.path.join(gdb_save_path_extrap, out_raster_name_extrap))
            # check for existence of previously processed rasters, skip if already done
            print 'checking for existence of extrapolated raster in output', gdb_save_path_extrap
            if ap.Exists(out_raster_save_path_extrap):
                print 'exists in output: ',  out_raster_save_path_extrap, '.....going to next raster ', '\n'
                pass
            else:
                print 'spp raster does not exist in output, check for critical load values:  ', spp_raster
                spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
                #set environments to handle differing resolutions rasters
                #set the cell size environment using a raster dataset.
                ap.env.cellSize = spp_raster_path
                # set output coordinate system
                spatial_ref = ap.Describe(spp_raster_path).spatialReference
                ap.env.outputCoordinateSystem = spatial_ref
                #set Snap Raster environment
                ap.env.snapRaster = spp_raster_path
                inTrueRaster = spp_raster
                inFalseConstant = 0
                spp_code = int(spp_raster.split('_')[0][1:])
                # set path to tdep value table to iterate thru values below
                table = os.path.join(spp_prop_ba_gdb_path, '{}').format(response_variable)
                # use Cursor to access each row within fields
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element), 'min_{}'.format(element), 'max_{}'.format(element)]) as cursor:
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None:
                            print 'no critical load value, **skipping** ', spp_code, ', row = ', row, '\n'
                            print '----------------------'
                        elif row[0] == spp_code and row[1] is not None:
                            print 'found critical load value, processing ', spp_code, ', row = ', row, '\n'
                            whereClause =  (("VALUE <{}".format(row[2]))) or (("VALUE >{}".format(row[3])))
                            outCon = ap.sa.Con(tdep_Raster, inTrueRaster, inFalseConstant, whereClause)
                            print '***SAVING EXTRAPOLATED RASTER OUPUT***  saving to: ', out_raster_save_path_extrap, '\n'
                            outCon.save(out_raster_save_path_extrap)

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'creating exptrapolated exceedance rasters', elapsed_min, 'minutes'













