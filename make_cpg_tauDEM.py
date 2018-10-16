import numpy as np
import pandas as pd
import gdal
import subprocess
import sys
import glob
import rasterio as rs
import os
import shutil

reg = sys.argv[1] # pull the region
jobID = sys.argv[2] # pull the slurm job ID
cores = int(sys.argv[3]) - 1 # pull the number of cores available

fdrPath = './data/NHDplusV21_facfdr/region_%s_fdr_tau.tiff'%(reg) # path to the flow direction raster
facPath = './data/NHDplusV21_facfdr/region_%s_fac.vrt'%(reg)
tempDir = './data/temps/%s'%(jobID)
outDir = './data/cpg_datasets/output_cpgs'

def make_cpg(param,dataPath,noDataPath,tempDir=tempDir,facPath=facPath,outDir = outDir, reg = reg):
    '''
    Inputs:
        param - parameter name that output filenames are based off of
        dataPath - path to the accumulated parameter data raster
        noDataPath - path to the accumulated no data raster
        tempDir - temperary direcotyr, Default: tempDir variable defined above
        facPath - flow accumulation grid path, Default: facPath variable defined above
        outDir - output directory, Default: outDir variable defined above
        reg - region, Default: reg variable defined above 

    Outputs:
        Parameter and NoData CPGS as bands 1 and 2 of a file in the output directory.
    '''
    CPGpath = os.path.join(outDir,param+'_%s_cpg.tiff'%(reg))

    with rs.open(dataPath) as ds: # load data raster and find no data value
        data = ds.read(1)
        profile = ds.profile

    with rs.open(noDataPath) as ds:
        noData = ds.read(1)

    with rs.open(facPath) as ds:
        accum = ds.read(1)

    dataCPG = data / ((accum + 1.) - noData) # make data CPG
    noDataCPG = noData / (accum + 1.) # make noData CPG

    dataCPG.dtype = np.float32
    noDataCPG.dtype = np.float32

    profile.update({'dtype':dataCPG.dtype,
                'compress':'LZW',
                'profile':'GeoTIFF',
                'tiled':True,
                'sparse_ok':True,
                'num_threads':'ALL_CPUS',
                'nodata':-9999,
                'count':2})

    with rs.open(CPGpath, 'w', **profile) as dst:
        dst.write(dataCPG,1)
        dst.write(noDataCPG,2)

    return None

# create temp directory
os.mkdir(tempDir)

params = pd.DataFrame()
params['path'] = glob.glob('./data/cpg_datasets/filled_data/*.tiff') #list the zero-filled datasets

def get_param_name(path):
    return path.split('_noDat')[-2].split('/')[-1]

params['name'] = params.path.map(get_param_name) # extract parameter names

# get regional raster extent
xmins = []
xmaxs = []
ymins = []
ymaxs = []

for rast in [fdrPath,facPath]: # extract min and max raster bounds
    with rs.open(rast) as ds:
        xmins.append(ds.bounds[0])
        xmaxs.append(ds.bounds[2])
        ymins.append(ds.bounds[1])
        ymaxs.append(ds.bounds[3])

# summarize the extents to the largest possible
xmin = np.min(xmins)
xmax = np.max(xmaxs)
ymin = np.min(ymins)
ymax = np.max(ymaxs)

# test that raster extents are equal
for rast in [fdrPath,facPath]:
    with rs.open(rast) as ds:
        assert xmin == ds.bounds[0], "Regional Extents Not Equal"
        assert xmax == ds.bounds[2], "Regional Extents Not Equal"
        assert ymin == ds.bounds[1], "Regional Extents Not Equal"
        assert ymax == ds.bounds[3], "Regional Extents Not Equal"

cropParams = {
    'xmin':xmin,
    'xmax':xmax,
    'ymin':ymin,
    'ymax':ymax,
    't_srs':'EPSG:42303'
}

outPaths = []
for param,path in zip(params.name,params.path): # crop input datasets to common extents
    try:
        # update input and output files:
        cropParams['inFl'] = path
        cropParams['outFl'] = os.path.join(tempDir,param+'_zeroFill.tiff') # create temp output file

        print('Cropping %s to temporary directory.'%(param))
        cmd = 'gdalwarp -wo NUM_THREADS=ALL_CPUS -multi -tr 30 30 -te {xmin} {ymin} {xmax} {ymax} {inFl} {outFl}'.format(**cropParams)
        subprocess.call(cmd, shell = True)
        outPaths.append(cropParams['outFl']) # save the output path
    except:
        print('Error cropping %.'%(param))
        outPaths.append(None)

params['dataPath'] = outPaths # update output paths into the dataframe

outPaths = []
for param,path in zip(params.name,params.dataPath): # fill each temp file with ones
    try:
        print('Generating NoData binary raster for %s'%(param))
        outFl = os.path.join(tempDir,param+'_noData.tiff')
        with rs.open(path) as ds: # read data
            dat = ds.read(1)
            profile = ds.profile
            noData = ds.nodata

        dat[dat!=noData] = 0 # make data values zero
        dat[dat==noData] = 1 # make noData values 1 to be accumulated later
        dat.dtype = np.uint8 # byte data type
        
        # update geoTiff profile
        profile.update({'dtype':dat.dtype,
                'compress':'LZW',
                'profile':'GeoTIFF',
                'tiled':True,
                'sparse_ok':True,
                'num_threads':'ALL_CPUS',
                'nodata':255})

        with rs.open(outFl, 'w', **profile) as dst:
            dst.write(dat,1)

        outPaths.append(outFl)
    except:
        print('Error in binary raster creation.')
        outPaths.append(None)

params['noDataPath'] = outPaths # save noData binary raster paths to dataframe.

# TauDEM code
tauParams = {
    'fdr':fdrPath,
    'cores':cores
}

# TauDEM accumulation
outPathsData = []
outPathsNoData = []
for param,dataPath,noDataPath in zip(params.name, params.dataPath, params.noDataPath): 
    # first accumulate the parameter
    #try:
    print('Accumulating Data %s'%param)
    tauParams['outFl'] = os.path.join(tempDir,param+'_fill_accum.tiff')
    tauParams['weight'] = dataPath
    
    cmd = 'mpiexec -n {cores} aread8 -p {fdr} -ad8 {outFl} -wg {weight}'.format(**tauParams)
    subprocess.call(cmd, shell = True)
    outPathsData.append(tauParams['outFl']) # save accumualted data path
    #except:
    #    print('Error Accumulating Data')
    #    outPathsData.append(None)

    # now accumulate the no data values
    #try:
    print('Accumulating NoData %s'%param)
    # then accumualte the noData binary grid
    tauParams['outFl'] = os.path.join(tempDir,param+'_noData_accum.tiff')
    tauParams['weight'] = noDataPath

    cmd = 'mpiexec -n {cores} aread8 -p {fdr} -ad8 {outFl} -wg {weight}'.format(**tauParams)
    print(cmd)
    subprocess.call(cmd, shell = True)
    outPathsNoData.append(tauParams['outFl']) # save accumulated no data path
    #except:
    #    print('Error Accumulating NoData')
    #    outPathsNoData.append(None)

# save the output paths
params['accumData'] = outPathsData
params['accumNoData'] = outPathsNoData

for param,dataPath,noDataPath in zip(params.name, params.accumData, params.accumNoData):
    #try:
    print('Computing CPGS for %s'%(param))
    make_cpg(param,dataPath,noDataPath)
    #except:
    #    print('Error Computing CPGS for %s'%(param))

# delete the temp dir
#shutil.rmtree(tempDir)