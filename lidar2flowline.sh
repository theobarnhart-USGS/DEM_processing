#! /bin/bash

##########################################################################
# script to extract flowlines from LiDAR
#
# Script must be run via grass74 -c <inpath>/huc_<huc>.tiff ./ --exec lidar2flowline.sh <inpath> <huc> <thresh> <outdir>
#
# inputs:
# $1 <huc> - huc12 ID, can really be any hucID as long as it exists
# $2 <thresh> - cell threshold above which to create streams
# $3 <outdir> - output directory to print flowline
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
echo $1
echo $2
echo $3

r.external i=./SStemp_${1}/huc_${1}.tiff o=huc
r.watershed elev=huc str=str threshold=$2
r.to.vect type=line input=str output=flowline
v.out.ogr input=flowline output=${3}/huc_${1}.shp format=ESRI_Shapefile --overwrite