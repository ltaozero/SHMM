%Learn MFA for each Surgeme (per skill)
function [Dict]=train_dict_base_mppca(usedidx,trainidx,num_sub,latent_dim,flagskill,ismppca,S,trr)
%%% usedidx is the index of the surgemes which are used in our experiment

nsurgeme=length(usedidx);
nskill=size(S,2);
%load '../all suturing/trr.mat';
%load '../all suturing/switches.mat';
if ~flagskill 
  S1=cell(nsurgeme,1);
  trr1=cell(nsurgeme,1);
 % switches1=cell(nsurgeme,1);
  for i=1:nsurgeme
    S1{i}=cell2mat(S(usedidx(i):size(S,1):end)');
    trr1{i}=cell2mat(trr(usedidx(i):size(S,1):end)');
 %   switches1{i}=cell2mat(switches(usedidx(i):size(S,1):end)');
  end
  
  
else
    S1=cell(nsurgeme,nskill);
    trr1=cell(nsurgeme,nskill);
   for i=1:nsurgeme
   S1(i+nsurgeme*[0:1:nskill-1])=S(usedidx(i):size(S,1):end);
   trr1(i+nsurgeme*[0:1:nskill-1])=trr(usedidx(i):size(S,1):end);
 %  switches1(i+nsurgeme*[0:1:nskill-1])=switches(usedidx(i):size(S,1):end);
   end
end
S=S1;trr=trr1;% switches=switches1;
clear S1; clear trr1;%clear switches1;

%Dict=cell(1,size(S,1)*size(S,2));
Dict=cell(size(S,1),size(S,2));

%%%%%%%%%%need change according to different setup.
for i=1:size(S,1)*size(S,2)
    Dict{i}=[];
    if size(S{i},1)~=0 
    %%%%%%%%%%only use points that come from the training data
    temptrr=repmat(trr{i},1,length(trainidx));
    tempsub=repmat(trainidx,size(temptrr,1),1);

    temp=S{i}(sum(temptrr==tempsub,2)~=0,:);
    if size(temp,1)~=0
   % tempswitches=switches{i}(sum(temptrr==tempsub,2)~=0); 
    if num_sub*latent_dim >size(temp,1)/3
        num_sub=ceil(size(temp,1)./latent_dim/3);
    end
    
    
    [logL,mppca,~]=mfa(temp',latent_dim,num_sub,ismppca,0,0);    
    Dict{i}=mppca;   
    end
    end
end
end



