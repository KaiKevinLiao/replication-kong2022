% Run all Matlab Code for main manuscript
tic
cd(fileparts(mfilename('fullpath')))

% Estimation
run 'matlab/E1_Sample_kdensity.m'
run 'matlab/E2_Estimate_gchoice.m'
run 'matlab/E3_Estimate_P.m'
run 'matlab/E4_Estimate_theta.m'
run 'matlab/E5_Estimate_theta_am.m'

% Counterfactual analysis
% Fixed-royalty auctions
run 'matlab/C01_Fit_theta_copula.m'
run 'matlab/C02_Fixed_royalty_values.m'
run 'matlab/C03_Fixed_royalty_bids.m'
run 'matlab/C04_Fixed_royalty_SPA.m'
run 'matlab/C05_Fixed_royalty_comparison.m'
% Scoring auctions
run 'matlab/C06_Quasi_linear_scoring.m'   
% Higher oil prices
run 'matlab/C07_Increase_p_values.m'
run 'matlab/C08_Increase_p_bids.m'
run 'matlab/C09_Increase_p_compare.m'
% Longer lease duration, with American option valuation
run 'matlab/C10_Fit_theta_copula_am.m'
run 'matlab/C11_Fixed_royalty_values_am.m'
run 'matlab/C12_Fixed_royalty_bids_am.m'
run 'matlab/C13_Fixed_royalty_comparison_am.m'
run 'matlab/C14_Increase_t_values_am.m'
run 'matlab/C15_Increase_t_bids_am.m'
run 'matlab/C16_Increase_t_compare_am.m'

% Figures and Tables
run 'matlab/figure1.m'
run 'matlab/figure2.m'
run 'matlab/figure4.m'
run 'matlab/figure5_6_7.m'
run 'matlab/figure8_table_4_5.m'  
toc