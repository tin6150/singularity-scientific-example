#!/bin/bash
#SBATCH -p euan,owners
#SBATCH -n 16
#SBATCH --mem 48G
#SBATCH -t 2-00:00:00
#SBATCH --export ALL
#SBATCH --nodes 1
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user cjprybol@stanford.edu
#SBATCH -o slurm-6.bwa_align.host.out
bash 6.bwa_align.sh 16 host
