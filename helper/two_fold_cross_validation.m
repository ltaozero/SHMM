
function [sigma,lamda,avgrate]=...
two_fold_cross_validation(usedidx,trainidx,s,m,flagskill,data_filenames,trans_filenames, data_index,S,trr)

display('Perform 2-fold cross validation for Sigma and Lambda');
%%% usedidx is the index of the surgemes which are used in our experiment
trainidx1=trainidx(1:2:end);
trainidx2=trainidx(2:2:end);
[Dict1]=train_dict_base_new(usedidx,trainidx1,s,m,flagskill,S,trr);
[Dict2]=train_dict_base_new(usedidx,trainidx2,s,m,flagskill,S,trr);
%%% move to the parameter estimation function
sigma1=[0.1:0.3:1,2];
lamda1=[1e-2,2e-2,5e-2,1e-1,5e-1];
testidxall{1}=trainidx2;
testidxall{2}=trainidx1;

Dictall{1}=Dict1;
Dictall{2}=Dict2;
[indS,indL,avgrate,~]=...
    cross_validation(usedidx,testidxall,Dictall,s,data_filenames,trans_filenames,data_index,sigma1,lamda1);
sigma=sigma1(indL);
lamda=lamda1(indS);
end
