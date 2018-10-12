#!/bin/bash
#SBATCH --job-name=aggNLDAS # name that you chose
#SBATCH -N 33            # number of cores needed
#SBATCH -p normal                         # the partition you want to use, for this case prod is best
#SBATCH --account=wymtwsc        # your account
#SBATCH --time=36:00:00           # Overestimated guess at time
#SBATCH --mail-type=ALL         # Send email on all events
#SBATCH --mail-user=tbarnhart@usgs.gov
#SBATCH  -o %j.log                    # Sets output log file to %j ( will be the jobId returned by sbatch)  
#SBATCH --mem=128000            #memory in MB 

source activate py36
module load gis/TauDEM-5.3.8-gcc-mpich

python -u ./make_cpg_tauDEM.py $1 $SLURM_JOB_ID $SLURM_NTASKS