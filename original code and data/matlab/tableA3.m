% Produce Appendix Table A3
% Uses American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load outcomes of LA cash-royalty auction and fixed-royalty auction
load('../calculations/CR_and_FR_outcomes_am.mat')
ss = height(T); % number of rows

benchmarkr = 23; % benchmark royalty is 23%
% For each bid, compute ex-ante value of royalties to government
current_gvalpad = NaN(ss,1);
for j = 1:ss
    current_gvalpad(j) = american_gval( T.S(j), T.roy(j), T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
end

%% Keep cash-royalty auction bids but allocate to winner of 23% fixed royalty auction = Allocative effect
winner_fr = winner(:,benchmarkr+1);
% Cash: cash revenue per acre
allofr_ave_cpad = mean(T.totalcash(winner_fr==1 & use==1));
% Royalty: Ex-ante value of royalties to government
allofr_ave_gvalpad = mean(current_gvalpad(winner_fr==1 & use==1));
% Total gov revenue
allofr_totalgvalpad = allofr_ave_cpad + allofr_ave_gvalpad;
    
%% Result table
Table = [current_totalgvalpad current_ave_cpad current_ave_gvalpad;
        allofr_totalgvalpad allofr_ave_cpad allofr_ave_gvalpad;
        fixroy_totalgvalpad(benchmarkr+1) fixroy_ave_cpad(benchmarkr+1) fixroy_ave_gvalpad(benchmarkr+1)];
% output 
csvwrite('../output/TableA3.csv',round(Table)) 