

function pr_ex=american_probex(F, K, r, sigma, time, no_steps)


%--------------------------------------------------------------------------
%
% DESCRIPTION:
%
% Computing ex-ante probability of option exercise for an american
% option using a binomial tree.
%
%--------------------------------------------------------------------------
%
% INPUTS:
%
% F:        firm's share of revenue
% K:        cost of production
% r:        interest rate
% sigma:    volatility
% time:     lease duration
% no_steps: number of steps in binomial tree
%
%--------------------------------------------------------------------------

prices = zeros(no_steps+1,1);
node_values    = zeros(no_steps+1,1);
probex = NaN(no_steps+1,1);

t_delta= time/no_steps;
Rinv = exp(-r*(t_delta));
u = exp(sigma*sqrt(t_delta));
d = 1.0/u;
uu= u*u;
pUp = (1-d)/(u-d); 
pDown = 1.0 - pUp;
prices(1) = F*(d^no_steps);


for ( i=2:(no_steps+1) ) 
    prices(i) = uu*prices(i-1); 
end    
    

for ( i=1:(no_steps+1) ) 
    node_values(i) = max(0.0, (prices(i)-K));
    probex(i) = (prices(i)-K) > 0.0;
end
    

for ( step=no_steps:-1:1 ) 
    for ( i=1:1:(step) ) 
        prices(i) = d*prices(i+1);
        node_values(i)    = (pDown*node_values(i)+pUp*node_values(i+1))*Rinv;
        node_values(i)    = max(node_values(i), prices(i)-K); 
        exercise = prices(i)-K > node_values(i);
        % If the firm exercises here, Pr(exercise)=1 at this node.
        % Otherwise, it is the expected Pr(exercise) of the two branches
        % extending from this node.
        probex(i) = exercise*1 + (1-exercise)*(pDown*probex(i) + pUp*probex(i+1));
    end
end

pr_ex = probex(1);

