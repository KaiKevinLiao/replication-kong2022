% Compute bids in a fixed-royalty first price auction

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load lease values at fixed royalty rates
load('../calculations/Fixed_royalty_values.mat')
% Load simulated draws of theta, index values
load('../calculations/Fit_theta_copula.mat')

ss = length(T.roy); % # rows in the data
t = 3; % lease duration
R = [0:0.01:0.5]; % grid of fixed royalties
LR = length(R);

C = cell(ss/2,LR);
parfor i = 1:ss/2 % simulate the counterfactual bids for each observed auction. 2 bids per auction.
if ~isnan(T.theta1(i*2-1)) && ~isnan(T.theta1(i*2))

    % Condition simulated thetas on quality index of this auction
    cond = zs>T.index(i*2)-0.005 & zs<T.index(i*2)+0.005;
    ctos1 = tos1(cond); ctos2 = tos2(cond);
    cts1 = ts1(cond); cts2 = ts2(cond);

    for j = 1:LR
        % For simulated thetas, compute V(a,theta) at a=R and S,sigma,r_cc values of auction i
        vs = black( R(j),cts1,cts2,T.S(i*2),T.sigma(i*2),t,T.r_cc(i*2) );
        vos = black( R(j),ctos1,ctos2,T.S(i*2),T.sigma(i*2),t,T.r_cc(i*2) );

        % Compute the FPA bid for each bidder in this auction. The function
        % apvfpa() accounts for affiliation between bidders.
        frb1j = apvfpa(V(i*2-1,j),vs,vos); % bidder1
        frb2j = apvfpa(V(i*2,j),vs,vos); % bidder2
        winner1j = frb1j>frb2j; % bidder1
        winner2j = 1-winner1j; % bidder2
        C{i,j} = [frb1j winner1j; frb2j winner2j];
    end
    
end
end

%% Collect output
output = NaN(ss,LR*2);
for i = 1:ss/2
if ~isnan(T.theta1(i*2-1)) && ~isnan(T.theta1(i*2))
    row = C{i,1};
    for j = 2:LR
        row = [row C{i,j}];
    end
    output(2*i-1:2*i,:) = row;
end
end
frb = output(:,1:2:LR*2-1); % bids in fixed-royalty auction
winner = output(:,2:2:LR*2); % indicator for who wins

save('../calculations/Fixed_royalty_bids.mat','t','R','frb','winner')