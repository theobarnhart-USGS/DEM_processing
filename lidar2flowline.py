#!/home/tbarnhart/miniconda3/envs/py36/bin python

# Theodore Barnhart
# tbarnhart@usgs.gov
#
# Designed to work with GRASS 7.4 and Python 3.6
# Created: 7/13/2018
#
# Inputs:
# working directory [string]
# huc number [int]
# threshold in number of cells [int]
# output directory [string]
# gdalwarp [boolean]
#
# Outputs:
# Vector of flowlines in the 

from grass.pygrass.modules import Module
import sys
import subprocess
import os

tr = 2 # resolution
cutfl = '~/projects/gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb'
datfl = '~/projects/DEM_processing/data/huc10270203.vrt'
cutLayer = 'WBDHU12'
cutCol = 'HUC12'
proj = 'EPSG:26852'

# parse command line arguments
workingDir = sys.argv[1]
huc = sys.argv[2]
thresh = sys.argv[3]
outDir = sys.argv[4]
gdalwarp = sys.argv[5] # flag for if gdalwarp should be run

# define the functions to use.
r_external = Module("r.external") 
r_watershed = Module("r.watershed")
r_to_vect = Module("r.to.vect")
v_out_ogr = Module("v.out.ogr")

# build a parameter dictionary
params = {'tr':tr,
        'cutfl':cutfl,
        'cutLayer':cutLayer,
        'cutCol':cutCol,
        'proj':proj,
        'outfl':os.path.join(outdir,'huc_%s.shp'%{huc}),
        'infl':os.path.join(workingDir,'SStemp_%s'%{huc},'huc_%s.tiff'%{huc}),
        'tempDir':os.path.join(workingDir,'SStemp_%s'%{huc})}

# test if the temporary directory exists
try:
    assert os.path.isdir(params['tempDir']) == True
except:
    print('Temporary directory does not exist.\nExiting Program...')
    sys.exit(1) # not sure this is the best way to do this...

if gdalwarp: # assemble the gdalwarp command
    cmd = 'gdalwarp -dstnodata -99 -of GTiff -tr {tr} {tr} -overwrite -cutline {cutfl} -cl {cutLayer} -cwhere "{cutCol}=\'{huc}\'" -crop_to_cutline -t_srs \'{proj}\' $datfl {outfl}'

    print(subprocess.check_output(cmd)) # run the gdalwarp code to subset the mosaiced DEM

try:
    assert os.path.exists(params['infl']) == True
except:
    print('Input file does not exist.\nExiting Program...')
    sys.exit(1)

r_external(input=params['infl'],output='huc')
r_watershed(elevation='huc',threshold=thresh,stream='stream')
r_to_vect(input='stream',output='flowline',type='line',overwrite=True)
r_out_ogr(input='flowline',output=params['outfl'])