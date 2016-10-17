import subprocess
import sys

for task_index in [1,2,3]:
    for setup_index in [1,2]:
        for zeromean in [0,1]:
            for slaveonly in [2]:
                for b in [0.1,1,10]:
                    for a in [10*b,100*b,1000*b]:
                        for dict_size in [100,200]:
                            for rs in [1]:
                                sbatch_command="sbatch -o ~/logfiles/slurm-%j.out /home-3/ltao4@jhu.edu/Code/SHMM_submitted_final/scripts/bayesian.sh {} {} {} {} {} {} {} {}".format(task_index, setup_index, rs, slaveonly,a,b, dict_size,zeromean)
                                print(sbatch_command)
                                exit_status = subprocess.call(sbatch_command, shell=True)
                                if exit_status is 1:  # Check to make sure the job submitted
                                    print "Job {0} failed to submit".format(qsub_command)
print "Done submitting jobs!"
