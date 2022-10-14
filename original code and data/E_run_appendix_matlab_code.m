% Run Matlab code for Appendix materials
tic
cd(fileparts(mfilename('fullpath')))

% Additional counterfactual analysis for appendix
% Fixed-royalty auctions, American option valuation
run 'matlab/C17_Fixed_royalty_SPA_am.m'
% Scoring auctions, American option valuation
run 'matlab/C18_Quasi_linear_scoring_am.m'
% Higher oil prices, American option valuation
run 'matlab/C19_Increase_p_values_am.m'
run 'matlab/C20_Increase_p_bids_am.m'

% Appendix Figures and Tables
run 'matlab/figureA1toA4.m'
run 'matlab/figureA8_table_A4_A5.m'
run 'matlab/figureA9toA15.m'
run 'matlab/figureA16.m'
run 'matlab/tableA2.m'
run 'matlab/tableA3.m'
toc