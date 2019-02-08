# only way I could get convert from interchange file to work
# converting tdep rasters for yrs 2000-2002
'''
files from
ftp://ftp.epa.gov/castnet/tdep/grids/s_tw/    File: s_tw-0002.zip
ftp://ftp.epa.gov/castnet/tdep/grids/n_tw/   File: n_tw-0002.zip
unzip and put into project folder containing all the inputs

'''


import arcpy as ap
from arcpy import env
import os

project_dir =  "<path to your project folder>//total_deposition"
output_dir = os.path.join(project_dir, 'grids')
env.workspace = project_dir

var_list = ['n', 's']

for var in var_list:
    importE00File = "{}_tw-0002.e00".format(var)
    outDirectory = output_dir
    outName = "{}_tw-0002".format(var)

    # Delete pre-existing output
    if env.overwriteOutput :
        if os.path.exists(outName):
            os.remove(outName)

    # Execute ImportFromE00
    ap.ImportFromE00_conversion(importE00File, outDirectory, outName)





