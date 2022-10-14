% Compare LA cash-royalty system to fixed-royalty benchmark.
% American option

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
load('../calculations/Fixed_royalty_values_am.mat')
load('../calculations/Fixed_royalty_bids_am.mat')

ss = length(T.theta_am1);

%% LA cash-royalty auction
% cash revenue per acre
current_ave_cpad = mean(T.totalcash(T.accbid==1 & use==1));

% Ex-ante value of royalties to government per acre
gvalpad = NaN(ss,1);
for j = 1:ss
    gvalpad(j) = american_gval( T.S(j), T.roy(j), T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
end
current_ave_gvalpad = mean(gvalpad(T.accbid==1 & use==1));
    
% Total gov revenue
current_totalgvalpad = current_ave_cpad + current_ave_gvalpad;

% Average lease value to winner
bvalpad = NaN(ss,1);
for j=1:ss
    bvalpad(j) = american_value( T.S(j)*(1-T.roy(j))*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
end
current_ave_bvalpad = mean(bvalpad(T.accbid==1 & use==1));

% Probability of exercise
current_pdrill = NaN(ss,1);
for j = 1:ss % Compute using binomial tree
    current_pdrill(j) = american_probex( T.S(j)*(1-T.roy(j))*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
end
current_ave_pdrill = mean(current_pdrill(T.accbid==1 & use==1));
    
% Social surplus
current_social_surplus = current_ave_gvalpad + current_ave_bvalpad;
% Allocation relative to 0% royalty case
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

%% Counterfactual Fixed royalty auctions
fixroy_ave_cpad     = NaN(length(frgrid),1);
fixroy_ave_gvalpad  = NaN(length(frgrid),1);
fixroy_ave_bvalpad  = NaN(length(frgrid),1);
fixroy_ave_pdrill   = NaN(length(frgrid),1);
fixroy_sameallo     = NaN(length(frgrid),1);
fixroy_isoptallo    = NaN(length(frgrid),1);
fixroy_ave_gvalpado = NaN(length(frgrid),1);
fixroy_ave_pdrillo  = NaN(length(frgrid),1);
fixroy_pdrill       = NaN(ss,length(frgrid));

for i=0:50 % From royalty = 0% to 50%

    c = i+1; % Column of matrix to use
    a = i/100; % The fixed royalty
    % bonus revenue per acre
    cash = frb(:,c);
    fixroy_ave_cpad(c) = mean(cash(winner(:,c)==1 & use==1));
    
    % Ex-ante value of royalties to government
    % Compute using binomial tree
    gvalpad = NaN(ss,1);
    for j = 1:ss
        gvalpad(j) = american_gval( T.S(j), a, T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
    end
    fixroy_ave_gvalpad(c) = mean(gvalpad(winner(:,c)==1 & use==1)); 
        
    % Value of the option to winning bidder
    bvald = V(:,c);
    fixroy_ave_bvalpad(c) = mean(bvald(winner(:,c)==1 & use==1));
    
    % Probability of exercise
    for j = 1:ss % Compute using binomial tree
        fixroy_pdrill(j,c) = american_probex( T.S(j)*(1-a)*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
    end
    fixroy_ave_pdrill(c) = mean(fixroy_pdrill(winner(:,c)==1 & use==1,c));
        
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
% Ex-ante value of the option to society
social_surplus = fixroy_ave_gvalpad + fixroy_ave_bvalpad;
% Bidder's information rent
fixroy_ave_irpad = fixroy_ave_bvalpad-fixroy_ave_cpad;

%% Save
save('../calculations/CR_and_FR_outcomes_am.mat')

%% Save - to use in other counterfactuals
fixroy_totalgvalpad_O = fixroy_totalgvalpad;
social_surplus_O = social_surplus;
fixroy_ave_pdrill_O = fixroy_ave_pdrill;
fixroy_ave_cpad_O = fixroy_ave_cpad;
fixroy_ave_gvalpad_O = fixroy_ave_gvalpad;
fixroy_isoptallo_O = fixroy_isoptallo;
save('../calculations/Fixed_royalty_comparison_am.mat','fixroy_totalgvalpad_O','social_surplus_O','fixroy_ave_pdrill_O','fixroy_ave_cpad_O','fixroy_ave_gvalpad_O','fixroy_isoptallo_O')