function [model]=train_dict_base_bayesian(usedidx,trainidx,m,flagskill,S,trr, zeromean,param)
%%% usedidx is the index of the surgemes which are used in our experiment
nsurgeme=length(usedidx);
nskill=size(S,2);
%%%Train a dictionary using SPAMS software
if strcmp(param.prior,'invgamma')&& sum(isfield(param, {'a', 'b', 'c', 'd','prior'}))~=5 
   error('Wrong input param');
end
if strcmp(param.prior,'gamma')&& ~isfield(param, 'lambda') 
   error('Wrong input param');
end
if ~strcmp(param.prior, 'gamma') && ~strcmp(param.prior, 'invgamma')
  error('prior type unknown');
end

if ~flagskill
    S1=cell(nsurgeme,1);
    trr1=cell(nsurgeme,1);
    for i=1:nsurgeme
        S1{i}=cell2mat(S(usedidx(i):size(S,1):end)');
        trr1{i}=cell2mat(trr(usedidx(i):size(S,1):end)');
    end
    
    
else
    S1=cell(nsurgeme,nskill);
    trr1=cell(nsurgeme,nskill);
    for i=1:nsurgeme
        S1(i+nsurgeme*[0:1:nskill-1])=S(usedidx(i):size(S,1):end);
        trr1(i+nsurgeme*[0:1:nskill-1])=trr(usedidx(i):size(S,1):end);
    end
end
S=S1;trr=trr1;
clear S1; clear trr1;

Dict=cell(size(S,1),size(S,2));
data_all = cell(size(S,1),size(S,2));
% first generate temp for all surgemes
S_total = 0;
Q_total=0;
N_total=0;
for i=1:size(S,1)*size(S,2)
   if size(S{i},1)~=0
        %%%%%%%%%%only use points that come from the training data
        temptrr=repmat(trr{i},1,length(trainidx));
        tempsub=repmat(trainidx,size(temptrr,1),1);
        
        temp=S{i}(sum(temptrr==tempsub,2)~=0,:);
        mm=m;
        % train the dictionary only if there are enough data
        if size(temp,1)~=0
            %if size(temp,1)<m
            %    display(' Not enough data to train the dictionary, result might not be accurate');
            %    mm=size(temp,1);
            %end
            
            Mu{i} = zeros(1, size(temp,2));
            if zeromean == 1
                Mu{i} = mean(temp);
                temp = temp - repmat(Mu{i},size(temp,1),1);
            end
            data_all{i} = temp;
            D = size(temp,2);
            Dict{i}=rand(D,m);
            Dict{i} = normc(Dict{i});
            x = Dict{i}'*temp';
            N_total = N_total+ size(temp,1);
            S_total = S_total+ sum(sum(x.^2));
            Q_total = Q_total+ sum(sum((temp'-Dict{i}*x).^2));
        end
    end
end

%initialization
param.K=mm; param.max_iter =2000;
alpha = (N_total*param.K+2*param.a)/(S_total+2*param.b);
beta = (N_total*D + 2*param.c)/(Q_total+2*param.b);
display(alpha)
display(beta)
%initialization


% start iteration
for iter = 1: param.max_iter
  S_total = 0;
  N_total = 0;
  Q_total = 0;
  for i =1: numel(data_all)
    data = data_all{i};
    N = size(data,1);
    M = data'*data;
    % E-step
    Sigma = inv(beta*(Dict{i}'*Dict{i}) + alpha*eye(param.K));%diag(alpha));
    % some useful values
    % V = \sum(o_t u_t^T)
    V = M*Dict{i}*Sigma'*beta;
    % S = \sum_t E(x_t x_t^T)
    S = N.*Sigma + beta.^2* Sigma*Dict{i}'*M*Dict{i}*Sigma';
    Dict{i} =V/S;% V*inv(S);
    Dict{i} = normc(Dict{i});    
    % M-step: update Dict, alpha and beta
    S_total = S_total+ sum(diag(S));
    N_total =N_total+ N;
    % Q = \sum_t E(\|o_t - Dx_t\|^2)
    Q = trace(M) - 2* trace(Dict{i}*V') + trace(Dict{i}'*Dict{i}*S);
    Q_total =Q_total+Q;    
  end
  % update beta and alpha for all class
  alpha = (param.K*N_total + 2*param.a)/(S_total+2*param.b)
  beta = (D*N_total+2*param.c) /(Q_total+2*param.d)

end
model.Dict = Dict;
model.Alpha = alpha;
model.Beta = beta;
model.Mu = Mu;
model.prior = param.prior;

end

