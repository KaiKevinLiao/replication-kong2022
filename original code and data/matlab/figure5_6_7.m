% Produce Figures 5-7

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load outcomes of LA cash-royalty auction and fixed-royalty auction
load('../calculations/CR_and_FR_outcomes.mat')
benchmark = 0.23;

%% Figure 5: Royalty revenue
fig = figure;
plot(R, fixroy_ave_gvalpad,'k', [0;0.5],ones(2,1).*current_ave_gvalpad,'r--', benchmark.*ones(2,1),[0;2500],'b:')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
legend('Fixed-royalty','Location','Southeast')
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,0,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .595 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figure5.eps'])

    % Maximum royalty revenue occurs at
    [M,I] = max(fixroy_ave_gvalpad);
    R(I)

%% Figure 6: Cash revenue
fig = figure;
plot(R, fixroy_ave_cpad,'k', ...
    [0;0.5],ones(2,1).*current_ave_cpad,'r--', benchmark.*ones(2,1),[500;1500],'b:')
legend('Fixed-royalty','Location','Northeast')
xlim([0.1 0.4])
ylim([500 1500])
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,500,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
annotation('textbox',[.89 .36 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figure6.eps'])

    % Absolute difference between cash-royalty and 23% fixed royalty auction:
    fixroy_ave_cpad(benchmark*100+1) - current_ave_cpad
    % Percent difference:
    1 - current_ave_cpad/fixroy_ave_cpad(benchmark*100+1)

%% Figure 7: Total gov revenue
fig = figure;
plot(R,fixroy_totalgvalpad,'k', ...
    [0;0.5],ones(2,1).*current_totalgvalpad,'r--', ...
    0.125.*ones(2,1),[2250;2850],'b:',  0.25.*ones(2,1),[2250;2850],'b:' )
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
legend('Fixed-royalty','Location','Northeast')
xlim([0.09 0.5])
ylim([2250 2850])
txt1 = {'standard','federal','rate','\downarrow'};
txt2 = {'standard','private','rate','\downarrow'};
text(0.125,2250,txt1,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
text(0.25,2250,txt2,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .475 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figure7.eps'])

    % royalty rates at which cash-royalty auction yields higher revenue
    R(fixroy_totalgvalpad<current_totalgvalpad)
    % Absolute difference between cash-royalty and 23% fixed royalty auction:
    fixroy_totalgvalpad(benchmark*100+1) - current_totalgvalpad
    % Percent difference:
    fixroy_totalgvalpad(benchmark*100+1)/current_totalgvalpad - 1

    % revenue maximizing fixed-royalty rate:
    best_fixedroy = R(fixroy_totalgvalpad==max(fixroy_totalgvalpad));
    % Absolute difference between cash-royalty and optimal fixed royalty auction:
    max(fixroy_totalgvalpad) - current_totalgvalpad
    % Percent difference:
    max(fixroy_totalgvalpad)/current_totalgvalpad - 1