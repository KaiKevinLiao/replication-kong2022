% Estimate thetas for American option values

cd(fileparts(mfilename('fullpath')))
addpath('functions')

%% Import Data
clear; clc;
load('../calculations/Estimate_theta.mat') % Contains data and est. theta values from European model
ss = length(sigma); % sample size

% Generate a binary vector, 'use', indicating whether types for both bids in each
% 2-bidder auction are identified.
nanauc = max(reshape(isnan(theta1(nb==2)),2,[])',[],2); % flags auctions where less than both bids are identified (given nb==2)
nanauc = reshape([nanauc'; nanauc'],[],1); % Repeat the vector to have a flag for each bid
nanauc = [nanauc; ones(sum(nb==1),1)]; % Fill in placeholders for nb==1 cases
use = nanauc==0 & ided==1 & nb==2;

% Right-hand sides of FOCs (8) and (9)
rhs1 = dcdroy;
rhs2 = totalcash + P./dPdc;

%% Estimate thetas using fmincon
steps = 100; % Number of steps for binomial tree.
options = optimset('MaxFunEvals',1e10,'Display','off');
theta_am = NaN(ss,2);
objval = NaN(ss,1);
for i=1:ss
    if isnan(theta1(i))
        theta_am(i,:) = [NaN NaN]; 
        objval(i) = NaN;
    else
        startval = [theta1(i) theta2(i)];
        lb = startval.*0.001;
        ub = startval.*1000;
        % Minimize violation of FOCs
        [sol, fval] = fmincon(@(th) focs_am( th,S(i),roy(i),r_cc(i),sigma(i),t(i),steps,deltar,rhs1(i),rhs2(i) ), ...
            startval,[],[],[],[],lb,ub,[],options);
        theta_am(i,:) = sol;
        objval(i) = fval; % How well were FOCs satisfied.
    end
end

theta_am1 = theta_am(:,1);
theta_am2 = theta_am(:,2);
save('../calculations/Estimate_theta_am.mat')