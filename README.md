This toolbox provide an implementation of SHMM proposed in [1]. For comparison, the code for Mixture of Factor Analysis (MFA) is also provided.

Please see the example script SHMM_cross_validation_LOS.m for example usage. This script performs the benchmark setup cross validation on
the JIGSAW dataset. To run the script, please download the JIGSAW dataset (together with experiment setups) and set the globalDir to the directory 
of the dataset.

Please note that the function SHMM_train and SHMM_test assumes both transcription files and feature files has the same filename format.

Lingling Tao, Johns Hopkins University. 2015-01
