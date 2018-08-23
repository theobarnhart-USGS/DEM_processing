source activate py27 # load correct python environment
module load gis/grass-7.4-spack # load GRASS

mkdir ./SStemp/reg${1} # create scratch environment
mkdir ./SStemp/reg${1}/PERMANENT # make for GRASS

grass74 -c ./data/NHDplusV21_facfdr/region_${1}_fdr_grass.tiff ./SStemp/reg${1} --exec python2 ./extract_watersheds.py ${1}

rm -r ./SStemp/reg${1}