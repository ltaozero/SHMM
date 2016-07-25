function [model]=train_dict_base_bayesian(usedidx,trainidx,m,flagskill,S,trr, zeromean,param)
%%% usedidx is the index of the surgemes which are used in our experiment
nsurgeme=length(usedidx);
nskill=size(S,2);

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
Sigma=cell(size(S,1),size(S,2));
Lambda=cell(size(S,1),size(S,2));
fobj_total=0; Ntotal=0;
for i=1:size(S,1)*size(S,2)
    Dict{i}=[];
    if size(S{i},1)~=0
        %%%%%%%%%%only use points that come from the training data
        temptrr=repmat(trr{i},1,length(trainidx));
        tempsub=repmat(trainidx,size(temptrr,1),1);
        
        temp=S{i}(sum(temptrr==tempsub,2)~=0,:);
        mm=m;
        % train the dictionary only if there are enough data
        if size(temp,1)~=0
            if size(temp,1)<m
                display(' Not enough data to train the dictionary, result might not be accurate');
                mm=size(temp,1);
            end
            
            Mu{i} = zeros(1, size(temp,2));
            if zeromean == 1
                Mu{i} = mean(temp);
                temp = temp - repmat(Mu{i},size(temp,1),1);
            end
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

   
            param.K=mm; param.max_iter =1000;
            [D, alpha, beta] = EM_dict_learn(temp, param);
            
            Dict{i}=D;
            Alpha{i} = alpha;
            Beta{i} = beta;
            
        end
    end
end
model.Dict = Dict;
model.Alpha = Alpha;
model.Beta = Beta;
model.Mu = Mu;
model.prior = param.prior;

end

