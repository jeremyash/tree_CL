# jen j 12-30-17
# 4.  working on exceedance part, not finished

'''
also still confused about this: we want the proportional values in the pixels that are in exceedance, right?
that is what I did below...the output rasters show proportional ratio values to national forest, excluding pixels not in exceedance
if this is incorrect, we can read the basal area rasters instead of the proportional ones, so that the output rasters would have their
absolute basal area, excluding pixels not in exceedance.   Maybe we need both? so this would be what is in steps 4. and 5. in Justin's
workflow.docx.    so all we do is change how it's symbolized?  not sure   yes, still confused.

still have to think about stats and from which outputs we need them :
we can use ap.GetRasterProperties_management(<'raster name'>, 'MEAN') and also can get other params: 'MINIMUM' 'MAXIMUM'
To calculate total number of all pixel/cells can also use same GetRasterProperties_management() with COLUMNCOUNT and ROWCOUNT parameter.
maybe there's other tools, like Aggregate. These are float rasters for which you can't make an attribute table, or the values will be truncated -
so we can't use Zonal Statistics, for example.

raster calculator is not meant to be used in a geoprocessing environment - I used the Con tool via spatial analyst

for the end mapping result i am still not sure about excluding values = 0 in proportional rasters before we calculate exceedance in this script?
ie if we classify the result from this code into breaks (as Robert's example maps were), zero would be included in the lowest-valued, first break
so i don't know if we need to keep the 0 valued pixel for later calulations? I am still having trouble thinking ahead about what we need
if they are not wanted from this output, we can exclude in the mapping later if we need to - I am saying that if 0 is excluded in classified map,
the map displays only where the species is in exceedance on conus.  Otherwise, all the 0 valued pixels, where the species does not exist, are mapped also

i HATE making up variable names, and folder names....my mentor says it is good to make descriptive names, even if they are overly - long
as that is in the spirit of Python (readability!) --  so if you think my names are awkward, that's why - i am open to new suggestions


'''

import os
import timeit

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial") # for some reason I have to add this line or get tool not licensed error even though imported sa

# set path for processed proportional wilson spp / natl forest rasters
user_path = os.path.expanduser('~')
ba_out_dir = os.path.join(user_path, '<your path>')
spp_prop_ba_gdb_path = os.path.join(ba_out_dir, 'spp_proportion_ba.gdb')

'''
I manually exported the tdep rasters [i.e. named n_tw-13150  /  s_tw-13150 to their own gdb , I didn't write code for that
'''
# set tdep raster path
# later we can loop thru to get s_tw_13150 also
tdep_path = 'E://tdep_mapping_usfs_nps//tdep.gdb//n_tw_13150'
# tdep raster will be used below for the conditional raster calculator step below

# create tables from master tdep table tabs and save in the proportional gdb
# later the tables will be used to read from to get n1 values for exceedance
# and later can loop thru for both growth and survival for both N or S exceedance
# and export to separate 4 separate gdbs, if we want, or to a single gdb , whatever
'''
SEE email ATTACHED CLEANED TABLE 'MASTER_Table_for_gis.xlsx' to see the tabs from which the tables will be made
before creating tables i manually cleaned up the master tdep spreadsheet headings - arcpy does not like '@'
in column headings, for example - I also got rid of periods, stuff like that
'''
intable = "E://tdep_mapping_usfs_nps//MASTER_Table_for_gis.xlsx"  # set your own path to the table
response_variables = ['growth', 'survival'] # these correspond to partial tab names
for response_variable in response_variables:
    sheet_name = '{}_clean'.format(response_variable)
    outtable = os.path.join(spp_prop_ba_gdb_path, sheet_name)
    print sheet_name
    # read tabs, convert to gdb table and save in the gdb
    ap.ExcelToTable_conversion(intable, outtable, sheet_name)


# set input workspace so arcpy can find calculated proportional rasters
ap.env.workspace = spp_prop_ba_gdb_path

# set output save path, for saving testing results
# for testing i just save to my default gdb, you may have the same path here!
user_path = os.path.expanduser('~')
save_path = os.path.join(user_path, 'Documents//ArcGIS//Default.gdb')

# just testing on one raster, otherwise if the specific raster name was not listed, 's105_proportion'
# we can use ('s*') in the argument to get all the species rasters into the list, then we would loop thru
spp_prop_ba_raster_list = ap.ListRasters('s105_proportion')
for spp_raster in spp_prop_ba_raster_list:
    print spp_raster
    spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
    print spp_raster_path
    # set environments to handle differing resolutions rasters (tdep vs wilson rasters)
    # Set the cell size environment using the spp raster
    ap.env.cellSize = spp_raster_path
    # set output coordinate system
    spatial_ref = ap.Describe(spp_raster_path).spatialReference
    ap.env.outputCoordinateSystem = spatial_ref
    # # # Set Mask environment
    # # ap.env.mask = spp_raster_path   # ?NEED  I DONT KNOW IF THIS DOES ANYTHING ANYWAY WORKING ON STILL
    # Set snap raster environment
    ap.env.snapRaster = spp_raster_path
    # set up conditional values for map algebra / raster calculator to find proportional pixels in exceedance
    in_tdep_raster = tdep_path  # just changing name so reads better
    if_true_raster = spp_raster
    if_false_constant = 0
    # USE CURSOR HERE TO GET REAL exceedance VALUES for n1 / s1 etc from tables
    '''
    search cursors
    http://pro.arcgis.com/en/pro-app/arcpy/get-started/data-access-using-cursors.htm
    '''
    # exceedance_value here would be read from the table
    # this is just a made up one for testing...it works!!!
    exceedance_value = "VALUE >= 8"
    outCon = ap.sa.Con(in_tdep_raster, if_true_raster, if_false_constant, exceedance_value)
    out_raster_name = '{}_exc_n_growth'.format(spp_raster)
    outCon.save(os.path.join(save_path, out_raster_name))

print 'debug'












