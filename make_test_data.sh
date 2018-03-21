gdalbuildvrt ./data/test_dem.vrt ../WYMT_SWE/data/dem/mt/n44_w112_3arc_v2_bil/n44_w112_3arc_v2.bil \
../WYMT_SWE/data/dem/mt/n44_w113_3arc_v2_bil/n44_w113_3arc_v2.bil \
../WYMT_SWE/data/dem/mt/n45_w112_3arc_v2_bil/n45_w112_3arc_v2.bil \
../WYMT_SWE/data/dem/mt/n45_w113_3arc_v2_bil/n45_w113_3arc_v2.bil \
../WYMT_SWE/data/dem/mt/n46_w112_3arc_v2_bil/n46_w112_3arc_v2.bil \
../WYMT_SWE/data/dem/mt/n46_w113_3arc_v2_bil/n46_w113_3arc_v2.bil

gdalwarp ./data/test_dem.vrt ./data/test_data.tiff
