% Assess effect of longer lease duration (t=6) on government revenue.
% American option

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% t=3 results
load('../calculations/Fixed_royalty_comparison_am.mat')
% Counterfactual t=6 lease values and bids
load('../calculations/Increase_t_values_am.mat')
load('../calculations/Increase_t_bids_am.mat')

ss = size(T,1);
benchmark = 0.23;

%% Counterfactual fixed royalty auctions, t=6
fixroy_ave_cpad = NaN(length(frgrid),1);
fixroy_ave_gvalpad = NaN(length(frgrid),1);
fixroy_pdrill = NaN(ss,length(frgrid));
fixroy_isoptallo = NaN(length(frgrid),1);

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
        
    % Probability of exercise
    for j = 1:ss % Compute using binomial tree
        fixroy_pdrill(j,c) = american_probex( T.S(j)*(1-a)*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), t, steps );
    end
    fixroy_ave_pdrill(c) = mean(fixroy_pdrill(winner(:,c)==1 & use==1,c));
    
    % Revenue optimal allocation
        exanterev = cash + gvalpad;
        bdr1better = exanterev(1:2:ss-1) > exanterev(2:2:ss); % Bidder 1 would yield more revenue
        optallo = reshape([bdr1better'; (1-bdr1better)'],[],1); % Optimal allocation in current auction.
        isoptallo = winner(:,c)==optallo;
    fixroy_isoptallo(c) = mean(isoptallo((winner(:,c)==1 & use==1))); % Fraction of auctions that achieve optimal alloc.

end
% Total ex-ante gov revenue: bonus+royalty
fixroy_totalgvalpad = fixroy_ave_cpad + fixroy_ave_gvalpad;

%% Figure A5: Plot Pr(Option exercise)
fig = figure;
plot(frgrid,fixroy_ave_pdrill, frgrid,fixroy_ave_pdrill_O,'--')
xlabel('royalty','FontSize',14)
legend('6 year lease','3 year lease','Location','Southwest')
print(fig,'-depsc',['../output/figureA5.eps'])

% display Pr(exercise) at benchmark royalty rate
fixroy_ave_pdrill_O(benchmark*100+1) % t=3
fixroy_ave_pdrill(benchmark*100+1) % t=6

%% Figure A6: Plot total government revenue
fig = figure;
plot(frgrid,fixroy_totalgvalpad, frgrid,fixroy_totalgvalpad_O,'--', ...
    0.125.*ones(2,1),[0;3500],'b:',  0.25.*ones(2,1),[0;3500],'b:' )
xlabel('royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
legend('6 year lease','3 year lease','Location','Southeast')
ylim([0 3500])
txt1 = {'standard','federal','rate','\downarrow'};
txt2 = {'standard','private','rate','\downarrow'};
text(0.125,0,txt1,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
text(0.25,0,txt2,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
print(fig,'-depsc',['../output/figureA6.eps'])

% display Percentage Difference in gov revenue between t=3 and t=6 leases, at benchmark
% royalty rate
fixroy_totalgvalpad(benchmark*100+1)/fixroy_totalgvalpad_O(benchmark*100+1) - 1