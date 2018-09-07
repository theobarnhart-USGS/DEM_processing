#!/usr/bin/env python2
# script to extract watershed areas from gauges snapped to NHDplusV2.1
# Theodore Barnhart | August 22, 2018 | tbarnhart@usgs.gov
from __future__ import print_function #python 2/3
from grass.pygrass.modules import Module
import sys
import subprocess
import os
import pandas as pd
from pyproj import Proj, transform
import numpy as np


reg = sys.argv[1] # extract coommand line argument 1, region to process
#reg = '16'

workspace = '/home/tbarnhart/projects/DEM_processing/data'
drainDirPath = os.path.join('./data','NHDplusV21_facfdr','region_%s_fdr_grass.tiff'%(reg))

fl = './data/CATCHMENT_v1.csv' # need to change this
gauges = pd.read_csv(fl)

gauges.loc[gauges.Lat_snap == -9999,'Lat_snap'] = np.NaN # handle no data values
gauges.loc[gauges.Long_snap == -9999,'Long_snap'] = np.NaN

def fixRegion(df):
    '''Fix region 3, which is divided in the original data set for some reason.'''
    reg = df.NHDPlusReg # get region
    
    if reg[:2] == '03':
        reg = '03'
        
    return reg

gauges['NHDPlusReg'] = gauges.apply(fixRegion,axis=1) # fix region 3

gauges = gauges.loc[gauges.NHDPlusReg == reg] # subset the gauge list

# create list of gauge locations

# infill the missing snapped locations with NWIS locations, no longer needed after talk w/ Kathy Chase.
#gauges.loc[np.isnan(gauges.Lat_snap) == 1,'Lat_snap'] = gauges.loc[np.isnan(gauges.Lat_snap) == 1].Lat_nwis
#gauges.loc[np.isnan(gauges.Long_snap) == 1,'Long_snap'] = gauges.loc[np.isnan(gauges.Long_snap) == 1].Long_nwis

gauges.dropna(inplace=True) # just drop the rows containing NA values

lons = gauges.Long_snap.values
lats = gauges.Lat_snap.values
gaugeID = gauges.Gage_no.values

inProj = '+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs' # projection of points pulled from shapefile
#outProj = '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs' # pulled from FDR

# define projections
inProj = Proj(inProj,preserve_units=True)
#outProj = Proj(outProj)
outProj = Proj('+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs', preserve_units=True)

# reporject the gauges
xs = []
ys = []

for lon,lat in zip(lons,lats):
    x,y = transform(inProj,outProj,lon,lat)
    xs.append(x)
    ys.append(y)

# now for the GRASS code

# define functions to use
r_external = Module('r.external')
r_water_outlet = Module('r.water.outlet')
r_to_vect = Module('r.to.vect')
v_out_ogr = Module('v.out.ogr')
g_region = Module('g.region') # command to set processing region extent and resolution
v_db_addcol = Module('v.db.addcolumn')
v_to_db = Module('v.to.db')

r_external(input=drainDirPath,output='dir', o = True, overwrite = True) # bring in the drainage direction raster
g_region(raster = 'dir', res = 30) # set region resolution and extent

for ID,x,y in zip(gaugeID,xs,ys):
    print('Starting Gauge No. %s in Region %s.'%(ID,reg))
    outfl = os.path.join(workspace,'gauges','region_%s_gageNo_%s_watershed_NHDplusV2_1.shp'%(reg,ID)) # format output string

    if os.path.isfile(outfl):
        print('Gauge No. %s in Region %s already complete.'%(ID,reg))
        continue

    else:
        r_water_outlet(input = 'dir', output = 'watershed', coordinates =(x,y), overwrite=True) # delineate watershed
        r_to_vect(input = 'watershed', output = 'boundary', type = 'area', overwrite=True) # convert raster to vector

        # compute area of watershed
        v_db_addcol(map='boundary', columns='area_sqkm double precision')
        v_to_db(map='boundary', option='area', columns='area_sqkm', units='kilometers')

        v_out_ogr(e = True, input = 'boundary', type = 'area', output = outfl, overwrite=True, format = 'ESRI_Shapefile') # export the watershed boundary to a temporary file
        # define projection later...
        #cmd = 'ogr2ogr -a_srs \'+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs\' %s ./data/gauges/tmp_reg%s.shp'%(outfl,reg) #ogr command to define projection
        #subprocess.call(cmd,shell=True)

        print('Gauge No. %s in Region %s complete.'%(ID,reg))
