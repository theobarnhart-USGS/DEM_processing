#!/bin/bash
# Script to move files and then run the aggregation script
# Theodore Barnhart | tbarnhart@usgs.gov

#SBATCH --job-name=reproject # name that you chose
#SBATCH -n 1            # number of cores needed
#SBATCH -p normal                         # the partition you want to use, for this case prod is best
#SBATCH --account=wymtwsc        # your account
#SBATCH --time=3:00:00           # Overestimated time
#SBATCH --mail-type=ALL         # Send email on all events
#SBATCH --mail-user=tbarnhart@usgs.gov
#SBATCH  -o %j.log                    # Sets output log file to %j ( will be the jobId returned by sbatch)
#SBATCH --mem=20000

# $1 - resampling method
# $2 - infile
# $3 - outfile

source activate py36

ssrs="EPSG:42303"
gdalwarp -overwrite -tr 30 30 -t_src EPSG:42303 -co "SPARSE_OK=TRUE" -co "COMPRESS=LZW" -s_srs $ssrs -r $1 $2 $3