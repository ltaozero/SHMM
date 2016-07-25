function model = MFA_train(trainfilename, conf)
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
% conf.num_sub: number of latent subspaces
%
% conf.latent_dim: dimension of latent subspace
%
% conf.data_index: specified the index of the part of the data used in the
%                  experment
%
% 
% Output: 
%
% model: the learned model. Model is a struct with following fields.
%
% model.Dict: a cell array of matrices learned using MFA
%
% model.transp: the learned transition matrix
%
% model.prior: the learned prior
%
% *********************************************************

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
%%%%%%%%%%%%% train dictionary using KSVD
Dict=train_dict_base_mppca(conf.usedidx,[1:length(data_filenames)],conf.num_sub,conf.latent_dim,0,0,S,trr);


[prior,transp]=hmmtraining_trans(conf.usedidx,[1:length(data_filenames)],trans_filenames);
prior(prior==0)=1e-200;
transp(transp==0)=1e-200;
model.Dict = Dict;
model.prior = prior;
model.transp = transp;
end

