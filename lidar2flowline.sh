#! /bin/bash

##########################################################################
# script to extract flowlines from LiDAR
#
# Script must be run via grass74 -c <inpath>/huc_<huc>.tiff ./ --exec lidar2flowline.sh <inpath> <huc> <thresh> <outdir>
#
# inputs:
# $1 <inpath> - input directory
# $2 <huc> - huc12 ID, can really be any hucID as long as it exists
# $3 <thresh> - cell threshold above which to create streams
# $4 <outdir> - output directory to print flowline
#
#
# outputs:
# flowline shapefile in <outdir>
#
# example: 
# grass74 -c ./data/huc_102702010305.tiff ../SStest/PERMANENT --exec sh ./lidar2flowline.sh ./data 102702010305 8000 ./data
#
# Theodore Barnhart
# tbarnhart@usgs.gov
#
##########################################################################

r.external i=${1}/huc_${2}.tiff o=huc
r.watershed elev=huc str=str threshold=$3
r.to.vect type=line input=str output=flowline
v.out.ogr input=flowline output=${4}/huc_${2}.shp format=ESRI_Shapefile --overwrite