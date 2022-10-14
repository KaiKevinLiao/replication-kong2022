% Compute lease values at fixed royalty rates
% Remember that these values are per acre.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load estimated theta values
load('../calculations/Estimate_theta.mat')
T = table(theta1,theta2,index,S,sig2to2,sigma,t,ert,roy,r_cc,totalcash, ...
    accbid,Sert,xsol,pdrill,ided,t,stateagency );
T = T(nb==2,:); % use auctions for which both bids are present
clearvars theta1 theta2 index S sig2to2 sigma t ert roy r_cc totalcash ...
    accbid Sert xsol pdrill ided t stateagency

% Compute value of the option given fixed royalties and estimated thetas.
% Grid of royalties
frgrid = [0:0.01:0.5];
x = NaN(length(T.theta1),length(frgrid));
V = NaN(length(T.theta1),length(frgrid));
for i = 1:length(frgrid)
    x(:,i) = (log((1-frgrid(i)).*T.S.*T.theta1./T.theta2) + T.sig2to2)./(T.sigma.*sqrt(T.t));
    V(:,i) = T.ert.*( (1-frgrid(i)).*T.S.*T.theta1.*normcdf(x(:,i)) - T.theta2.*normcdf(x(:,i)-(T.sigma.*sqrt(T.t))) );
end

% Save
save('../calculations/Fixed_royalty_values.mat')