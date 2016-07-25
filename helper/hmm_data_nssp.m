
function [rall,prall,ratebasic,labelbasic,ratesmooth,path1,pathsmooth1]=hmm_data_nssp(usedidx,Dict,data_filenames, trans_filenames, data_index)
ntrial = length(data_filenames);
if (length(trans_filenames)~=ntrial)
    error('Number of data files does not equal number of transcription files');
end
data = cell(1,ntrial);
Trans = cell(1,ntrial);
for i = 1 : ntrial
    [data{i}, Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, data_index);
end

rall=cell(ntrial,1);
prall=cell(ntrial,1);
nsurgeme=length(usedidx);
path1=cell(ntrial,1);
pathsmooth1=cell(ntrial,1);
for k=1:ntrial;
  temp=data{k}';
  %get the ground truth of the data
  trans=Trans{k};
%temp=temp(:,ismember(trans,usedidx));  %%just look at those surgemes
  
  %Compute the residual of each frame 
   nclass=size(Dict,1)*size(Dict,2);
   r=5000*ones(nclass,size(temp,2));
   pr=1*ones(nclass, size(temp,2));
    for j=1:nclass %actually only 21 dictionary
         if size(Dict{j},1)~=0
           rin=zeros(size(Dict{j},2),size(temp,2));
          for dicidx=1:size(Dict{j},2)
              tempD=Dict{j}{dicidx};
              rr=temp-tempD*inv(tempD'*tempD)*tempD'*temp;
              rin(dicidx,:)=sqrt(sum(rr.*rr));
          end  
          if size(Dict{j},2)==1
              r(j,:)=rin;
          else
          r(j,:)=min(rin);
          end
          %% calculate the posterior probabiliry 
          sigma=0.8;%sqrt(0.84.^2/78);
          
          pr(j,:)=(2*pi*sigma.^2).^(-39)*exp(-r(j,:).*r(j,:)/2/sigma/sigma); 
        end
    end
    [~,ii]=min(r);
    level=ceil(ii/length(usedidx));
    labelbasic(k)=mode(level);
    rall{k}=r;
    prall{k}=pr;
    
    [~,path]=min(r(labelbasic(k)*nsurgeme-nsurgeme+1:labelbasic(k)*nsurgeme,:));
    path=usedidx(path);
    ratebasic(k)=sum(path==trans)/length(path);
    
    stepn=15;
    pathsmooth=zeros(1,size(r,2));
    pathsmooth(1:stepn)=1;
   

      for i=stepn+1:size(r,2)-stepn
        [~,pathsmooth(i)]=min(sum(r(:,i-stepn:i+stepn),2));
        pathsmooth(i)=mod(pathsmooth(i)-1,nsurgeme)+1;
      end
      pathsmooth(size(r,2)-stepn:end)=pathsmooth(size(r,2)-stepn);
      pathsmooth=usedidx(pathsmooth);
     ratesmooth(k)=sum(pathsmooth==trans)/length(pathsmooth);
     path1{k}=path;
     pathsmooth1{k}=pathsmooth;

end