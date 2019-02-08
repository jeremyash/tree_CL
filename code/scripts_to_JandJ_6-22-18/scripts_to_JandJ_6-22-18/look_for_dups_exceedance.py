# http://pro.arcgis.com/en/pro-app/tool-reference/spatial-analyst/conditional-evaluation-with-con.htm
# http://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/complete-listing-of-spatial-analyst-tools.htm

'''
testing to see how many spp have s or n exceedance for growth or survival
AND exceedance for S AND N
'''

import os

import arcpy as ap
import arcpy.sa

ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

root_dir = ("F://tdep_mapping_usfs//tdep_2000_2002_run")
out_dir = os.path.join(root_dir, 'output')

response_variables = ['growth', 'survival']
elements = ['n', 's']

n_path = os.path.join(out_dir, 'N_dep.gdb')
s_path = os.path.join(out_dir, 'S_dep.gdb')

ap.env.workspace = n_path
n_list = sorted(ap.ListRasters())

ap.env.workspace = s_path
s_list = sorted(ap.ListRasters())

# find matching spp codes in ndep and sdep gdbs
# make both lists a set object
n_set_growth = sorted(set([n[:4] for n in n_list if 'growth' in n]))
s_set_growth = sorted(set([s[:4] for s in s_list if 'growth' in s]))

# try to find spp codes that have exceedances for n AND s (AND growth OR survival)
# mash n_list and s_list together
n_list.extend(s_list)

# remove growth or survival variable
no_varList = sorted([n.rpartition('_')[0] for n in n_list])
# remove spp codes that occur only once
# create index list for finding spp codes
sppList1 = sorted([i[:4] for i in no_varList])
# remove singular spp codes and those cannot have exceedances for n AND s
sppList2 = sorted([i for i in sppList1 if not sppList1.count(i)==1])
# use sspList to clean no_var_list: get rid of singulars
no_varList2 = sorted([i for i in no_varList if i[:4] in sppList2])
sppList3 = sorted(list(set(no_varList)))

test = sorted([i[:4] for i in sppList3])
test2 =  sorted([i for i in test if not test.count(i)==1])
sppList_s_and_n_exc = sorted([i for i in sppList3 if i[:4] in test2])


print 'debug'
