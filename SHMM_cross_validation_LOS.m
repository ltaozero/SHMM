% Example script for LOS cross validation
% INPUT:task_index, setup_index, dict_type, dict_size, sparsity/beta,
% slaveonly, rs,zeromean
 % globalDir = '/cis/home/ltao/lab/Data/California76/';
 globalDir = '/scratch/groups/rvidal1/Data/California76';
%  task_index = 1;
%  setup_index = 1;

% set different randome generator seed
rng('shuffle');

% add path to toolbox
addpath helper
%addpath /cis/home/ltao/lab/ksvd/ksvdbox13/
%addpath /cis/home/ltao/lab/ksvd/ompbox10/
%run('/cis/home/ltao/lab/matlab_toolbox/spams-matlab-v2.3/start_spams.m');
addpath /home-3/ltao4@jhu.edu/toolbox/ksvd
run('/home-3/ltao4@jhu.edu/toolbox/spams-matlab/start_spams.m')

% cross_validation parameters
taskset = {'Suturing', 'Knot_Tying','Needle_Passing'};
setupset = {'UserOut', 'SuperTrialOut'};
ntest_set = [8,5];
% Note: change the used surgeme in Needle passing from [1:6,8:11], to
% [1:6,8,11].
surgemes_set = { [1:6,8:11],[1,11:15],[1:6,8,11]};
setuptask = taskset{task_index};
setupname = setupset{setup_index};
ntests = ntest_set(setup_index);
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
    param.c=gamma3;
    param.d=gamma4;
    conf.param=param;
end
conf.skip = skip;
conf.dict_size = dict_size;
conf.dict_type = dict_type;
switch slaveonly
    case 1
        conf.data_index = [39:76];
    case 0
        conf.data_index = [1:76];
    case 2
        conf.data_index = [39:41,54:57,58:60,73:76];
    otherwise
        % by default use all data
        conf.data_index=[1:76];
end

% set conf parameters
% use normalized data
conf.rs = rs;
conf.datapath = [globalDir,'/data/' setuptask '/california76/AllGestures_norm/'];
conf.transpath = [globalDir,'/data/' setuptask '/transcriptions_final/'];
conf.usedidx = surgemes_set{task_index};
conf.cross_valid = 0;
conf.zeromean = zeromean;
if conf.cross_valid ==0
    conf.default_sigma = 2.0;
    conf.default_lambda = 0.01;
end

predicted_labels = cell(1, ntests); rate = cell(1,ntests);ratebasic = cell(1,ntests);
for test_number = 1 : ntests
            fprintf(['Test number ', num2str(test_number) '\n']);
            trainfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],['itr_1'],'Train.txt'));
            testfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],['itr_1'],'Test.txt'));
            
            model{test_number} = SHMM_train(trainfilename, conf);
            [predicted_labels{test_number}, rate{test_number}, ratebasic{test_number}] = SHMM_test(testfilename, conf, model{test_number});           
end

fprintf(conf.dict_type)
switch conf.dict_type
    case 'fix_beta_EM'
result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_beta%1.4f_mean%d_itr%d',conf.dict_type,slaveonly, conf.dict_size, conf.beta, conf.zeromean, conf.rs)));
    fprintf(result_filename);   
    case 'KSVD'
result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_s%d_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.sparsity,conf.zeromean, conf.rs)));
    fprintf(result_filename);   
    case 'Bayesian'
    result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_a%1.4f_b%1.4f_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.param.a, conf.param.b,conf.zeromean, conf.rs)));
    fprintf(result_filename);   
end

if conf.skip>1
  result_filename = sprintf('%s_skip%d',result_filename,conf.skip);
end
result_filename = result_filename+'.mat';
        
if (exist('result_filename', 'var'))
    fprintf(['save result to ', result_filename]);
    save(result_filename, 'predicted_labels','rate','ratebasic','model','conf');
else 
    fprintf('results not saved');
end
