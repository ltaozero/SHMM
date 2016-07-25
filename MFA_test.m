function [predicted_labels, rate] = MFA_test(testfilename, conf, model, result_filename)
% ********************************************************
% Input:
%
% testfilename: the file which contains the name of testing trials. 
%
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
% model: the learned model. Model is a struct with following fields.
%
% model.Dict: a cell array of matrices learned using MFA
%
% model.transp: the learned transition matrix
%
% model.prior: the learned prior
%
% result_filename: if it's not empty, the result will be saved as
% 'result_filename'
%
% Output:
% predicted_labels: a cell array which contrains the predicted labels
%
% rate: the prediction accuracy of each testing trial
%
% *********************************************************

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




% predict labels of test data

[prall,ratebasic,labelbasic,pathbasic]=...
          hmm_data_mppca(conf.usedidx,model.Dict,data_filenames,trans_filenames, conf.data_index);
    
rate = zeros(1,length(trans_filenames));
predicted_labels = cell(1,length(trans_filenames));
for i=1:length(trans_filenames)
    trans=Trans{i};
    temp=prall{i};
    
    temp=temp(:,sum(temp)~=0);
    
    temp(temp==0)=min(min(temp(temp~=0)));
    
    [path] = viterbi_path(model.prior, model.transp, temp);
    
    path2=zeros(size(trans));
    path2(sum(temp)~=0)=path;
    path2(sum(temp)==0)=1;
    predicted_labels{i}=conf.usedidx(path2);
    rate(i)=sum(conf.usedidx(path2)==trans)./length(path2);
end

if (~isempty(result_filename))
    save(result_filename, 'predicted_labels','rate');
end

end


