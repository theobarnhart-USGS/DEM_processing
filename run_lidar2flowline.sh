# script to run the lidar2flowline script in GRASS
# 
# Theodore Barnhart
# tbarnhart@usgs.gov
#
# inputs:
#
# $1 - set working directory
# $2 - huc
# $3 - threshold in number of cells
# $4 - output directory
tr=6.56168
proj="EPSG:26852"
cutfl=~/projects/gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb
datfl=~/projects/DEM_processing/data/huc10270203.vrt

oldDir=`pwd`

echo $1
echo $2
echo $3
echo $4

cd $1
mkdir ./SStmp_${2}

gdalwarp -dstnodata -99 -of GTiff -tr $tr $tr -overwrite -cutline $cutfl -cl WBDHU12 -cwhere "HUC12='$2'" -crop_to_cutline -t_srs $proj $datfl ./SStmp_${2}/huc_${2}.tiff # crop out the selected huc

grass74 -c ./SStmp_${2}/huc_${2}.tiff ./SStmp_${2}/PERMANENT --exec sh ${oldDir}/lidar2flowline.sh ${2} ${3} ${4}

rm -r SStmp_${2}