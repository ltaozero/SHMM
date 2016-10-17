#!/bin/bash

for i in {1..3}
do
for j in {1..2}
      do
        #for z in {6..10}
         # do
            #for p in {0..1}
             # do
             z=11
             p=1
            qsub -o "/cis/home/ltao/logFiles/log_KSVD${i}_${j}_${z}_${p}.txt" -N "KSVD${i}_${j}_${z}_${p}" ksvd.sh $i $j $z $p 3 200
        
             # done
          #  done
    done
done
  
