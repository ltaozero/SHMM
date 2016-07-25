%% set the path to save path result at the end
%%% 
function [prall,ratebasic,labelbasic,pathbasic]=hmm_data_mppca(usedidx,Dict,data_filenames, trans_filenames, data_index)

ntrial = length(data_filenames);
if (length(trans_filenames)~=ntrial)
    error('Number of data files does not equal number of transcription files');
end
data = cell(1,ntrial);
Trans = cell(1,ntrial);
for i = 1 : ntrial
    [data{i}, Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, data_index);
end


prall=cell(ntrial,1);
pathbasic=cell(ntrial,1);
labelbasic = zeros(1,ntrial);
for k=1:ntrial
  temp=data{k}';
  %get the ground truth of the data
  trans=Trans{k};
%temp=temp(:,ismember(trans,usedidx));  %%just look at those surgemes
  
  %Compute the residual of each frame 
   nclass=size(Dict,1)*size(Dict,2);
 %  r=zeros(nclass,size(temp,2));
   pr=zeros(nclass, size(temp,2));
    for j=1:nclass %actually only 21 dictionary
         if size(Dict{j},1)~=0
             
                
          [pr(j,:)]=pr_mfa(temp,Dict{j}); % use OMP to get the sparse representation
          
         end
    end
   [~,ii]=max(pr);
    level=ceil(ii/length(usedidx));
    labelbasic(k)=mode(level);
   
    prall{k}=pr;
    
    path=usedidx(mod(ii-1,length(usedidx))+1);
    ratebasic(k)=sum(path==trans)/length(path);
    
         pathbasic{k}=path;
      
end