% Generate Table 4, Table 5, and Figure 8
cd(fileparts(mfilename('fullpath')))
addpath('functions')

%%
clear; clc;

% Outcomes of LA cash-royalty auction and fixed-royalty auctions
load('../calculations/CR_and_FR_outcomes.mat')

% Outcomes of quasi-linear scoring auctions
load('../calculations/Quasi_linear_scoring.mat')

powergrid = [1:1:10];
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
    notnan = isnan(rchoice_qls(:,col(j)))==0;
    rmean(j) = mean(rchoice_qls(notnan,col(j))); % mean
    rmedian(j) = median(rchoice_qls(notnan,col(j))); % median
    rvar(j) = var(rchoice_qls(notnan,col(j))); % variance

    s_ave_cpad(j) = qls_ave_cpad(col(j));
    s_ave_gvalpad(j) = qls_ave_gvalpad(col(j));
    s_totalgvalpad(j) = qls_totalgvalpad(col(j));
    s_ave_bvalpad(j) = qls_ave_bvalpad(col(j));
    s_social_surplus(j) = qls_social_surplus(col(j));

    % Probability of development
        x_qls = x_black( rchoice_qls(:,col(j)),T.theta1,T.theta2,T.S,T.sigma,T.t );
        s_pdrill = normcdf(x_qls-T.sigma.*sqrt(T.t));
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

%% Table 4
table4 = round([avecashportion; rmean; rmedian] , 2);
csvwrite('../output/Table4.csv',table4) % output   


%% Table 5
% About the fixed-royalty second price auction:
    % maximum revenue and revenue maximizing royalty rate
    [bestrrev,bestrI] = max(fixroy_totalgvalpad_spa);
    % information rents
    fixroy_ave_irpad_spa = fixroy_ave_bvalpad(bestrI) - fixroy_ave_cpad_spa(bestrI);
    % social surplus
    fixroy_ave_socialsurplus = fixroy_ave_bvalpad(bestrI) + fixroy_ave_gvalpad(bestrI);

% Fraction of scoring auctions that achieve same allocation as fixed-royalty auction? for rho=1
sameallo = won_qls(:,col(1))==frspawinner(:,bestrI);
sameallo = mean(sameallo(won_qls(:,col(1))==1 & use==1));

% Table 5, column 1
Table_fr = [round(R(bestrI),2); round(R(bestrI),2); 
    round(fixroy_totalgvalpad_spa(bestrI), 0); 
    round(fixroy_ave_gvalpad(bestrI), 0); 
    round(fixroy_ave_cpad_spa(bestrI), 0);  
    round(fixroy_ave_irpad_spa, 0); 
    NaN; 
    round(fixroy_ave_pdrill(bestrI), 2); 
    round(fixroy_ave_socialsurplus, 0) ];
% Table 5, column 2
Table_s = [round(rmean(1),2); round(rmedian(1),2); 
    round(s_totalgvalpad(1), 0);  
    round(s_ave_gvalpad(1), 0);  
    round(s_ave_cpad(1), 0);  
    round(s_ave_irpad(1), 0);  
    round(sameallo, 2); 
    round(s_ave_pdrill(1), 2); 
    round(s_social_surplus(1), 0) ]; 
 
table5 = [Table_fr Table_s];
csvwrite('../output/Table5.csv',table5) % output 
 
% difference between columns of Table 5:
diff = Table_s - Table_fr;


%% Figure 8
fig = figure;
yyaxis left % left y-axis
l1 = plot(powergrid,rvar,'--'); % plot variance of royalties bid
ylim([0 0.125])
ylabel('Variance of royalties bid','FontSize',14)
xlabel('\rho','FontSize',14)
yyaxis right % right y-axis
l2 = plot(powergrid,maxrev); % plot total government revenue
hold on
l3 = plot([1;10],max(fixroy_totalgvalpad_spa).*ones(2,1),'-.'); % plot revenue from optimal fixed-royalty SPA
hold off
text(5.5,2893,'Optimal fixed-royalty auction revenue','color',[0.8500, 0.3250, 0.0980],'HorizontalAlignment','center')
ylabel('Total government revenue ($ per acre)','FontSize',14)
legend( [l1;l2] , {'variance of royalties bid (left y-axis)','total government revenue (right y-axis)'}, 'Location','East' );
print(fig,'-depsc','../output/figure8.eps') % output