function [indS,indL,avgrate,rateall]=cross_validation(usedidx,testidx2,Dict2,s,data_filenames,trans_filenames,data_index,sigma1,lamda1)
% MORDIFY HERE
% Read All Data and Transcripts
%load(datapath);
%load(transpath);

for i = 1 : length(data_filenames)
    [data{i} Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, data_index);
end


rateall=cell(length(sigma1),length(lamda1));

for indD=1:length(Dict2)
    Dict=Dict2{indD};
    testidx=testidx2{indD};
    trainidx=testidx2{3-indD};
    [prior,transp]=hmmtraining_trans(usedidx,trainidx,trans_filenames);
    transp(transp==0)=0.0001;
    for k=1:length(testidx);
         temp=data{testidx(k)}';
        %get the ground truth of the data
         trans=Trans{testidx(k)};
         temp=temp(:,ismember(trans,usedidx));  %%just look at those surgemes
         %Compute the residual of each frame 
            nclass=size(Dict,1)*size(Dict,2);
            r=zeros(nclass,size(temp,2));
            pr=cell(length(sigma1),length(lamda1));
                for inds=1:length(sigma1)
                    for indl=1:length(lamda1);
                       pr{inds,indl}= zeros(nclass, size(temp,2));
                    end
                end
           for j=1:nclass %actually only 21 dictionary
              if size(Dict{j},1)~=0
                 x=omp(Dict{j},temp,Dict{j}'*Dict{j},s); % use OMP to get the sparse representation
                  rr=temp-Dict{j}*x;
                  r(j,:)=sqrt(sum(rr.*rr));
                  %% calculate the posterior probabiliry 
        %           sigma=1;%sqrt(0.84.^2/78);
        %           lamda=1/0.1493;
                 for inds=1:length(sigma1)
                 for indl=1:length(lamda1)
                     sigma=sigma1(inds);lamda=lamda1(indl);
                   pr{inds,indl}(j,:)=(-r(j,:).*r(j,:)/2/sigma/sigma)+log(sigma.^2*2*pi)*(-size(temp,1)/2) ...
               +(-lamda*sum(abs(x)))+log(lamda./2)*size(Dict{1},2);
                 end
                 end
              end
           end
          trans=Trans{testidx(k)}; 
          trans=trans(ismember(trans,usedidx));
         for inds=1:length(sigma1)
          for indl=1:length(lamda1)          
            temp=pr{inds,indl};
            valididx=find(sum(temp)~=0);
             invalididx=find(sum(temp)==0);
             temp=temp(:,valididx);
             temp(temp==0)=min(min(temp(temp~=0)));
        
           [path] = viterbi_path_log(prior, transp, temp);
            path2=zeros(size(trans));
           path2(valididx)=path;
           path2(invalididx)=1;%path2(invalididx+1);
           path=path2;      % path=path-1
           rateall{inds,indl}(testidx(k))=sum(usedidx(path)==trans)./length(path);
          end
         end
         len(testidx(k))=length(path);
         end
   end
    for inds=1:length(sigma1)
    for indl=1:length(lamda1)
       avgrate(inds,indl)=sum(rateall{inds,indl}.*len)/sum(len);
    end
    end
    [b,indL]=max(avgrate);
    [~,indS]=max(avgrate(indL));
    indL=indL(indS);
    
end
