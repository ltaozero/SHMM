#!/bin/bash

#SBATCH
#SBATCH --qos=scavenger
#SBATCH --partition=scavenger
#SBATCH -t 4:00:00
#SBATCH --nodes=1
#SBATCh --mem=8g
#SBATCh --job-name=bayesian

cd /home-3/ltao4@jhu.edu/Code/SHMM_submitted_final

matlab -nosplash -nodisplay -singleCompThread -r "task_index=$1;setup_index =$2; rs = $3; slaveonly = $4; gamma1=$5; gamma2 =$6; dict_size = $7; zeromean=$8;dict_type='Bayesian';SHMM_cross_validation_LOS"

