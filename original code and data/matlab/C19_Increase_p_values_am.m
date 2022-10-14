% Compute lease values for 20% higher oil prices, at fixed royalty rates
% Remember that these values are per acre.
% American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load estimated theta values
load('../calculations/Fixed_royalty_values_am.mat')
clearvars V
ss = size(T,1);
% Counterfactual oil prices:
T.S = T.S.*1.2;
T.Sert = T.S.*T.ert;

%% Compute value of the option given fixed royalties and estimated thetas.
frgrid = [0:0.01:0.5]; % Grid of royalties
V = NaN(ss,length(frgrid));
for i = 1:length(frgrid)
    for j = 1:ss
        if isnan(T.theta_am1(j))
            V(j,i) = NaN;
        else
            V(j,i) = american_value( T.S(j).*(1-frgrid(i)).*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), T.t(j), steps );
        end
    end
end

% Save
save('../calculations/Increase_p_values_am.mat')