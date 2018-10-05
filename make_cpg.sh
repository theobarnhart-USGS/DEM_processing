#!/bin/bash
# $1 - region (int)
reg=$1
inpath='/home/tbarnhart/projects/DEM_processing/data/cpg_datasets' # path for source data files
echo Linking to External Data
r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_${reg}_fac.vrt out=accum --overwrite --quiet -o # link the NHDplus accumulation grid
r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_${reg}_fdr_grass.tiff out=dir --overwrite --quiet -o # link the NHDplus direction grid
g.region rast=dir res=30 # explicitely set region to imported drainage dir extent
r.mapcalc --overwrite "accum_fill = accum + 1" # add one to the flow accumulation grid to help w/ math down the line
echo Linking Complete
for inDat in `ls -1 ${inpath}/*.tiff`; do # iterate through the source data files in the CPG directory, all tiffs in directory...
    filename=$(basename -- "$inDat") # file without path
    echo Processing: $filename
    varName="${filename%.*}"
    outDat=${inpath}/output_cpg/${varName}_${reg}_cpg.tiff
    echo Saving to: $outDat
    r.external in=${inDat} out=param --overwrite --quiet -o # link the parameter grid
    r.mapcalc "param_fill = if(isnull(param),0,param)" --overwrite # fill nulls to zero before accumulating the parameter surface 
    r.accumulate dir=dir weight=param_fill accum=param_accum --overwrite --quiet # accumulate the parameter based on the flow direction grid
    r.mapcalc "param_cpg = float(param_accum) / float(accum_fill)" --overwrite # compute the actual CPG
    echo Saving to: $outDat
    r.out.gdal --quiet --overwrite in=param_cpg out=${outDat} format=GTiff createopt="TILED=YES,COMPRESS=LZW,NUM_THREADS=ALL_CPUS,SPARSE_OK=TRUE,PROFILE=GeoTIFF" # export the CPG
    echo Completed: $filename
done