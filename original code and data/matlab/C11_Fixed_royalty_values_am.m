% Compute lease values at fixed royalty rates
% American option

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

% Generate a binary vector, 'use', indicating whether types for both bids in each
% 2-bidder auction are identified.
nanauc = max(reshape(isnan(T.theta1),2,[])',[],2); % flags auctions where less than both bids are identified
nanauc = reshape([nanauc'; nanauc'],[],1); % Repeat the vector to have a flag for each bid
use = nanauc==0 & T.ided==1;

clearvars theta1 theta2 index S sig2to2 sigma t ert roy r_cc totalcash ...
    accbid Sert ided t stateagency theta_am1 theta_am2 nanauc pdrill

% Compute value of the option given fixed royalties and estimated thetas.
frgrid = [0:0.01:0.5]; % Grid of royalties
V = NaN(length(T.theta_am1),length(frgrid));
for i = 1:length(frgrid)
    for j = 1:length(T.theta_am1)
        
        if isnan(T.theta_am1(j))
            V(j,i) = NaN;
        else
            V(j,i) = american_value( T.S(j).*(1-frgrid(i)).*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), T.t(j), steps );
        end
    end
end

% Save
save('../calculations/Fixed_royalty_values_am.mat')