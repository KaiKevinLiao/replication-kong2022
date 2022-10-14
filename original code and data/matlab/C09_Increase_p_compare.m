% Assess effect of 20% higher oil prices on government revenue.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Outcomes at original oil prices
load('../calculations/Fixed_royalty_comparison.mat')
% Outcomes at higher prices
load('../calculations/Increase_p_values.mat')
load('../calculations/Increase_p_bids.mat')

% Generate a binary vector, 'use', indicating whether types for both bids in each
% 2-bidder auction are identified.
nanauc = max(reshape(isnan(T.theta1),2,[])',[],2); % flags auctions where less than both bids are identified
nanauc = reshape([nanauc'; nanauc'],[],1); % Repeat the vector to have a flag for each bid
use = nanauc==0 & T.ided==1;

ss = length(T.roy);

%% Compute outcomes on a grid of fixed royalties
fixroy_ave_gvalpad = NaN(length(R),1);
fixroy_pdrill = NaN(length(T.theta1),length(R));
fixroy_isoptallo = NaN(length(R),1);
fixroy_ave_cpad = NaN(length(R),1);
fixroy_ave_pdrill = NaN(length(R),1);

for i=0:50 % From royalty = 0% to 50%
    c = i+1; % Column of matrix to use
    a = i/100; % The fixed royalty
    % cash revenue per acre
    cash = frb(:,c);
    fixroy_ave_cpad(c,1) = mean(cash(winner(:,c)==1 & use==1));
    % Ex-ante value of royalties to government
    gvalpad = T.Sert.*a.*T.theta1.*normcdf(x(:,c)); % This is per acre.
    fixroy_ave_gvalpad(c) = mean(gvalpad(winner(:,c)==1 & use==1));

    % Probability of exercise
    fixroy_pdrill = normcdf(x(:,c)-T.sigma.*sqrt(t));
    fixroy_ave_pdrill(c) = mean(fixroy_pdrill(winner(:,c)==1 & use==1));

    % Revenue optimal allocation
        exanterev = cash + gvalpad;
        bdr1better = exanterev(1:2:ss-1) > exanterev(2:2:ss); % Bidder 1 would yield more revenue
        optallo = reshape([bdr1better'; (1-bdr1better)'],[],1); % Optimal allocation in current auction.
        isoptallo = winner(:,c)==optallo;
    fixroy_isoptallo(c) = mean(isoptallo((winner(:,c)==1 & use==1))); % Fraction of auctions that achieve optimal alloc.
end

% Total ex-ante gov revenue: bonus+royalty
fixroy_totalgvalpad = fixroy_ave_cpad + fixroy_ave_gvalpad;

%% Figure A7: Plot government revenue
fig = figure;
plot(frgrid,fixroy_totalgvalpad, frgrid,fixroy_totalgvalpad_O,'--', ...
    0.125.*ones(2,1),[0;4500],'b:',  0.25.*ones(2,1),[0;4500],'b:' )
xlabel('royalty','FontSize',14)
ylabel('revenue in dollars per acre','FontSize',14)
legend('at counterfactual prices','at observed prices','Location','Southeast')
txt1 = {'standard','federal','rate','\downarrow'};
txt2 = {'standard','private','rate','\downarrow'};
text(0.125,0,txt1,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
text(0.25,0,txt2,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
print(fig,'-depsc',['../output/figureA7.eps'])

% percentage difference in government revenue
min(fixroy_totalgvalpad./fixroy_totalgvalpad_O)
max(fixroy_totalgvalpad./fixroy_totalgvalpad_O)