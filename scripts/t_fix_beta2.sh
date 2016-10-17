#!/bin/bash

for i in {1..3}
do
for j in {1..2}
      do
        #for z in {1..5}
        #  do
       #     for p in {0..1}
        #      do
          z=1
           p=1      
          qsub -o "/cis/home/ltao/logFiles/log_SHMM${i}_${j}_${z}_${p}.txt" -N "SHMM${i}_${j}_${z}_${p}" fix_beta.sh $i $j $z $p 0.1 500
        
         #     done
         #   done
    done
done
  
