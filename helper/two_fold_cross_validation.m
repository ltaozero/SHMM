
function [sigma,lamda,avgrate]=...
two_fold_cross_validation(usedidx,trainidx,s,m,flagskill,data_filenames,trans_filenames, data_index,S,trr,skip,zeromean)

display('Perform 2-fold cross validation for Sigma and Lambda');
%%% usedidx is the index of the surgemes which are used in our experiment
trainidx1=trainidx(1:2:end);
trainidx2=trainidx(2:2:end);
[model1]=train_dict_base_new(usedidx,trainidx1,s,m,flagskill,S,trr,zeromean);
[model2]=train_dict_base_new(usedidx,trainidx2,s,m,flagskill,S,trr,zeromean);
%%% move to the parameter estimation function
sigma1=[1e-3,1e-2,1e-1,1,10];
lamda1=[1e-2,1e-1,1,10,20];
testidx_all{1}=trainidx2;
testidx_all{2}=trainidx1;

model_all{1}=model1;
model_all{2}=model2;
[indS,indL,avgrate,~]=...
    cross_validation(usedidx,testidx_all,model_all,s,data_filenames,trans_filenames,data_index,sigma1,lamda1,skip);
sigma=sigma1(indL);
lamda=lamda1(indS);
end
