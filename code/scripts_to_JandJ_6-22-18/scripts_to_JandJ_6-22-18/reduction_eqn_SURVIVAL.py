'''
script #6b - calculate reduction percentages for survival only

[script #6a - calculate reduction percentages for growth only]
>> separated currently because rdxn for growth and survival not same calculation
# TODO - incorporate both into one script, use fxns
       - ADD other checks for rasters
       - is there any way to get scalar value from in_memory obj so prints a value?  line 108
'''

import os
import timeit

import arcpy as ap
import arcpy.sa
from arcpy.sa import Divide, Exp, Ln, Square, Times # use math functions from spatial analyst instead of math module

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# set path general output directory
root_dir = ('<your path to project folder>')
out_dir = os.path.join(root_dir, 'output')

# create output gdbs
n_rdxn_out_path = os.path.join(out_dir, 'N_reduction.gdb')
if not ap.Exists(n_rdxn_out_path):
    ap.CreateFileGDB_management(out_dir, 'N_reduction.gdb')

s_rdxn_out_path = os.path.join(out_dir, 'S_reduction.gdb')
if not ap.Exists(s_rdxn_out_path):
    ap.CreateFileGDB_management(out_dir, 'S_reduction.gdb')

# create variable lists for looping thru
response_variables = ['survival']
elements = ['s', 'n']

# record start time
start_time = timeit.default_timer()

# set tdep raster paths n_tw_0002 or s_tw_0002
for element in elements:
    tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))
    exc_path = os.path.join(out_dir, '{}_dep.gdb'.format(element).capitalize())
    ap.env.workspace = exc_path
    for response_variable in response_variables:
        spp_exc_raster_list = ap.ListRasters('*survival*')
        for spp_exc_raster in spp_exc_raster_list:
            if response_variable in spp_exc_raster:
                print '**check**: element, response variables match for in and out file names:', spp_exc_raster + ':', element, response_variable
                ## ADD CHECK HERE FOR RASTER SIZE? OTHER THINGS TO CHECK?
                # create save names and save paths for raster so can check for existence
                out_raster_name = '{0}_{1}_{2}_reduction'.format(spp_exc_raster, element, response_variable)
                out_raster_save_path = os.path.join(os.path.join(out_dir, '{}_reduction.gdb'.format(element).capitalize()), out_raster_name)
                # check for existence of previously processed rasters, skip if already done
                if ap.Exists(out_raster_save_path):
                    print 'out file name = ', out_raster_name
                    print ' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path
                    print 'going to next raster', '\n'
                else:
                    print 'does not exist in output gdb, .....process raster ', spp_exc_raster
                    spp_exc_raster_path = os.path.join(exc_path, spp_exc_raster)
                    print 'redxn raster will be saved to : ', out_raster_save_path, '\n'
                    # test if spp raster has exceedance values, if not pass
                    maxResult = ap.GetRasterProperties_management(spp_exc_raster_path, 'MAXIMUM')
                    print '**check** for exceedance values...'
                    if maxResult.getOutput(0) == '0':
                        print 'no exceedance values, skipping raster: ', spp_exc_raster, '\n'
                        pass
                    else:
                        print 'found exceedance values, going to calculations loop'
                        # extract tdep raster values where spp in exceedance
                        # set environments to handle differing resolutions rasters
                        ap.env.cellSize = spp_exc_raster_path
                        spatial_ref = ap.Describe(spp_exc_raster_path).spatialReference
                        ap.env.outputCoordinateSystem = spatial_ref
                        ap.env.snapRaster = spp_exc_raster_path
                        rasObj = ap.sa.Con((ap.Raster(spp_exc_raster_path)>0) & (ap.Raster(tdep_Raster)>0), (ap.Raster(tdep_Raster)), 0)

                        # setting scratch wksp to memory stops intermediary output (from divide, exp, etc) from being written to current workspace
                        ap.env.scratchWorkspace = 'in_memory'
                        ## read values need for reduction eqn from tables
                        spp_code = int(spp_exc_raster.split('_')[0][1:])
                        table = os.path.join(exc_path, '{}').format(response_variable)
                        with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element), '{}2'.format(element), '{}dep_max'.format(element)]) as cursor:
                            for row in cursor:
                                if row[0] == spp_code and row[3] == 0:
                                    print 'skipping ', spp_code, ', {}dep_max'.format(element), 'is null',  '\n'
                                elif row[0] == spp_code and row[3] is not None:
                                    if cursor.fields[1] == '{}1'.format(element):
                                        element1 = row[1]
                                    if cursor.fields[2] == '{}2'.format(element):
                                        element2 = row[2]
                                    if cursor.fields[3] == '{}dep_max'.format(element):
                                        dep_max = row[3]
                                        print 'values for spp code,', '{}1,'.format(element), '{}2,'.format(element), '{}dep_max = '.format(element), row
                                        ### dep value from con raster object ###
                                        ## numerator survival reduction
                                        dep_div_element1 = Divide(rasObj, element1)
                                        print 'calculating numerator'
                                        ln_dep_div_element1 = Ln(dep_div_element1)
                                        ln_dep_div_element1_div_element2 = Divide(ln_dep_div_element1, element2)
                                        sq_ln_dep_div_element1_div_element2 = Square(ln_dep_div_element1_div_element2)
                                        e_exp_numerator = Times(sq_ln_dep_div_element1_div_element2, -5.0)
                                        numerator_survival = Exp(e_exp_numerator)
                                        print 'numerator_survival: ', numerator_survival
                                        ## TODO - is there any way to get scalar value from in_memory obj so prints a value?

                                        ## denominator survival reduction
                                        # denominator is scalar not a raster
                                        print 'calculating demoninator'
                                        dep_max_div_element1 = Divide(dep_max, element1)
                                        ln_dep_max_div_element1 = Ln(dep_max_div_element1)
                                        ln_dep_max_div_element1_div_element2 = Divide(ln_dep_max_div_element1, element2)
                                        sq_ln_dep_max_div_element1_div_element2 = Square(ln_dep_max_div_element1_div_element2)
                                        e_exp_denominator = Times(sq_ln_dep_max_div_element1_div_element2, -5.0)
                                        denominator_survival = Exp(e_exp_denominator)
                                        print 'denominator_survival: ', denominator_survival

                                        ## reduction percentage
                                        print 'calculating survival reduction percentage raster'
                                        red_survival = 1 - (Divide(numerator_survival, denominator_survival))
                                        red_survival.save(out_raster_save_path)
                                        print '***RED SURVIVAL saved to***', red_survival
                                        print 'rdxn calculation complete', '\n'
                                        print '-------------------------'

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'creating survival reduction rasters took ', elapsed_min, 'minutes'



