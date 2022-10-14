% Produce Figures A9-A15 of appendix
% Uses American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load outcomes of LA cash-royalty auction and counterfactual fixed-royalty auction
load('../calculations/CR_and_FR_outcomes_am.mat')
benchmark = 0.23;

%% Figure A9: Royalty revenue
fig = figure;
plot(R, fixroy_ave_gvalpad,'k', [0;0.5],ones(2,1).*current_ave_gvalpad,'r--', benchmark.*ones(2,1),[0;2500],':b')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
legend('Fixed-royalty','Location','Southeast')
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,0,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .56 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA9.eps'])

%% Figure A10: Cash revenue
fig = figure;
plot(R,fixroy_ave_cpad,'k', ...
    [0;0.5],ones(2,1).*current_ave_cpad,'r--', benchmark.*ones(2,1),[500;1500],'b:')
legend('Fixed-royalty','Location','Northeast')
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,500,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
xlim([0.1 0.4])
ylim([500 1500])
annotation('textbox',[.89 .36 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA10.eps'])

%% Figure A11: Total gov revenue
fig = figure;
plot(R,fixroy_totalgvalpad,'k', ...
    [0;0.5],ones(2,1).*current_totalgvalpad,'r--', ...
    0.125.*ones(2,1),[2200;2800],'b:',  0.25.*ones(2,1),[2200;2800],'b:' )
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
legend('Fixed-royalty','Location','Northeast')
xlim([0.09 0.5])
txt1 = {'standard','federal','rate','\downarrow'};
txt2 = {'standard','private','rate','\downarrow'};
text(0.125,2200,txt1,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
text(0.25,2200,txt2,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .38 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA11.eps'])

%% Figure A12: Information rents in dollars per acre
fig = figure;
plot(R, fixroy_ave_irpad,'k', [0;0.5],ones(2,1).*current_ave_irpad,'r--', ...
    benchmark.*ones(2,1),[600;2000],'b:')
legend('Fixed-royalty','Location','Northeast')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)    
xlim([0.1 0.4])
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,600,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .485 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA12.eps'])

%% Figure A13: Exercise Probability
fig = figure;
plot(R,fixroy_ave_pdrill,'k', [0;0.5],current_ave_pdrill.*ones(2,1),'r--', benchmark.*ones(2,1),[0.2;0.65],'b:')
text(benchmark,0.2,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
legend('Fixed-royalty','Location','Northeast')
xlabel('fixed royalty','FontSize',14)
annotation('textbox',[.89 .51 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA13.eps'])

%% Figure A14: Social surplus
fig = figure;
plot(R, social_surplus,'k', [0;0.5],ones(2,1).*current_social_surplus,'r--', ...
    benchmark.*ones(2,1),[2600;4400],'b:')
legend('Fixed-royalty','Location','Northeast')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
text(benchmark,2600,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .59 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA14.eps'])

%% Figure A15: Allocative Performance
fig = figure;
plot(R,fixroy_isoptallo,'k', [0;0.5],current_isoptallo.*ones(2,1),'r--')
xlabel('fixed royalty','FontSize',14) 
ylim([0.9 1])
annotation('textbox',[.89 .42 .1 .1],'String','\leftarrow LA','EdgeColor','none','color',[0.8500, 0.3250, 0.0980])
print(fig,'-depsc',['../output/figureA15.eps'])