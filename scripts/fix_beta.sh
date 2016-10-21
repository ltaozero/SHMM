#!/bin/bash

#SBATCH
#SBATCH --partition=shared
#SBATCH -t 3:00:00
#SBATCH --nodes=1
#SBATCh --mem=8g
#SBATCh --job-name=fixBeta

cd /home-3/ltao4@jhu.edu/Code/SHMM_submitted_final

matlab -nosplash -nodisplay -singleCompThread -r "task_index=$1;setup_index =$2; rs = $3; slaveonly = $4; beta=$5; dict_size = $6; zeromean=$7;skip=$8;dict_type='fix_beta_EM';SHMM_cross_validation_LOS"

