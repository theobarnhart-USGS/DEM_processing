#!/usr/bin/env bash
# $1 - region

v.in.ascii -t in=/home/tbarnhart/projects/DEM_processing/data/CATCHMENT_region_${1}.csv out=gauges x=24 y=25 cat=26 sep=comma format=point skip=1 --overwrite --quiet # import ascii data

r.stream.snap in=gauges out=gauges_snap stream=str radius=20 mem=118000 --overwrite --quiet # snap all gauges to stream network

v.out.ogr in=gauges_snap type=point out=./data/cpg_datasets/

