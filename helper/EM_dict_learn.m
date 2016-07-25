function [Dict, alpha, beta] = EM_dict_learn(data, param)
% train dictionary and alpha, beta with gamma priors on the precision of
% gaussian model



% ************************** initialize parameters
N = size(data,1); % number of training examples
D = size(data,2); % dimension of input feature
% initialize Dictionary with PCA
coeff = pca(data);
%Dict = coeff(:,1:param.K);
Dict = rand(D, param.K);
Dict = normc(Dict);

% initialize latent variable x
x = Dict'* data';
% initialize alpha and beta
alpha = zeros(1, param.K);

switch param.prior
    case 'invgamma'
        for i = 1 : param.K
            alpha(i) = (N+2*param.a)/ (sum(x(i,:).^2) + 2*param.b);
        end
    case 'gamma'
        % need to solve the quadratic equation.
        for i = 1 : param.K
            p1 = sum(x(i,:).^2)/2;
            p2 = -N/2;
            alpha(i) = (sqrt(p2^2+4*p1*param.lambda) - p2) /2/p1;
        end
end

beta = (D*N+2*param.c)/(sum(sum((data'-Dict*x).^2)) + 2*param.d);

%

% some useful intermediate parameters
% M = \sum o_t o_t^T
M = data'*data;

% EM Iterate
for iter = 1 : param.max_iter
    
    % E-step
    Sigma = inv(beta* (Dict'*Dict) + diag(alpha));
    % some useful values
    % V = \sum(o_t u_t^T)
    V = M*Dict*Sigma'*beta;
    % S = \sum_t E(x_t x_t^T)
    S = N.*Sigma + beta.^2* Sigma*Dict'*M*Dict*Sigma';
    
    % M-step: update Dict, alpha and beta
    switch param.prior
        case 'invgamma'
            for i = 1 : param.K
                alpha(i) = (N + 2*param.a) / (S(i,i) + 2*param.b);
            end
        case 'gamma'
            % need to solve the quadratic equation.            
            for i = 1 : param.K
                p1 = S(i,i)/2;
                p2 = -N/2;
                alpha(i) = (sqrt(p2^2+4*p1*param.lambda) - p2) /2/p1;
            end
    end
    Dict =V/S;% V*inv(S);
    % Q = \sum_t E(\|o_t - Dx_t\|^2)
    Q = trace(M) - 2* trace(Dict*V') + trace(Dict'*Dict*S);
    beta = (D*N+2*param.c) /(Q+2*param.d);
end
end


