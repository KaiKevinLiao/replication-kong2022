

function output=american_value(F, K, r, sigma, time, no_steps)


%--------------------------------------------------------------------------
% DESCRIPTION:
% Value of a lease as an American option, adapted from 
% american_call_futures_bin by Paolo Zagaglia, February 2012
%
%--------------------------------------------------------------------------
% INPUTS:
% F:        firm's share of revenue
% K:        cost of production
% r:        interest rate
% sigma:    volatility
% time:     lease duration
% no_steps: number of steps in binomial tree
%--------------------------------------------------------------------------

prices = zeros(no_steps+1,1);
node_values = zeros(no_steps+1,1);

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
end
    

for ( step=no_steps:-1:1 ) 
    for ( i=1:1:(step) ) 
        prices(i) = d*prices(i+1);
        node_values(i)    = (pDown*node_values(i)+pUp*node_values(i+1))*Rinv;
        node_values(i)    = max(node_values(i), prices(i)-K); 
    end
end

output = node_values(1);

