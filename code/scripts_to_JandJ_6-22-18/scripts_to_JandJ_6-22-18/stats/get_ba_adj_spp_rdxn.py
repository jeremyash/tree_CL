'''
STATS Script # 3
6-20-18
searches data from output folder in project folder

Code below needs testing to confirm runs as intended --

I worked on but can't test currently because don't have ArcGIS installed
What code is meant to do [aside from inline comments]:
generate 4 csv spreadsheets: 2 for Nitrogen (growth and survival) + 2 for Sulfur (growth and survival)
Currently each record (for each species) in the spreadsheet will contain the species code and the scalar value for 
reduction for a variable (growth or survival) weighted by the species' summed basal area across the CONUS.

Later if need other stats from the reduction rasters I left in some lines of code from stats script #2 that can be adapted
or used as a skeleton to generate those stats and added to the output spreadsheet

hopefully output here is, e.g. for Nitrogen/growth,  'N_growth_ba_wtd_exceedance_rdxn.csv' containing rdxn weighted ba for ea spp for growth
then will go to survival in this loop and output another spreadsheet
then in next iteration then go to sulfur/growth, sulfur/survival

'''

import os
import timeit

import arcpy as ap
import arcpy.sa
import pandas as pd

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# record start time
start_time = timeit.default_timer()

