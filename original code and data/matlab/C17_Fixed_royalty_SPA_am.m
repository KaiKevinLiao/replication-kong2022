% Compute cash revenue from fixed-royalty, second-price auctions.
% American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

% Import necessary data and estimates
clear; clc;
load('../calculations/Fixed_royalty_values_am.mat')
ss = height(T);

% Compute value of the option given fixed royalties and estimated thetas.
frgrid = [0:0.01:0.29 0.2901:0.0001:0.3099 0.31:0.01:0.5]; % Grid of royalties
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

%% Run second price fixed royalty auction
frspawinner = NaN(ss,length(frgrid));
frspacash = NaN(ss,length(frgrid));
for j = 1:length(frgrid) % Loop over royalty

    % Identify winner. Recall N=2, and consecutive rows belong to same
    % auction.
    v_byauction = [V([1:2:ss-1],j) V([2:2:ss],j)]; % each row is an auction
        % If one bidder of an auction shows NaN, discard whole auction
        v_byauction(isnan(v_byauction(:,1)),2) = NaN;
        v_byauction(isnan(v_byauction(:,2)),1) = NaN;
    % Winner is the one with higher v
    bidder1wins = v_byauction(:,1) > v_byauction(:,2);
    winnerid = bidder1wins.*1 + (1-bidder1wins).*2;
    % Construct logical vector indicating whether a row contains winner
    frspawin = zeros(ss,1);
    frspawin([0:2:ss-2]' + winnerid) = 1;
    
    % Cash from each auction
    sparev = min(v_byauction,[],2); % cash revenue = smaller of two cash bids
    sparev = reshape([sparev'; sparev'],[],1);
    
    % Collect in matrix with j columns
    frspawinner(:,j) = frspawin; % indicator for who wins
    frspacash(:,j) = sparev; % cash revenue from the auctions
end

%% Compute expected auction revenue
fixroy_ave_cpad_spa = NaN(length(frgrid),1);
fixroy_ave_gvalpad = NaN(length(frgrid),1);
fixroy_ave_bvalpad = NaN(length(frgrid),1);
for c = 1:length(frgrid)
    % Cash revenue per acre
    fixroy_ave_cpad_spa(c) = mean(frspacash(frspawinner(:,c)==1 & use==1,c));
    % Ex-ante value of royalties to government
    gvalpad = NaN(ss,1);
    for j = 1:ss
        gvalpad(j) = american_gval( T.S(j), frgrid(c), T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), T.t(j), steps );
    end
    fixroy_ave_gvalpad(c) = mean(gvalpad(frspawinner(:,c)==1 & use==1));
    % Value of the option to winning bidder
    bvald = V(:,c);
    fixroy_ave_bvalpad(c) = mean(bvald(frspawinner(:,c)==1 & use==1));
end
% Total government revenue from second-price fixed-royalty auction
fixroy_totalgvalpad_spa = fixroy_ave_cpad_spa + fixroy_ave_gvalpad;

%% Save
save('../calculations/Fixed_royalty_SPA_am.mat','frgrid','frspawinner','frspacash','fixroy_ave_cpad_spa','fixroy_ave_gvalpad','fixroy_totalgvalpad_spa','fixroy_ave_bvalpad','ss')