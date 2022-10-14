% Compare LA cash-royalty system to fixed-royalty benchmark.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
load('../calculations/Fixed_royalty_values.mat')
% Generate a binary vector, 'use', indicating whether types for both bids in each
% 2-bidder auction are identified.
nanauc = max(reshape(isnan(T.theta1),2,[])',[],2); % flags auctions where less than both bids are identified
nanauc = reshape([nanauc'; nanauc'],[],1); % Repeat the vector to have a flag for each bid
use = nanauc==0 & T.ided==1;

% Fixed royalty FPA bids
load('../calculations/Fixed_royalty_bids.mat')
% SPA cash revenue
load('../calculations/Fixed_royalty_SPA.mat')
ss = length(T.roy);
t = 3;

%% LA cash-royalty auction
% cash revenue per acre
current_ave_cpad = mean(T.totalcash(T.accbid==1 & use==1));
% Ex-ante value of royalties to government
gvalpad = T.Sert.*T.roy.*T.theta1.*normcdf(T.xsol); % This is per acre.
current_ave_gvalpad = mean(gvalpad(T.accbid==1 & use==1));
% Total to gov
current_totalgvalpad = current_ave_cpad + current_ave_gvalpad;
% Average lease value to winner
bvalpad = T.ert.*((1-T.roy).*T.S.*T.theta1.*normcdf(T.xsol) - T.theta2.*normcdf(T.xsol-T.sigma.*sqrt(t)));
current_ave_bvalpad = mean(bvalpad(T.accbid==1 & use==1));
% Probability of exercise
current_ave_pdrill = mean(T.pdrill(T.accbid==1 & use==1));
% Social surplus
current_social_surplus = current_ave_gvalpad + current_ave_bvalpad;
% Allocation relative to 0% case
sameallo = T.accbid==winner(:,1);
current_sameallo = mean(sameallo(T.accbid==1 & use==1));
% Bidder's information rent
current_ave_irpad = current_ave_bvalpad-current_ave_cpad;
% Revenue optimal allocation
    exanterev = T.totalcash + gvalpad;
    bdr1better = exanterev(1:2:ss-1) > exanterev(2:2:ss); % Bidder 1 would yield more revenue
    optallo = reshape([bdr1better'; (1-bdr1better)'],[],1); % Optimal allocation in current auction.
    isoptallo = T.accbid==optallo;
current_isoptallo = mean(isoptallo(T.accbid==1 & use==1)); % Fraction of auctions that achieve optimal alloc.

%% Fixed royalty auctions

fixroy_ave_cpad = NaN(length(R),1);
fixroy_ave_cpad_spa = NaN(length(R),1);
fixroy_ave_gvalpad = NaN(length(R),1);
fixroy_ave_bvalpad = NaN(length(R),1);
social_surplus = NaN(length(R),1);
fixroy_sameallo = NaN(length(R),1);
fixroy_pdrill = NaN(length(T.theta1),length(R));
fixroy_isoptallo = NaN(length(R),1);

for i=0:50 % From royalty = 0% to 50%
    c = i+1; % Column of matrix to use
    a = i/100; % The fixed royalty
    % bonus revenue per acre
    cash = frb(:,c);
    fixroy_ave_cpad(c) = mean(cash(winner(:,c)==1 & use==1));
    fixroy_ave_cpad_spa(c) = mean(frspacash(frspawinner(:,c)==1 & use==1,c));
    % Ex-ante value of royalties to government
    gvalpad = T.Sert.*a.*T.theta1.*normcdf(x(:,c)); % This is per acre.
    fixroy_ave_gvalpad(c) = mean(gvalpad(winner(:,c)==1 & use==1));
    % Value of the option to winning bidder
    bvald = V(:,c);
    fixroy_ave_bvalpad(c) = mean(bvald(winner(:,c)==1 & use==1));
    
    % Probability of exercise
    fixroy_pdrill = normcdf(x(:,c)-T.sigma.*sqrt(t));
    fixroy_ave_pdrill(c) = mean(fixroy_pdrill(winner(:,c)==1 & use==1));
    % Change in allocation relative to zero royalty case.
    sameallo = winner(:,c)==winner(:,1);
    fixroy_sameallo(c) = mean(sameallo(winner(:,c)==1 & use==1));
    
    % Revenue optimal allocation
        exanterev = cash + gvalpad;
        bdr1better = exanterev(1:2:ss-1) > exanterev(2:2:ss); % Bidder 1 would yield more revenue
        optallo = reshape([bdr1better'; (1-bdr1better)'],[],1); % Optimal allocation in current auction.
        isoptallo = winner(:,c)==optallo;
    fixroy_isoptallo(c) = mean(isoptallo((winner(:,c)==1 & use==1))); % Fraction of auctions that achieve optimal alloc.
end

% Total ex-ante gov revenue: bonus+royalty
fixroy_totalgvalpad = fixroy_ave_cpad + fixroy_ave_gvalpad;
fixroy_totalgvalpad_spa = fixroy_ave_cpad_spa + fixroy_ave_gvalpad;
% Ex-ante value of the option to society
social_surplus = fixroy_ave_gvalpad + fixroy_ave_bvalpad;
% Bidder's information rent
fixroy_ave_irpad = fixroy_ave_bvalpad-fixroy_ave_cpad;

%% Save
save('../calculations/CR_and_FR_outcomes.mat')

%% Save - to use in other counterfactuals
fixroy_totalgvalpad_O = fixroy_totalgvalpad;
social_surplus_O = social_surplus;
fixroy_ave_pdrill_O = fixroy_ave_pdrill;
fixroy_ave_cpad_O = fixroy_ave_cpad;
fixroy_ave_gvalpad_O = fixroy_ave_gvalpad;
fixroy_isoptallo_O = fixroy_isoptallo;
save('../calculations/Fixed_royalty_comparison.mat','fixroy_totalgvalpad_O','social_surplus_O','fixroy_ave_pdrill_O','fixroy_ave_cpad_O','fixroy_ave_gvalpad_O','fixroy_isoptallo_O')