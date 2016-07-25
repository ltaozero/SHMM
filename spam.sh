# 
#$ -cwd 
#$ -j y 
#$ -pe orte 24
#$ -S /bin/bash 
#

pwd
cd /cis/home/ltao/lab/matlab_toolbox/spams-matlab-v2.3/
pwd
MATLABPATH=/usr/local/bin
$MATLABPATH/matlab.r2013a -nosplash -nodisplay -singleCompThread -r "compile"
