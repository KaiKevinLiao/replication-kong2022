% Compute lease values when lease duration = 6 years, at fixed royalty rates
% Remember that these values are per acre.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load estimated thetas for american option
load('../calculations/Estimate_theta_am.mat')
pdrilleu = pdrill;

% organize relevant variables into a data table
T = table(theta1,theta2,index,S,sig2to2,sigma,t,ert,roy,r_cc,totalcash, ...
    accbid,Sert,ided,t,stateagency, theta_am1,theta_am2,pdrilleu );
T = T(nb==2,:); % use auctions for which both bids are present
ss = size(T,1);

% Generate a binary vector, 'use', indicating whether types for both bids in each
% 2-bidder auction are identified.
nanauc = max(reshape(isnan(T.theta1),2,[])',[],2); % flags auctions where less than both bids are identified
nanauc = reshape([nanauc'; nanauc'],[],1); % Repeat the vector to have a flag for each bid
use = nanauc==0 & T.ided==1;

clearvars theta1 theta2 index S sig2to2 sigma t ert roy r_cc totalcash ...
    accbid Sert ided t stateagency theta_am1 theta_am2 nanauc pdrill

% Counterfactual: lease duration = 6 years
t = 6;
T.sig2to2 = T.sigma.^2.*t./2; 
T.ert = exp(-T.r_cc.*t);
T.Sert = T.S.*T.ert;

% Compute value of the option with t=6 given fixed royalties and estimated thetas.
% Grid of royalties
frgrid = [0:0.01:0.5];
V = NaN(ss,length(frgrid));
for i = 1:length(frgrid)
    for j = 1:ss
        if isnan(T.theta_am1(j))
            V(j,i) = NaN;
        else
            V(j,i) = american_value( T.S(j).*(1-frgrid(i)).*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
        end
    end
end

% Save
save('../calculations/Increase_t_values_am.mat')