#!/bin/bash
# $1 - region (int)
reg=$1
inpath='/home/tbarnhart/projects/DEM_processing/data/cpg_datasets' # path for source data files
echo Linking to External Data

r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21/region_${reg}.vrt out=elev --overwrite --quiet -o # link to NHD hydroDEM
g.region rast=elev res=30 # explicitely set region to imported drainage dir extent
r.watershed -msa --overwrite --quiet elevation=elev accumulation=accum memory=115000 # generate accumulation from elevation
r.mapcalc --overwrite "accum_fill = accum + 1" # add one to the flow accumulation grid to help w/ math down the line
echo Linking Complete
for inDat in `ls -1 ${inpath}/*.tiff`; do # iterate through the source data files in the CPG directory, all tiffs in directory...
    filename=$(basename -- "$inDat") # file without path
    echo Processing: $filename
    varName="${filename%.*}"
    outDat=${inpath}/output_cpg/${varName}_${reg}_cpg.tiff
    
    # find the no data value as this doesn't transfer with r.external...
    tmp=`gdalinfo $inDat | grep 'NoData Value='` # search gdalinfo
    nd="$(cut -d "=" -f2 <<<$tmp)" # extract the no data value
    
    r.external in=${inDat} out=param --overwrite --quiet -o # link the parameter grid
    r.mapcalc "param_fill = if(param==${nd},0,param)" --overwrite # fill nulls with zero before accumulating the parameter surface

    r.watershed -msa --overwrite --quiet elevation=elev flow=param_fill accumulation=param_accum memory=115000 # accumulate the parameter
 
    r.mapcalc "param_cpg = float(param_accum) / float(accum_fill)" --overwrite # compute the actual CPG
    echo Saving to: $outDat
    r.out.gdal --quiet --overwrite in=param_cpg out=${outDat} format=GTiff createopt="TILED=YES,COMPRESS=LZW,NUM_THREADS=ALL_CPUS,SPARSE_OK=TRUE,PROFILE=GeoTIFF" # export the CPG
    echo Completed: $filename
done
