

function gval=american_gval(S, roy, theta1, K, r, sigma, time, no_steps)

%--------------------------------------------------------------------------
%
% DESCRIPTION:
%
% Computing government ex-ante value for royalties from an american
% option using a binomial tree.
%
%--------------------------------------------------------------------------
%
% INPUTS:
%
% S:        price
% roy:      royalty rate
% theta1:   expected production
% K:        cost of production
% r:        interest rate
% sigma:    volatility
% time:     lease duration
% no_steps: number of steps in binomial tree
% 
%--------------------------------------------------------------------------

% Firm revenue at current spot price S
R = S*(1-roy)*theta1;
    
firm_revenue = zeros(no_steps+1,1);
call_values  = zeros(no_steps+1,1);

t_delta= time/no_steps;
Rinv = exp(-r*(t_delta));
u = exp(sigma*sqrt(t_delta));
d = 1.0/u;
uu= u*u;
pUp = (1-d)/(u-d); 
pDown = 1.0 - pUp;

%% Revenue and Values in the last period.
% Revenues (determined by prices)
firm_revenue(1) = R*(d^no_steps);
for ( i=2:(no_steps+1) ) 
    firm_revenue(i) = uu*firm_revenue(i-1); 
end    
% Values
for ( i=1:(no_steps+1) ) 
    call_values(i) = max(0.0, (firm_revenue(i)-K));
    % Government value: whenever the firm exercises, the gov receives
    % S*roy*theta1. Otherwise, gov receives 0.
    gov_values(i) = ((firm_revenue(i)-K)>0.0)*(firm_revenue(i)/(1-roy)*roy);
end

%% Move backwards through binomial tree to compute values to government
for ( step=no_steps:-1:1 ) % Going through time periods from next-to-last to first.
    for ( i=1:1:(step) ) % Going through the branches in that time period from lowest price to highest.
        firm_revenue(i) = d*firm_revenue(i+1); % Firm revenue in time t branches as function of revenue in t+1 branches.
        % Update option value at this node
        call_values(i)    = (pDown*call_values(i)+pUp*call_values(i+1))*Rinv;
        gov_values(i)     = (pDown*gov_values(i) +pUp*gov_values(i+1))*Rinv;
        % Check whether the firm would want to exercise.
        call_values(i)    = max(call_values(i), firm_revenue(i)-K);
        % If firm exercises, update government value at this node to
        % reflect exercise.
        exercise = (firm_revenue(i)-K) > call_values(i);
        gov_values(i) = exercise*firm_revenue(i)/(1-roy)*roy + (1-exercise)*gov_values(i);
    end
end

gval = gov_values(1);

