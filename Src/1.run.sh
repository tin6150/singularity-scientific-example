#!/bin/bash
#SBATCH -p euan,owners
#SBATCH -n 1
#SBATCH --mem-per-cpu=8G
#SBATCH -t 2-00:00:00
#SBATCH --export=ALL
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=cjprybol@stanford.edu
singularity exec singularity-manuscript.img bash 1.download_data.sh
