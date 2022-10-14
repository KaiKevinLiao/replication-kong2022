% Produce Appendix Table A2

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load outcomes of LA cash-royalty auction and fixed-royalty auction
load('../calculations/CR_and_FR_outcomes.mat')
ss = height(T); % number of rows
benchmarkr = 23; % benchmark royalty is 23%

%% Keep cash-royalty auction bids but allocate to winner of 23% fixed royalty auction = Allocative effect
winner_fr = winner(:,benchmarkr+1); % fixed royalty auction winners
% Cash: cash revenue per acre
allofr_ave_cpad = mean(T.totalcash(winner_fr==1 & use==1));
% Royalty: Ex-ante value of royalties to government
current_gvalpad = T.Sert.*T.roy.*T.theta1.*normcdf(T.xsol);
allofr_ave_gvalpad = mean(current_gvalpad(winner_fr==1 & use==1));
% Total gov revenue
allofr_totalgvalpad = allofr_ave_cpad + allofr_ave_gvalpad;
    
%% Result table
Table = [current_totalgvalpad current_ave_cpad current_ave_gvalpad;
        allofr_totalgvalpad allofr_ave_cpad allofr_ave_gvalpad;
        fixroy_totalgvalpad(benchmarkr+1) fixroy_ave_cpad(benchmarkr+1) fixroy_ave_gvalpad(benchmarkr+1)];
% output 
csvwrite('../output/TableA2.csv',round(Table)) 