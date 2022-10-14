% Compute bids in counterfactual fixed-royalty first-price auction
% American option

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
load('../calculations/Fixed_royalty_values_am.mat') % fixed-royalty lease values, american option
load('../calculations/Fit_theta_copula_am.mat') % Theta, index values simulated from estimated joint distribution

ss = length(T.roy); % # rows in the data
t = 3;
R = [0:0.01:0.5];
LR = length(R);

C = cell(ss/2,LR);
vs = cell(ss/2,LR);
vos = cell(ss/2,LR);
% Simulate the counterfactual bids for each observed auction. 2 bids per auction.
for i = 1:ss/2 
if ~isnan(T.theta1(i*2-1)) && ~isnan(T.theta1(i*2))

    % Condition simulated thetas on quality index of this auction
    cond = zs>T.index(i*2)-0.005 & zs<T.index(i*2)+0.005;
    ctos1 = tos1(cond); ctos2 = tos2(cond);
    cts1 = ts1(cond); cts2 = ts2(cond);
    L = length(cts1);
    
    for j = 1:LR
        %tic
        vall = NaN(L,2);
        parfor k = 1:L
            % For simulated thetas, compute V(a,theta) at a=R and S,sigma,r_cc values of auction i
            vsk = american_value( T.S(i*2).*(1-R(j)).*cts1(k), cts2(k), T.r_cc(i*2), T.sigma(i*2), t, steps );
            vosk = american_value( T.S(i*2).*(1-R(j)).*ctos1(k), ctos2(k), T.r_cc(i*2), T.sigma(i*2), t, steps );
            vall(k,:) = [vsk vosk];
        end
        %toc
        vs{i,j} = vall(:,1);
        vos{i,j} = vall(:,2);
    end
end
end

parfor i = 1:ss/2 
if ~isnan(T.theta1(i*2-1)) && ~isnan(T.theta1(i*2))
    for j = 1:LR
        %tic
        % Compute the FPA bid for each bidder in this auction. The function
        % apvfpa() accounts for affiliation between bidders.
        frb1j = apvfpa(V(i*2-1,j),vs{i,j},vos{i,j});
        frb2j = apvfpa(V(i*2,j),vs{i,j},vos{i,j});
        winner1j = frb1j>frb2j; % bidder1
        winner2j = 1-winner1j; % bidder2
        C{i,j} = [frb1j winner1j; frb2j winner2j];
        %toc
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
frb = output(:,1:2:LR*2-1); % bids
winner = output(:,2:2:LR*2); % indicator of who wins

save('../calculations/Fixed_royalty_bids_am.mat','t','R','frb','winner')