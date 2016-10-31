import subprocess
import sys

for task_index in [1]:#[1,2,3]:
    for setup_index in [1]:#[1,2]:
        for zeromean in [0]:
            for slaveonly in [0]:
                for beta in [0.1,0.5]:#[0.1,0.5,1,2,5,10]:
                    for dict_size in [200]:
                        for skip in [1]:#[1,10, 20,40,80,160,320]:
                            for rs in [1]:
                                sbatch_command="sbatch -o ~/logfiles/slurm-%j.out /home-3/ltao4@jhu.edu/Code/SHMM_submitted_final/scripts/fix_beta.sh {} {} {} {} {} {} {} {}".format(task_index, setup_index, rs, slaveonly,beta, dict_size,zeromean,skip)
                                print(sbatch_command)
                                exit_status = subprocess.call(sbatch_command, shell=True)
                                if exit_status is 1:  # Check to make sure the job submitted
                                    print "Job {0} failed to submit".format(qsub_command)
    print "Done submitting jobs!"
