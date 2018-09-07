# $1 - parameter dataset to be cpg-afied (path)
# $2 - region (int)
# $3 - outfile (path)

r.external in=$1 out=param --overwrite --quiet -o # link the parameter grid
r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_$2_fac.vrt out=accum --overwrite --quiet -o # link the NHDplus accumulation grid
r.external in=/home/tbarnhart/projects/DEM_processing/data/NHDplusV21_facfdr/region_$2_fdr_grass.tiff out=dir --overwrite --quiet -o
r.mapcalc "accum_fill = accum + 1" # add one to the flow accumulation grid to help w/ math down the line
r.mapcalc "param_fill = if(isnull(param),0,param)" # fill nulls to zero before accumulating the parameter surface 
r.accumulate dir=dir weight=param_fill accum=param_accum --overwrite
r.mapcalc "param_cpg = float(param_accum) / float(accum_fill)" --overwrite
r.out.gdal in=param_cpg out=$3 format=GTiff createopt="TILED=YES,COMPRESS=LZW,NUM_THREADS=ALL_CPUS,SPARSE_OK=TRUE,PROFILE=GeoTIFF"