from __future__ import print_function #python 2/3
from grass.pygrass.modules import Module
import pandas as pd
import glob
import sys

reg = sys.argv[1] # pull the region from the command line arguments

# grass functions
r_external = Module('r.external')
r_what = Module('r.what')

def get_val(dat):
    '''
    query grass raster for value based on coordinates
    '''
    x = dat.x
    y = dat.y

    r_what(map = 'param_cpg', coordinates = (x,y), separator = ',', output = '/home/tbarnhart/projects/DEM_processing/data/reg_%s_cpgQuery.txt'%(reg), overwrite = True, quiet = True) # query the raster and output to text file

    with open('/home/tbarnhart/projects/DEM_processing/data/reg_01_cpgQuery.txt') as fl:
        out = fl.readline() # open and read the text file

    return float(out.split('\n')[0].split(',')[-1])

cpgs = glob.glob('./data/cpg_datasets/output_cpg/*_%s_cpg.tiff'%(reg)) # pull a list of cpgs

dat = pd.read_csv('./data/CATCHMENT_region_%s.csv'%(reg)) # load the dataset

for fl in cpgs: # iterate through each CPG
    CPG = fl.split('/')[-1].split('_%s'%reg)[0] # get CPG name

    r_external(input=fl, output='param_cpg', o = True, overwrite = True, quiet = True) # link the cpg

    dat[CPG] = dat.apply(get_val,axis=1) # query the maps
    print('Completed %s'%CPG)