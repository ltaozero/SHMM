function [fil_path, path] = skip_viterbi(prior, transmat, log_obslik,skip)
% this functions calls the viterbi function with a skip parameter and performs median filtering with that skip length

if (~exist('skip','var'))
  skip = 1
end
nb_classes = size(log_obslik,1);
T = size(log_obslik,2);
path = zeros(1,T);

i=1;
path_tmp = viterbi_path_log(prior,transmat, log_obslik(:,i:skip:end));
path(i:skip:end) =  path_tmp;


for i = 2:skip
  equal_prior = ones(nb_classes,1)* 1.0/nb_classes;
  path_tmp = viterbi_path_log(equal_prior,transmat, log_obslik(:,i:skip:end));
  path(i:skip:end) =  path_tmp;
end

% add median fitering
fil_path = int8(medfilt1(path, skip));

%return fil_path



