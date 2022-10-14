% Compute cash revenue from fixed-royalty, second-price auctions.

cd(fileparts(mfilename('fullpath')))
addpath('functions')

%% Import necessary data and estimates
clear; clc;
load('../calculations/Fixed_royalty_values.mat')
ss = length(T.roy);

%% Second price auction
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

%% Save
save('../calculations/Fixed_royalty_SPA.mat','frspawinner','frspacash')