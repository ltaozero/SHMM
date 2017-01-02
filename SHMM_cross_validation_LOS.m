% Example script for LOS cross validation
% INPUT:task_index, setup_index, dict_type, dict_size, sparsity/beta,
% slaveonly, rs,zeromean, skip
%globalDir = '/cis/home/ltao/lab/Data/California76/';
globalDir = '/scratch/groups/rvidal1/Data/';
conf.globalDir = globalDir;
%  task_index = 1;
%  setup_index = 1;

% set different randome generator seed
rng('shuffle');

% add path to toolbox
addpath helper
addpath /home-3/ltao4@jhu.edu/toolbox/ksvd
run('/home-3/ltao4@jhu.edu/toolbox/spams-matlab/start_spams.m')

% set model parameters
if exist('sparsity','var')
    conf.sparsity = sparsity;
end
if exist('beta','var')
    conf.beta = beta;
end

if exist('gamma1','var')
    param.prior='invgamma';
    param.a=gamma1;
    param.b=gamma2;
    param.c=gamma1;
    param.d=gamma2;
    conf.param=param;
end
conf.task_index = task_index;
conf.slaveonly = slaveonly;
conf.skip = skip;
conf.dict_size = dict_size;
conf.dict_type = dict_type;
conf.rs = rs;
conf.cross_valid = 1;
conf.zeromean = zeromean;
if conf.cross_valid ==0
    conf.default_sigma = 2.0;
    conf.default_lambda = 0.01;
end


% dataset parameters
conf.data_params = get_dataset_params(task_index, setup_index, conf);


% run experiments
ntests = conf.data_params.ntests;
predicted_labels = cell(1, ntests); rate = cell(1,ntests);ratebasic = cell(1,ntests);
for test_number = 1 : ntests
            fprintf(['Test number ', num2str(test_number) '\n']);
            trainfilename = sprintf(conf.data_params.trainfilename_str, test_number);
            testfilename = sprintf(conf.data_params.testfilename_str, test_number);
            model{test_number} = SHMM_train(trainfilename, conf,test_number);
            [predicted_labels{test_number}, rate{test_number}, ratebasic{test_number}] = SHMM_test(testfilename, conf, model{test_number},test_number);           
            
            cell2mat(rate)

end


% save data  
result_filename = conf.data_params.result_filename;    
if (exist('result_filename', 'var'))
    fprintf(['save result to ', result_filename]);
    save(result_filename, 'predicted_labels','rate','ratebasic','model','conf');
else 
    fprintf('results not saved');
end
