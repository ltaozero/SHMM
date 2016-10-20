function [predicted_labels, rate, ratebasic] = SHMM_test(testfilename, conf, model, result_filename)
% ********************************************************
% Input:
%
% testfilename: the file which contains the name of testing trials.
%
% conf: configure parameters. conf is a struct with following fields.
%
% conf.datapath: the path to the folder that saves kinematic data
%
% conf.transpath: the path to the folder that saves the transcriptions
%
% conf.usedidx: interested gesture indices
%
% conf.data_index: specified the index of the part of the data used in the
%                  experment
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
% result_filename: if it's not empty, the result will be saved as
% 'result_filename'
%
% Output:
% predicted_labels: a cell array which contains the predicted labels
%
% rate: the prediction accuracy of each testing trial
%
% *********************************************************

fprintf('Test Start');
%read training setup file
if (~exist(testfilename,'file'))
    error('TestFile does not exist!');
end

data_filenames = [];
trans_filenames = [];
fid = fopen(testfilename);
tline = fgetl(fid);
while ischar(tline)
    b = strread(tline,'%s');
    data_filenames = [data_filenames,{fullfile(conf.datapath, [b{2}])}];
    trans_filenames = [trans_filenames,{fullfile(conf.transpath, [b{2}])}];
    tline = fgetl(fid);
end
fclose(fid);

% Load transcriptions
ntrial = length(trans_filenames);
if (length(trans_filenames)~=ntrial)
    error('Number of data files does not equal number of transcription files');
end
Trans = cell(1,ntrial);
for i = 1 : ntrial
    [~, Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, conf.data_index);
end

switch model.dict_type
    case 'KSVD'
        % predict labels of test data
        [~,prall,ratebasic,~,~]=...
            hmm_data_l1_log(conf.usedidx,model,data_filenames,...
            trans_filenames,conf.data_index);
    case 'fix_beta_EM'
        [~,prall,ratebasic,~,~]=...
            hmm_data_l1_real_log(conf.usedidx,model,data_filenames,...
            trans_filenames,conf.data_index);
    case 'Bayesian'
        [prall,ratebasic,~,~]=...
            hmm_data_bayesian(conf.usedidx,model,data_filenames,...
            trans_filenames,conf.data_index);
end


% Viterbi decoding
rate = zeros(1,length(trans_filenames));
predicted_labels = cell(1,length(trans_filenames));

for i=1:length(trans_filenames)
    trans=Trans{i};
    temp=prall{i};
    
    temp=temp(:,sum(temp)~=0);
    
    %temp(temp==0)=min(min(temp(temp~=0)));
    
    [path] = skip_viterbi(model.prior, model.transp, temp, conf.skip);
    
    path2=zeros(size(trans));
    path2(sum(temp)~=0)=path;
    path2(sum(temp)==0)=1;
    predicted_labels{i}=conf.usedidx(path2);
    select_idx = find(ismember(trans,conf.usedidx));
    rate(i)=sum(conf.usedidx(path2(select_idx))==trans(select_idx))./length(select_idx);
end

% if (exist(result_filename, 'var'))
%     save(result_filename, 'predicted_labels','rate','ratebasic','model','conf');
% end

fprintf('Test End');
end


