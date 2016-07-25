function [path,loglik] = viterbi_path_log(prior, transmat, log_obslik)
% VITERBI Find the most-probable (Viterbi) path through the HMM state trellis.
% path = viterbi(prior, transmat, obslik)
%
% Inputs:
% prior(i) = Pr(Q(1) = i)
% transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% obslik(i,t) = Pr(y(t) | Q(t)=i)
%
% Outputs:
% path(t) = q(t), where q1 ... qT is the argmax of the above expression.


% delta(j,t) = prob. of the best sequence of length t-1 and then going to state j, and O(1:t)
% psi(j,t) = the best predecessor state, given that we ended up in state j at t

scaled = 0;

T = size(log_obslik, 2);
prior = prior(:);
Q = length(prior);

delta = zeros(Q,T);
psi = zeros(Q,T);
path = zeros(1,T);
scale = ones(1,T);

log_prior=1.*log(prior);
log_transmat=1.*log(transmat);
%add these 2 lines temporarily
%log_prior(log_prior<-100) = -1e6;
%log_transmat(log_transmat<-100) = -1e6;

log_prior(isinf(log_prior))=-1e6;
log_transmat(isinf(log_transmat))=-1e6;
%log_obslik=log(obslik);
t=1;
delta(:,t) = log_prior+log_obslik(:,t);

psi(:,t) = 0; % arbitrary value, since there is no predecessor to t=1
for t=2:T
  for j=1:Q
    [delta(j,t), psi(j,t)] = max(delta(:,t-1) +log_transmat(:,j));
    delta(j,t) = delta(j,t)+log_obslik(j,t);
  end
  
end
[p, path(T)] = max(delta(:,T));
for t=T-1:-1:1
  path(t) = psi(path(t+1),t+1);
end

% If scaled==0, p = prob_path(best_path)
% If scaled==1, p = Pr(replace sum with max and proceed as in the scaled forwards algo)
% Both are different from p(data) as computed using the sum-product (forwards) algorithm



  loglik = p;
end


%prob=delta(Q,T);