element_list = ['n', 's']
variable_list = ['growth', 'survival']
for element in element_list:
    for variable in variable_list:

        # set paths to directories
        root_dir = ("<path to project folder>")
        # set path for output dir to hold spreadsheets
        stats_out_dir = os.path.join(root_dir, 'ba_adj_spp_reduction')
        # check for and create out_dir for spreadsheets if not exists
        if not ap.Exists(stats_out_dir):
            ap.CreateFolder_management(root_dir, 'ba_adj_spp_reduction')
        
        # Set paths to rasters output previously to be used to derive BA weighted reductions
        ras_root_dir = os.path.join(root_dir, 'output') # 'output' dir is the output folder in the project folder holding output from all previous code parts
        ba_ras_path = os.path.join(ras_root_dir, 'ba.gdb')# 'ba.gdb' is the gdb holding the raw basal area data for horn species 
        rdxn_path = os.path.join(ras_root_dir, '{}'.format(element).capitalize() + '_reduction.gdb') # '<element>_reduction.gdb' is the gdb holding the rdxn rasters for N or S
        
        # set scratch workspace
        ap.env.scratchWorkspace = os.path.join(ras_root_dir, 'scratch.gdb') # set scratch to avoid calc remnants left in gdbs
        
        # set workspaces so arcpy finds rasters to create lists needed below
        ap.env.workspace = ba_ras_path
        ba_list = ap.ListRasters('s*')
        ba_list = [os.path.join(ba_ras_path, ba) for ba in ba_list]
        ap.env.workspace = rdxn_path
        rdxn_list = ap.ListRasters('*{}*'.format(variable))
        
        #create gdb for raster output for calculations
        ba_rdxn_processing_path = os.path.join(root_dir, 'ba_adj_processing.gdb')
        if not ap.Exists(ba_rdxn_processing_path):
            ap.CreateFileGDB_management(root_dir, 'ba_adj_processing.gdb')
        
        zipped = zip(sorted(ba_list), sorted(rdxn_list))
        for z in zipped:
            #for each species get ba / rdxn combo 
            #SET OUTPUT PATH-using name for z[1] because most descriptive - clean this up later
            outras_path = os.path.join(ba_rdxn_processing_path, z[1])
            #MULTIPLY RDXN RASTER '(z[1])' BY BASAL AREA '(z[0])'
            outras_ba_rdxn_mult = ap.Raster(z[0]) * ap.Raster(z[1])
            #CONVERT RDXN MULT RASTER TO ARRAY FOR CALCS
            #WHAT DOES OVERFLOW ERROR MEAN / DOES IT NEED HANDLING - OCCURS WHEN DONT PUT VALUE FOR NO DATA TO VALUE ARG IN NUMPY RASTER TO ARRAY
            #arr = ap.RasterToNumPyArray(outras_ba_rdxn_mult, nodata_to_value=-9999)
            arr_mult = ap.RasterToNumPyArray(outras_ba_rdxn_mult, nodata_to_value=0)  # NOT SURE WHAT SHOULD SET NO DATA VALUE TO
            #SUM CELL VALUES FROM THE PRODUCT RDXN RASTER * BASAL AREA
            arr_mult_sum = arr_mult.sum()
            #DERIVE RDXN WEIGHTED BY BA
            #CONVERT BASAL AREA RASTER TO NUMPY ARRAY 
            arr_ba = ap.RasterToNumPyArray(ap.Raster(z[0]), nodata_to_value=0)
            #SUM VALUES FROM BASAL AREA NUMPY ARRAY
            arr_ba_sum = arr_ba.sum()
            #GENERATE RDXN WEIGHTED BY BA FOR SPP ACROSS CONUS:
            #DIVIDE SCALARS DERIVED FROM SUM OPERATIONS ABOVE 	
            wtd_ba = arr_mult_sum/arr_ba_sum
    
        ap.env.workspace = ba_rdxn_processing_path
        wtd_rdxn_tups_list = []
        ras_list_wtd_rdxn = ap.ListRasters('*{}*'.format(variable))
        #use these lines to get spp and variable from raster to export to spreadsheet headers
        for ras in ras_list_wtd_rdxn:
            print ras
            spp = ras[:4].strip('_')
            var = ras.split('_')[-2]
            ###keep these lines as placeholder in case need stats besides scalar value from weighted calcs above
            ##ras2 = ap.sa.SetNull(ras, ras, "VALUE=0")  # this set nulls to zero , setting could be changed according to what needed
            ##result_wtd_rdxn = ap.GetRasterProperties_management(ras2, '<SOME PROPTERTY>') # get result as object
            ##rdxn_'<SOME PROPERTY>' = result_wtd_rdxn.getOutput(0) # get output from object
            ##create list of tuples containing spp name and variable for spreadsheet headers
            ##tup = tuple([spp, rdxn_'<SOME PROPERTY>', var]) # create a tuple 
            ##rdxn_'<SOME PROPERTY>'_tups_list.append(tup) # append tuple to list 
            #create list of tuples containing spp name and variable for spreadsheet headers
            tup = tuple([spp, var]) 
            wtd_rdxn_tups_list.append(tup) 
            
        ##PLACE HOLDER - AGAIN, keep these lines as placeholder in case derived other stats above and now need to insert into spreadsheet output 
        ###d = dict([ (spp, ['<SOME PROPERTY>', var]) for spp, '<SOME PROPERTY>', var in rdxn_<SOME PROPERTY>_tups_list ])
        #### use pandas to export dict to table and then to csv
        ###df = pd.DataFrame.from_dict(d, orient='index')
        ###df.columns = [<SOME PROPERTY>', 'variable']
        #### handle variable formatting that ends up in csv
        ###df['<SOME PROPERTY>'] = df['<SOME PROPERTY>'].astype('float64')
        ####etc, add other cols as needed, see get_rdxn_stats.py
        ####insert corresponding spp name into first col each row
        ###df.index.name = 'spp_code'
        
        # use spp code and tuple list to create dict (i.e. key, values)   
        d = dict([ (spp, [var]) for spp, var in wtd_rdxn_tups_list])
        # use pandas to export dict to table and then to csv
        df = pd.DataFrame.from_dict(d, orient='index')
        #name the column for growth or survival 'variable'
        df.columns = ['variable']
        #insert corresponding spp name into first col each row and name column 'spp_code'
        df.index.name = 'spp_code'
        
        csv_out_path = os.path.join(stats_out_dir, '{}_{}_ba_wtd_exceedance_rdxn.csv'.format(element, variable))
        # hopefully output here is, e.g. for Nitrogen/growth,  'N_growth_ba_wtd_exceedance_rdxn.csv' containing rdxn weighted ba for ea spp for growth
        # then will go to Ssurvival in this loop and output another spreadsheet in next iteration then go to sulfur
        df.to_csv(csv_out_path, float_format='%.6f')

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'calculating weighted reduction [and other stats] took: ', elapsed_min, 'minutes'
