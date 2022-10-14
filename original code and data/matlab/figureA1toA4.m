% Produce Figures A1-A4 of appendix

cd(fileparts(mfilename('fullpath')))
addpath('functions')

clear; clc;
% Load outcomes of LA cash-royalty auction and fixed-royalty auction
load('../calculations/CR_and_FR_outcomes.mat')
benchmark = 0.23;

%% A1: Information rents in dollars per acre
fig = figure;
plot(R, fixroy_ave_irpad,'k', [0;0.5],ones(2,1).*current_ave_irpad,'r--', ...
    benchmark.*ones(2,1),[500;2000],'b:')
legend('Fixed-royalty','Location','Northeast')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)    
xlim([0.1 0.4])
txt3 = {'LA','average','rate','\downarrow'};
text(benchmark,500,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .525 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA1.eps'])

fixroy_ave_irpad(benchmark*100+1) - current_ave_irpad
current_ave_irpad/fixroy_ave_irpad(benchmark*100+1) - 1

%% A2: Exercise probability
fig = figure;
plot(R,fixroy_ave_pdrill,'k', [0;0.5],current_ave_pdrill.*ones(2,1),'r--', benchmark.*ones(2,1),[0.15;0.65],'b:')
text(benchmark,0.15,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
xticks(0:0.1:0.5)
legend('Fixed-royalty','Location','Northeast')
xlabel('fixed royalty','FontSize',14)
annotation('textbox',[.89 .56 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA2.eps'])

%% A3: Social surplus
fig = figure;
plot(R, social_surplus,'k', [0;0.5],ones(2,1).*current_social_surplus,'r--', ...
    benchmark.*ones(2,1),[2500;4500],'b:')
xticks(0:0.1:0.5)
legend('Fixed-royalty','Location','Southwest')
xlabel('fixed royalty','FontSize',14)
ylabel('dollars per acre','FontSize',14)
text(benchmark,2500,txt3,'color','b','HorizontalAlignment','center','VerticalAlignment','bottom')
annotation('textbox',[.89 .635 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA3.eps'])

%% A4: Allocative Performance
fig = figure;
plot(R,fixroy_isoptallo,'k', [0;0.5],current_isoptallo.*ones(2,1),'r--')
xticks(0:0.1:0.5)
xlabel('fixed royalty','FontSize',14) 
legend('Fixed-royalty','Location','Southeast')
ylim([0.88 1])
annotation('textbox',[.89 .43 .1 .1],'String','\leftarrow LA','EdgeColor','none','color','r')
print(fig,'-depsc',['../output/figureA4.eps'])