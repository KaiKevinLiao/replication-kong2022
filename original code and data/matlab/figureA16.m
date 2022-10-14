% Produce Figure A16
% American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Outcomes at original oil prices
load('../calculations/Fixed_royalty_comparison_am.mat')
% Outcomes at higher prices
load('../calculations/Increase_p_values_am.mat')
load('../calculations/Increase_p_bids_am.mat')
ss = size(T,1);

%% Compute outcomes on a grid of fixed royalties
fixroy_ave_cpad = NaN(length(frgrid),1);
fixroy_ave_gvalpad = NaN(length(frgrid),1);
fixroy_pdrill = NaN(ss,length(frgrid));
fixroy_isoptallo = NaN(length(frgrid),1);

for i=0:50 % From royalty = 0% to 50%
    c = i+1; % Column of matrix to use
    a = i/100; % The fixed royalty
    % cash revenue per acre
    cash = frb(:,c);
    fixroy_ave_cpad(c) = mean(cash(winner(:,c)==1 & use==1));
    
    % Ex-ante value of royalties to government
    % Compute using binomial tree
    gvalpad = NaN(ss,1);
    for j = 1:ss
        gvalpad(j) = american_gval( T.S(j), a, T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
    end
    fixroy_ave_gvalpad(c) = mean(gvalpad(winner(:,c)==1 & use==1));
end
% Total ex-ante gov revenue: cash+royalty
fixroy_totalgvalpad = fixroy_ave_cpad + fixroy_ave_gvalpad;

%% Figure A16
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
print(fig,'-depsc',['../output/figureA16.eps'])