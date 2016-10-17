
function [prall,ratebasic,labelbasic,pathbasic]=hmm_data_bayesian(usedidx,model,...
    data_filenames,trans_filenames,data_index)

nclass=numel(model.Dict);
ntrial = length(data_filenames);
if (length(trans_filenames)~=ntrial)
    error('Number of data files does not equal number of transcription files');
end

% Compute Sigma_o for each class j, used in option 1
for j = 1:nclass
    inv_Sigma_o{j} = inv(model.Dict{j}*diag(1./model.Alpha{j})*model.Dict{j}' + 1/model.Beta{j}.*eye(size(model.Dict{j},1)));
end

% matrix to compute the posterior, used in option 2
%M = cell(1,nclass);
%for j=1:nclass
%    sigma = inv(model.Beta{j}.*model.Dict{j}'*model.Dict{j}+ diag(model.Alpha{j}));
%    M{j} = model.Beta{j}.*sigma * model.Dict{j}';
%end

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
    
    r = zeros(nclass, size(temp,2));
    pr=-1e10*ones(nclass, size(temp,2));
    for j=1:nclass %
        temp1 = temp - repmat(model.Mu{j}',1,size(temp,2));
        if size(model.Dict{j},1)~=0
            % ***************   1. use marginal distribution
            % we use plus because det(Sigma) = 1/ det(inv_Sigma)
            pr(j,:) = -0.5*sum(temp1.* (inv_Sigma_o{j}*temp1))+ 0.5* log(det(inv_Sigma_o{j}));
            % ***************   2. use p(o|x)*p(x)
            % first find best x*
            %x = M{j}*temp1;
            %rr=temp1-model.Dict{j}*x;
            %r(j,:)=sqrt(sum(rr.*rr));
            %pr(j,:)=(-sum(rr.^2)*model.Beta{j}/2)+log(model.Beta{j})*(size(temp1,1)/2) ...
            %    +(-0.5*sum(model.Alpha{j}* (x.^2)))+0.5*sum(log(model.Alpha{j}));
        end
    end
    
    [~,ii]=max(pr);
    level=ceil(ii/length(usedidx));
    labelbasic(k)=mode(level);
    prall{k}=pr;
    
    [~,path]=max(pr(labelbasic(k)*nsurgeme-nsurgeme+1:labelbasic(k)*nsurgeme,:));
    path=usedidx(path);
    select_idx = find(ismember(trans, usedidx));
    ratebasic(k)=sum(path(select_idx)==trans(select_idx))/length(select_idx);
    pathbasic{k}=path;
    
end
