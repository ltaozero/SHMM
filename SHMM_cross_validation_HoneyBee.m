% Example script for LOS cross validation
% INPUT: dict_type, dict_size, sparsity/beta, rs
globalDir = '/cis/home/ltao/lab/Data/HoneyBee/';

% set different randome generator seed
rng('shuffle');

% add path to toolbox
addpath helper
addpath /cis/home/ltao/lab/ksvd/ksvdbox13/
addpath /cis/home/ltao/lab/ksvd/ompbox10/
run('/cis/home/ltao/lab/matlab_toolbox/spams-matlab-v2.3/start_spams.m');s
ntests = 6;
if exist('sparsity','var')
    conf.sparsity = sparsity;
end
if exist('beta','var')
    conf.beta = beta;
end
conf.dict_size = dict_size;
conf.dict_type = dict_type;
conf.data_index=[1:30];

% set conf parameters
% use normalized data
conf.rs = rs;
conf.datapath = [globalDir,'/Data_5frame_norm4/'];
conf.transpath = [globalDir,'/Transcription/'];
conf.usedidx = 1:3;
conf.cross_valid = 0;
conf.zeromean = 1;
%conf.zeromeanidx = [];
if conf.cross_valid ==0
    conf.default_sigma = 2.0;
    conf.default_lambda = 0.01;
end

predicted_labels = cell(1, ntests); rate = cell(1,ntests);ratebasic = cell(1,ntests);
for test_number = 1 : ntests
            fprintf(['Test number ', num2str(test_number) '\n']);
            trainfilename=(fullfile(globalDir,'Experiments', ...
            [num2str(test_number),'_out'],'Train.txt'));
            testfilename=(fullfile(globalDir,'Experiments', ...
            [num2str(test_number),'_out'],'Test.txt'));
            
            model{test_number} = SHMM_train(trainfilename, conf);
            [predicted_labels{test_number}, rate{test_number}, ratebasic{test_number}] = SHMM_test(testfilename, conf, model{test_number});           
end

fprintf(conf.dict_type)
switch conf.dict_type
    case 'fix_beta_EM'
result_filename=(fullfile(globalDir,'Experiments',...
           sprintf('result_%s_dict%d_beta%1.4f_itr_%d.mat',conf.dict_type, conf.dict_size, conf.beta,  conf.rs)));
    fprintf(result_filename);   
    case 'KSVD'
result_filename=(fullfile(globalDir,'Experiments', ...
           sprintf('result_%s_dict%d_s%d_itr_%d.mat', conf.dict_type, conf.dict_size, conf.sparsity, conf.rs)));
    fprintf(result_filename);   
    case 'Bayesian'
    result_filename=(fullfile(globalDir,'Experiments', ...           
           sprintf('result_%s_dict%d_prior%s_itr_%d.mat', conf.dict_type, conf.dict_size, conf.param.prior, conf.rs)));
    fprintf(result_filename);   
end


        
if (exist('result_filename', 'var'))
    fprintf(['save result to ', result_filename]);
    %save(result_filename, 'predicted_labels','rate','ratebasic','model','conf');
else 
    fprintf('results not saved');
end
