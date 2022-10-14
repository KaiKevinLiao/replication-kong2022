% Compute lease values for 20% higher oil prices, at fixed royalty rates
% Remember that these values are per acre.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load estimated theta values
load('../calculations/Fixed_royalty_values.mat')
clearvars x V

% Counterfactual oil prices:
T.S = T.S.*1.2;
T.Sert = T.S.*T.ert;

%% Compute value of the option given fixed royalties and estimated thetas.
% Grid of royalties
frgrid = [0:0.01:0.5];
x = NaN(length(T.theta1),length(frgrid));
V = NaN(length(T.theta1),length(frgrid));
for i = 1:length(frgrid)
    x(:,i) = (log((1-frgrid(i)).*T.S.*T.theta1./T.theta2) + T.sig2to2)./(T.sigma.*sqrt(T.t));
    V(:,i) = T.ert.*( (1-frgrid(i)).*T.S.*T.theta1.*normcdf(x(:,i)) - T.theta2.*normcdf(x(:,i)-(T.sigma.*sqrt(T.t))) );
end

% Save
save('../calculations/Increase_p_values.mat')