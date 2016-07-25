function model = SHMM_train(trainfilename, conf)
% ********************************************************
% Input:
%
% trainfilename: the file which contains the name of training trials.
%
% conf: configure parameters. conf is a struct with following fields.
%
% conf.datapath: the path to the folder that saves kinematic data
%
% conf.transpath: the path to the folder that saves the transcriptions
%
% conf.usedidx: interested gesture indices
%
% conf.sparsity: sparsity level of the dictionary in KSVD
%
% conf.dict_size: size of dictionary learned via KSVD
%
% conf.cross_valid: is cross_valid is 1, perform cross validation to find
%                   sigma and lambda. Otherwise, set to default values
%                   specified by conf.defaul_sigma and conf.default_lambda
%
% conf.data_index: specified the index of the part of the data used in the
%                  experment
%
% conf.default_lambda: if conf.cross_valid = 0, it's used to
%                      set lambda for all classes
%
% conf.default_sigma: if conf.cross_valid = 0, it's used to
%                     set sigma for all classes
%
% Output:
%
% model: the learned model. Model is a struct with following fields.
%
% model.Dict: a cell array of matrices learned for SHMM using KSVD
%
% model.Sigma: the sigma used across all classes
%
% model.Lambda: the lambda used across all classes
%
% model.transp: the learned transition matrix
%
% model.prior: the learned prior
%
% *********************************************************

fprintf('Training Start');
%read training setup file
if (~exist(trainfilename,'file'))
    error('TrainFile does not exist!');
end

data_filenames = [];
trans_filenames = [];
fid = fopen(trainfilename);
tline = fgetl(fid);
while ischar(tline)
    b = strread(tline,'%s');
    data_filenames = [data_filenames,{fullfile(conf.datapath, [b{2}])}];
    trans_filenames = [trans_filenames,{fullfile(conf.transpath, [b{2}])}];
    tline = fgetl(fid);
end
fclose(fid);

%generate surgeme data
[S,trr]=generate_surgemedata(data_filenames,trans_filenames,conf.usedidx, conf.data_index, ones(1,length(trans_filenames)));

switch conf.dict_type
    case 'KSVD'
        %%%%%%%%%%%%% train dictionary using KSVD
        model = train_dict_base_new(conf.usedidx,[1:length(data_filenames)],conf.sparsity,conf.dict_size,0,S,trr,conf.zeromean);
        model.sparsity = conf.sparsity;
        % Get Sigma and Lambda
        % cross-validation to find good Sigma and Lambda
        if conf.cross_valid==0
            Sigma = conf.default_sigma;
            Lambda = conf.default_lambda;
        else
            display('Start performing cross validation to get best lambda and sigma');
            [Sigma,Lambda,~]=two_fold_cross_validation(conf.usedidx,[1:length(data_filenames)], ...
                conf.sparsity,conf.dict_size,0,data_filenames,trans_filenames,conf.data_index,S,trr);
            fprintf('cross validation finished, sigma is %f, lambda is %f', Sigma, Lambda);
        end
        model.Sigma = Sigma;
        model.Lambda = Lambda;
    case 'fix_beta_EM'
        model=train_dict_base_fix_beta(conf.usedidx,[1:length(data_filenames)],conf.beta,conf.dict_size,0,S,trr,1,conf.zeromean);
    case 'Bayesian'
        model = train_dict_base_bayesian(conf.usedidx,[1:length(data_filenames)],conf.dict_size,0,S,trr,conf.zeromean,conf.param);
end


[prior,transp]=hmmtraining_trans(conf.usedidx,[1:length(data_filenames)],trans_filenames);

%model.Dict = Dict;
model.prior = prior;
model.transp = transp;
%model.Sigma = Sigma;
%model.Lambda = Lambda;
%model.Mu = Mu;
model.dict_type = conf.dict_type;

fprintf('Training End');
end

