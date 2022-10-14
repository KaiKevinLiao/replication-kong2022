% Generate Table A4, Table A5, and Figure A8
% American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

%% Preliminary data upload and calculation
clear; clc;
% Estimated theta values
load('../calculations/Fixed_royalty_values_am.mat')
% Outcome of fixed-royalty second-price auctions
load('../calculations/Fixed_royalty_SPA_am.mat')
% Outcomes of quasi-linear scoring auctions
load('../calculations/Quasi_linear_scoring_am.mat')

ss = size(T,1);

for j = 1:length(powergrid)
    % Vector of weights for a fixed power
    x = w(abs(power-powergrid(j))<10^-4);
    % Corresponding vector of gov revenue for a fixed power
    y = qls_totalgvalpad(abs(power-powergrid(j))<10^-4);
    % Amount and index of maximum revenue for this power
    [M,I] = max(y);
    bestw(j) = x(I); % Revenue maximizing weight for this power
    maxrev(j) = M; % Maximum revenue for this power
    col(j) = (j-1)*100+I; % Column number of revenue maximizing weight
    % Investigate distribution of royalties bid under this scoring rule
    notnan = ~isnan(rchoice_qls(:,col(j)));
    rmean(j) = mean(rchoice_qls(notnan,col(j))); % mean
    rmedian(j) = median(rchoice_qls(notnan,col(j))); % median
    rvar(j) = var(rchoice_qls(notnan,col(j))); % variance

    s_ave_cpad(j) = qls_ave_cpad(col(j));
    s_ave_gvalpad(j) = qls_ave_gvalpad(col(j));
    s_totalgvalpad(j) = qls_totalgvalpad(col(j));
    s_ave_bvalpad(j) = qls_ave_bvalpad(col(j));
    s_social_surplus(j) = qls_social_surplus(col(j));
    
    % Probability of development
    s_pdrill = NaN(ss,1);
    for k = 1:ss
        s_pdrill(k) = american_probex( T.S(k)*(1-rchoice_qls(k,col(j)))*T.theta_am1(k), T.theta_am2(k), T.r_cc(k), T.sigma(k), T.t(k), steps );
    end
    s_ave_pdrill(j) = mean(s_pdrill(won_qls(:,col(j))==1 & use==1));    
    
    % Average proportion of cash in score
        roypart = T.S.*bestw(j).*(-1./(rchoice_qls(:,col(j)).^powergrid(j)));
        % Normalize min()=0
            roypart = roypart - min(roypart(use==1));
            cashpart = bpaid_qls(:,col(j)) - min(bpaid_qls(use==1,col(j)));
        score = cashpart + roypart;
        cashportion = cashpart./score;
        royportion = roypart./score;
        avecashportion(j) = mean(cashportion(use==1));
        averoyportion(j) = mean(royportion(use==1));
end

% Bidder's information rent
s_ave_irpad = s_ave_bvalpad-s_ave_cpad;

%% Table A4: Details of quasi-linear scoring auctions
TableA4 = round([avecashportion(1:10); rmean(1:10); rmedian(1:10)],2);
csvwrite('../output/TableA4.csv',TableA4) % output

%% Table A5: Fixed royalty second-price auction vs Second score auction
% About the fixed-royalty second price auction:
    % maximum revenue and revenue maximizing royalty rate
    [bestrrev,bestrI] = max(fixroy_totalgvalpad_spa);
    % information rents
    fixroy_ave_irpad_spa_bestr = fixroy_ave_bvalpad(bestrI) - fixroy_ave_cpad_spa(bestrI);
    % social surplus
    fixroy_ave_socialsurplus_bestr = fixroy_ave_bvalpad(bestrI) + fixroy_ave_gvalpad(bestrI);
    % Pr(option exercise)
    fixroy_pdrill = NaN(ss,1);
    for j = 1:ss 
        fixroy_pdrill(j) = american_probex( T.S(j)*(1-frgrid(bestrI))*T.theta_am1(j), T.theta_am2(j), T.r_cc(j), T.sigma(j), T.t(j), steps );
    end
    fixroy_ave_pdrill_bestr = mean(fixroy_pdrill(frspawinner(:,bestrI)==1 & use==1));
    
% Fraction of scoring auctions that achieve same allocation as fixed-royalty auction? for rho=1
sameallo = won_qls(:,col(1))==frspawinner(:,bestrI);
sameallo = mean(sameallo(won_qls(:,col(1))==1 & use==1));

% Table A5, column 1
Table_fr = [round(frgrid(bestrI),2); round(frgrid(bestrI),2); 
    round(fixroy_totalgvalpad_spa(bestrI) ,0); 
    round(fixroy_ave_gvalpad(bestrI) ,0); 
    round(fixroy_ave_cpad_spa(bestrI) ,0); 
    round(fixroy_ave_irpad_spa_bestr ,0); 
    NaN; 
    round(fixroy_ave_pdrill_bestr ,2); 
    round(fixroy_ave_socialsurplus_bestr ,0) ];
% Table A5, column 2
Table_s = [round(rmean(1),2); round(rmedian(1),2); 
    round(s_totalgvalpad(1) ,0); 
    round(s_ave_gvalpad(1) ,0); 
    round(s_ave_cpad(1) ,0); 
    round(s_ave_irpad(1) ,0); 
    round(sameallo ,2); 
    round(s_ave_pdrill(1) ,2); 
    round(s_social_surplus(1) ,0) ];
 
TableA5 = [Table_fr Table_s];
csvwrite('../output/TableA5.csv',TableA5) % output 

%% Figure A8
fig = figure;
yyaxis left
l1 = plot(powergrid,rvar,'--');
ylim([0 0.13])
ylabel('Variance of royalties bid','FontSize',14)
xlabel('\rho','FontSize',14)
yyaxis right
l2 = plot(powergrid,maxrev);
hold on
l3 = plot([1;max(powergrid)],max(fixroy_totalgvalpad_spa).*ones(2,1),'-.'); %, [1;10],current_totalgvalpad.*ones(2,1),':')
hold off
text(8,2812,'Optimal fixed-royalty auction revenue','color',[0.8500, 0.3250, 0.0980],'HorizontalAlignment','center')
ylabel('Total government revenue ($ per acre)','FontSize',14)
xlim([1 15])
legend( [l1;l2] , {'variance of royalties bid (left y-axis)','total government revenue (right y-axis)'}, 'Location','East' );
print(fig,'-depsc','../output/figureA8.eps') % output