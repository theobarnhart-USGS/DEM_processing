#!/bin/bash
# $1 - region (int)

r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_$2_fac.vrt out=accum --overwrite --quiet -o # link the NHDplus accumulation grid
r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_$2_fdr_grass.tiff out=dir --overwrite --quiet -o # link the NHDplus direction grid
r.mapcalc "accum_fill = accum + 1" # add one to the flow accumulation grid to help w/ math down the line

inpath='/home/tbarnhart/projects/DEM_processing/data/cpg_datasets/' # path for source data files

for inDat in `ls -1 ${inpath}*.tiff`; do # iterate through the source data files in the CPG directory, all tiffs in directory...
    filename=$(basename -- "$inDat") # file without path
    echo Processing: $filename
    varName="${filename%.*}"
    outDat=${inPath}$varName_${reg}_cpg.tiff

    r.external in=${inDat} out=param --overwrite --quiet -o # link the parameter grid
    r.mapcalc "param_fill = if(isnull(param),0,param)" # fill nulls to zero before accumulating the parameter surface 
    r.accumulate dir=dir weight=param_fill accum=param_accum --overwrite # accumulate the parameter based on the flow direction grid
    r.mapcalc "param_cpg = float(param_accum) / float(accum_fill)" --overwrite # compute the actual CPG
    r.out.gdal in=param_cpg out=${outDat} format=GTiff createopt="TILED=YES,COMPRESS=LZW,NUM_THREADS=ALL_CPUS,SPARSE_OK=TRUE,PROFILE=GeoTIFF" # export the CPG
    echo Completed: $filename
done