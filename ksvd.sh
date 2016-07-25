#
#$ -cwd 
#$ -j y 
#$ -S /bin/bash 
#
MATLABPATH=/usr/local/bin
cd /cis/home/ltao/lab/SHMM_submitted_final/

matlab -nosplash -nodisplay -singleCompThread -r "task_index=$1;setup_index =$2; rs = $3; slaveonly = $4; sparsity = $5; dict_size = $6;  dict_type='KSVD'; SHMM_cross_validation_LOS"
