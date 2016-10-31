function [model]=train_dict_base_fix_beta(usedidx,trainidx,beta,m,flagskill,S,trr,isotropic, zeromean)
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
            %if size(temp,1)<m
            %    display(' Not enough data to train the dictionary, result might not be accurate');
            %    mm=size(temp,1);
            %end
            
            
            %%%Train a dictionary using SPAMS software
            param.K=mm;param.mode=2;param.lambda=beta; param.iter=1000;
            Mu{i} = zeros(1, size(temp,2));
            if zeromean == 1
                Mu{i} = mean(temp);
                temp = temp - repmat(Mu{i},size(temp,1),1);
            end
            D= mexTrainDL(temp',param);
            
            Dict{i}=D;
            alpha=mexLasso(temp',D,param);
            %meanx = sum(sum(abs(alpha)))/numel(alpha)
            %meanxx = sum(sum(alpha.^2))/numel(alpha)
            %e = temp'-D*alpha;
            %meanee = sum(sum(e.^2))/numel(e)


            fobj = 0.5*sum(sum((temp'-D*alpha).^2))+beta*sum(sum(abs(alpha)));
            fobj_total=fobj_total+ fobj;
            Ntotal=Ntotal+size(temp,1);
            % optimize over lambda and sigam, s.t. beta=lambda*sigma^2
            Sigma{i}=(fobj)./(size(temp,2)/2+mm)/size(temp,1);
            Lambda{i}=beta/Sigma{i};
            
        end
    end
end
if isotropic == 1
    for i=1:size(S,1)*size(S,2)
        Sigma{i}=(fobj_total)./(size(temp,2)/2+mm)/Ntotal;
        Lambda{i}=beta/Sigma{i};
    end
end

model.Dict = Dict;
model.Sigma = Sigma;
model.Lambda = Lambda;
model.Mu = Mu;

end

