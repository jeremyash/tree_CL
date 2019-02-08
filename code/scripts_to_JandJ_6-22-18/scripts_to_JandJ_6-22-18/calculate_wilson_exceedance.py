'''
script #4
# calculate where Horn species are in exceedance according to Wilson response curves

last run on 2000-2002 tdep rasters so for others have to change 
i.e. line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))
'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# set path general output directory
root_dir = ('<your path to project folder>')
out_dir = os.path.join(root_dir, 'output')

# set path to input proportional rasters gdb created in #3: select_horn_spp_calc_proportion
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# set scratch workspace to hold intermediary calculated rasters
scratch_gdb_path = os.path.join(out_dir, 'Scratch.gdb')
if not ap.Exists(scratch_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'Scratch.gdb')

# import tdep value tables for growth and survival into input proportional rasters gdb
growthTable = os.path.join(root_dir, 'growth.csv')
growth_table_path = os.path.join(spp_prop_ba_gdb_path, growthTable)
growth_table_check_path = os.path.join(spp_prop_ba_gdb_path, 'growth')
if not ap.Exists(growth_table_check_path):
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=spp_prop_ba_gdb_path)

survivalTable = os.path.join(root_dir, 'survival.csv')
survival_table_path = os.path.join(spp_prop_ba_gdb_path, survivalTable)
survival_table_check_path = os.path.join(spp_prop_ba_gdb_path, 'survival')
if not ap.Exists(survival_table_check_path):
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=spp_prop_ba_gdb_path)

# create output gdbs
# additionally import tdep values tables into output gdbs in preparation for next step: reduction calculations
n_out_path = os.path.join(out_dir, 'N_dep.gdb')
if not ap.Exists(n_out_path):
    ap.CreateFileGDB_management(out_dir, 'N_dep.gdb')
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=n_out_path)
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=n_out_path)

s_out_path = os.path.join(out_dir, 'S_dep.gdb')
if not ap.Exists(s_out_path):
    ap.CreateFileGDB_management(out_dir, 'S_dep.gdb')
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=s_out_path)
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=s_out_path)

# import tdep rasters from source folders into a single gdb
# create output gdb for exported tdep rasters / if tdep gdb does not exist create it
tdep_gdb_path = os.path.join(out_dir, 'tdep.gdb')
if not ap.Exists(tdep_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'tdep.gdb' )
    
#TODO add something here to skip over importing tdep into tdep gdb if already done
# path to tdep data folder / walk folders and export both rasters to tdep.gdb just created
# tdep_data_path = os.path.join(root_dir, 'total_deposition')
# for (dirpath, dirnames, filenames) in os.walk(tdep_data_path):
    # if '_tw' in dirpath[:-4]:
        # ap.RasterToGeodatabase_conversion(Input_Rasters=dirpath, Output_Geodatabase=tdep_gdb_path, Configuration_Keyword="")
## I HAD TO CONVERT THE TDEP RASTERS FOR THE 2000_2002 RUN FROM e00 FORMAT, I DON'T REMEMBER NEEDING TO FOR 2013-2015 TDEP RASTERS...
## USE e00_convert.py TO DO THAT IF NEEDED THEN YOU CAN RUN ABOVE BLOCK

# record start time
start_time = timeit.default_timer()

# create variable lists for looping thru
response_variables = ['growth', 'survival']
elements = ['n', 's']

# set tdep raster paths n_tw_0002  or s_tw_0002 [for eg 2000-2002 run]
for element in elements:
    # path to tdep raster
    tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))
    for response_variable in response_variables:
        # set input workspace so arcpy can find proportional rassters
        ap.env.workspace = spp_prop_ba_gdb_path
        # set save paths (will be either of the S_dep or N_dep geodatabases created above)
        gdb_save_path = os.path.join(out_dir, '{}'.format(element).capitalize() + '_dep.gdb')

        # list proportional rasters for looping thru
        spp_prop_ba_raster_list = ap.ListRasters()
        for spp_raster in spp_prop_ba_raster_list:
            # create save names and save paths for raster so can check if already exists in output gdb;skip if already done
            out_raster_name = '{0}_exc_{1}_{2}'.format(spp_raster, element, response_variable)
            out_raster_save_path = os.path.join(gdb_save_path, out_raster_name)
            ap.env.scratchWorkspace = os.path.join(out_dir, 'Scratch.gdb')
            print '**check**: element, response variables match for in and out file names:', out_raster_name + ':', element, response_variable
            if ap.Exists(out_raster_save_path):
                print 'out file name = ', out_raster_name
                print ' >>> EXISTS IN OUTPUT EXCEEDANCE gdb, go to next raster', '\n'
                pass
            else:
                print 'does not exist in output gdb, process raster ', spp_raster
                print 'exceedance raster will be saved to : ', out_raster_save_path, '\n'
                #create path to proportioanal raster
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
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element)]) as cursor:
                    print 'checking for critical load values...'
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None: # skipping over species with flat responses, ie no values in n1 or s1
                            print 'no critical load value, skipping ', spp_raster, ', row = ', row, '\n'
                            print '-----------------------'
                        elif row[0] == spp_code and row[1] is not None:
                            print 'found critical load value, calculating exceedance raster...'
                            # 'row' is a tuple, and looks like this, for e.g. for species # 121:  (121, 12.32753)
                            whereClause = "VALUE >={}".format(row[1])  # 'Value' is pulled from the second number in row, that comes from the table, value for n1 or s1
                            outCon = ap.sa.Con(tdep_Raster, inTrueRaster, inFalseConstant, whereClause)
                            outCon.save(os.path.join(out_raster_save_path))
                            print '***EXCEEDANCE saved to***', out_raster_save_path, '\n'


# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'creating exceedence for proportional rasters', elapsed_min, 'minutes'












