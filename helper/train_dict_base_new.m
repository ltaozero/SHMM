function [model]=train_dict_base_new(usedidx,trainidx,s,m,flagskill,S, trr, zeromean)
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
Lamda=cell(size(S,1),size(S,2));
k=1;
%%%%%%%%%%need change according to different setup.
for i=1:size(S,1)*size(S,2)
    Dict{i}=[];
    if size(S{i},1)~=0
        %%%%%%%%%%only use points that come from the training data
        
        temp=S{i}(ismember(trr{i},trainidx),:);
        Mu{i} = zeros(1, size(temp,2));
        if zeromean==1
            Mu{i} = mean(temp);
            temp = temp - repmat(Mu{i}, size(temp,1),1);
        end
        %mm=m;
        if size(temp,1)~=0
            %if size(temp,1)<m
            %    mm=size(temp,1);
            %end
            %params.data =temp';
            %params.Tdata = s;
            %params.dictsize = mm;
            %params.iternum = 100;
            %params.memusage = 'normal';
            % give an initialized dictionary
            params.K = m;
            params.L = s;
            params.numIteration = 10;
            params.errorFlag=0;
            params.preserveDCAtom = 0;
            params.InitializationMethod = 'GivenMatrix';
            feat_dim = size(temp,2);
            D0 = randn(feat_dim, m);
            D0 = normc(D0);
            params.initialDictionary = D0;
            k=k+1;
            %%%train a dictionary using ksvd
            
            [Dksvd] = KSVD(temp',params);
            
            Dict{i}=Dksvd;
            %Gamma{i}=Gamma1;
            %Sigma{i}=err(end);
            %Lamda{i}=numel(Gamma1)/sum(sum(abs(Gamma1)));
        end
    end
end
model.Dict = Dict;
model.Mu = Mu;
end


