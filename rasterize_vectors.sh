gdal_rasterize -te -2493045.000 177285.000 2342655.000 3310005.000 -tr 30 30 -ot GTiff -co "PROFILE=GeoTIFF" -co "TILED=YES" -co "SPARSE_OK=TRUE" -co "COMPRESS=LZW" -co "NUM_THREADS=ALL_CPUS" -init 0.0 -add -a NID_STORAG -l points nid09ad_jun11.gdb nid_storage.tiff

gdal_rasterize -te -2493045.000 177285.000 2342655.000 3310005.000 -tr 30 30 -ot GTiff -co "PROFILE=GeoTIFF" -co "TILED=YES" -co "SPARSE_OK=TRUE" -co "COMPRESS=LZW" -co "NUM_THREADS=ALL_CPUS" -init 0.0 -add -a NORM_STORAG -l points nid09ad_jun11.gdb nid_normstor.tiff

gdal_rasterize -te -2493045.000 177285.000 2342655.000 3310005.000 -tr 30 30 -ot GTiff -co "PROFILE=GeoTIFF" -co "TILED=YES" -co "SPARSE_OK=TRUE" -co "COMPRESS=LZW" -co "NUM_THREADS=ALL_CPUS" -init 0.0 -add -a F_SCALE -l points us_major_npd.gdb npd_occur.tiff