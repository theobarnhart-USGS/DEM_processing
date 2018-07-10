# nebraska lcc m
#tr=2

#gdalwarp -tr $tr $tr -overwrite -cutline ../../gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb -cl WBDHU12 -cwhere "HUC12='102702030603'" -crop_to_cutline -t_srs "+proj=lcc +lat_1=43 +lat_2=40 +lat_0=39.83333333333334 +lon_0=-100 +x_0=500000 +y_0=0 +ellps=GRS80 +units=m +no_defs" huc10270203.vrt walnut_creek.tiff

#gdalwarp -tr $tr $tr -overwrite -cutline ../../gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb -cl WBDHU12 -cwhere "HUC12='102702030407'" -crop_to_cutline -t_srs "+proj=lcc +lat_1=43 +lat_2=40 +lat_0=39.83333333333334 +lon_0=-100 +x_0=500000 +y_0=0 +ellps=GRS80 +units=m +no_defs" huc10270203.vrt DR_Beaver_Creek.tiff

#gdalwarp -tr $tr $tr -overwrite -cutline ../../gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb -cl WBDHU12 -cwhere "HUC12='102702030407'" -crop_to_cutline -t_srs "+proj=lcc +lat_1=43 +lat_2=40 +lat_0=39.83333333333334 +lon_0=-100 +x_0=500000 +y_0=0 +ellps=GRS80 +units=m +no_defs" huc10270203.vrt CoY_Beaver_Creek.tiff

# for topol dev testing
tr=6.56168
proj="EPSG:26852"

gdalwarp -dstnodata -99 -of GTiff -tr $tr $tr -overwrite -cutline ../../gis_data/NHD_state/NHD_H_Nebraska_GDB/NHD_H_Nebraska_GDB.gdb -cl WBDHU12 -cwhere "HUC12='$1'" -crop_to_cutline -t_srs $proj huc10270203.vrt huc_$1.tiff
