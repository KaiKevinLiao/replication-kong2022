function [L] = gchoiceL(alpha,bases,win)
% Sum of log likelihood of observed goverment pairwise choices
    % P(diffr,diffc,q)= prob of being chosen
    P = bases*alpha;
    % Likelihood
    likelihood = (P.^win).*((1-P).^(1-win));
    % sum log-likelihood 
    L = sum(log(likelihood));
end

