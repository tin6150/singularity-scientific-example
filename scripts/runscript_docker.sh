#!/bin/bash

# This is a very simple running script to execute a Docker container workflow.
# It will install Docker, builder an image, and use it to run a series of scripts. 
# It was developed to run on Ubuntu 16.04 LTS

# Setup and installation for system stuffs is done by run.sh, including setting of:

# WORKDIR to be /scratch/data
# RUNDIR to be $HOME/singularity-scientific-example/cloud
# TIME_LOG and TIME output to $RUNDIR/logs/stats.log

# Let's also make a logs directory to keep
export DOCKER_LOG=$RUNDIR/logs/docker.log

#########################################################################################
# Singularity Installation
#########################################################################################

# 1. Install Singularity and dependencies
# If user has sudo, we assume on cloud instance and install. If not,
# we must be on cluster with it.
timeout 2 sudo id && hassudo="true" || hassudo="no"
if [[ $hassudo == "true" ]]; then
   echo "User has sudo, running install/update of Docker"
   bash /code/scripts/install_docker.sh
fi


#########################################################################################
# Setup and Installation
#########################################################################################

# Build our docker image
cd $BASE
sudo docker build -t vanessa/analysis .
cd $RUNDIR

#########################################################################################
# Data download
#########################################################################################

# We already have data downloaded, we are going to do it again.
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/analysis bash /code/scripts/1.download_data.sh /scratch/data

#########################################################################################
# Analysis
#########################################################################################

/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/2.simulate_reads.sh /scratch/data
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/3.generate_transcriptome_index.sh /scratch/data
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/4.quantify_transcripts.sh /scratch/data $NUMCORES
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/5.bwa_index.sh /scratch/data
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/6.bwa_align.sh /scratch/data
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/7.prepare_rtg_run.sh /scratch/data
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/8.map_trio.sh /scratch/data $MEM $THREADS
/usr/bin/time -a -o $TIME_LOG docker run -v /scratch/data:/scratch/data vanessa/singularity-scientific-example bash /code/scripts/9.family_call_variants.sh /scratch/data $MEM $THREADS
