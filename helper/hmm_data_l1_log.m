function [rall,prall,ratebasic,labelbasic,pathbasic]=hmm_data_l1_log(usedidx,model,...
    data_filenames,trans_filenames,data_index)

ntrial = length(data_filenames);
if (length(trans_filenames)~=ntrial)
    error('Number of data files does not equal number of transcription files');
end
Sigma = model.Sigma;
Lambda = model.Lambda;
Dict = model.Dict;
s = model.sparsity;
Mu = model.Mu;

data = cell(1,ntrial);
Trans = cell(1,ntrial);
for i = 1 : ntrial
    [data{i}, Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, data_index);
end

rall=cell(ntrial,1);
prall=cell(ntrial,1);
nsurgeme=length(usedidx);
pathbasic=cell(ntrial,1);
labelbasic = zeros(1, ntrial);
ratebasic = zeros(1, ntrial);

for k=1:ntrial;
    temp=data{k}';
    %get the ground truth of the data
    trans=Trans{k};
    %temp=temp(:,ismember(trans,usedidx));  %%just look at those surgemes
    % COMMENT THIS LINE
    % WE WANT TO GET THE RESULT OF WHOLE SERIES
    %Compute the residual of each frame
    nclass=size(Dict,1)*size(Dict,2);
    r=1e10*ones(nclass,size(temp,2));
    pr=-1e10*ones(nclass, size(temp,2));
    for j=1:nclass %
        sigma=Sigma;lamda=Lambda;
        % sigma=Sigma{j};lamda=Lamda{j};
        lamda(isnan(lamda)|isinf(lamda))=10000;
        temp1 = temp - repmat(Mu{j}',1,size(temp,2));
        if size(Dict{j},1)~=0
            x=OMP(Dict{j},temp1,s); % use OMP to get the sparse representation
            
            %x=omp(Dict{j},temp1,Dict{j}'*Dict{j},s); % use OMP to get the sparse representation
            rr=temp1-Dict{j}*x;
            r(j,:)=sqrt(sum(rr.*rr));
            
            
            pr(j,:)=(-r(j,:).*r(j,:)/2/sigma/sigma)+log(sigma.^2*2*pi)*(-size(temp1,1)/2) ...
                +(-lamda*sum(abs(x)))+log(lamda./2)*size(Dict{j},2);
            
            %  pr(j,:)=exp(pr(j,:));
        end
    end
    [~,ii]=min(r);
    level=ceil(ii/length(usedidx));
    labelbasic(k)=mode(level);
    rall{k}=r;
    prall{k}=pr;
    
    [~,path]=min(r(labelbasic(k)*nsurgeme-nsurgeme+1:labelbasic(k)*nsurgeme,:));
    path=usedidx(path);
    select_idx = find(ismember(trans, usedidx));
    ratebasic(k)=sum(path(select_idx)==trans(select_idx))/length(select_idx);    
    pathbasic{k}=path;    
end
