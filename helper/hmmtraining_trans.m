%learning hmm parameter
function[prior,transp]=hmmtraining_trans(usedidx,trainidx,trans_filenames,skip)
if (~exist('skip','var'))
  skip=1
end


Trans = cell(1, length(trans_filenames));
for i = 1 : length(trans_filenames)
    trans = read_trans(trans_filenames{i}); 
    Trans{i} = trans;
end

Nstate=max(usedidx);tranp=zeros(Nstate); p=zeros(Nstate,1);
pstart=zeros(Nstate,1);pend=zeros(Nstate,1);

for i=1:length(trainidx)
    trans=Trans{trainidx(i)};
    trans=trans(ismember(trans,usedidx));
    pstart(trans(1))= pstart(trans(1))+1;
  for j=1:size(trans,2)-skip    
        p(trans(j))=p(trans(j))+1;
        tranp(trans(j),trans(j+skip))=...
            tranp(trans(j),trans(j+skip))+1;
  end
end

prior=pstart./sum(pstart);
transp=tranp./repmat(p,1,Nstate);
prior=prior(usedidx);  % only pick the gestures used
transp=transp(usedidx,usedidx);
