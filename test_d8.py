import richdem as rd

fl = './data/NE/cedar2m/hdr.adf'
outfl = './data/cedar2m_d8_accum.tiff'
dem = rd.LoadGDAL(fl)
rd.FillDepressions(dem,in_place=True)
accum_d8 = rd.FlowAccumulation(dem,method='D8')
rd.SaveGDAL(outfl,accum_d8)
