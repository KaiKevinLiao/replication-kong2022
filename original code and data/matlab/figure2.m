% Generate Figure 2

cd(fileparts(mfilename('fullpath')))
addpath('functions')

% Import Data
clear; clc;
D = csvread('../calculations/scatter_win_loss.csv',1,0);
win = D(:,1); 
diffr = D(:,2);
diffc = D(:,3);

% Make figure
fig = figure;
scatter(diffr(win==1), diffc(win==1),'MarkerEdgeColor',[0, 0.4470, 0.7410])
hold on
scatter(diffr(win==0), diffc(win==0),'^','MarkerEdgeColor',[0.8500, 0.3250, 0.0980])
scatter(diffr(win==1 & diffr<0 & diffc<0), diffc(win==1 & diffr<0 & diffc<0),'MarkerEdgeColor',[0, 0.4470, 0.7410]) % So blue circles in lower left quadrant aren't covered up by red triangles.
hline(0,'k')
vline(0,'k')
xlabel('difference from competing bid''s royalty','FontSize',14)
ylabel('difference from competing bid''s cash ($)','FontSize',14)
legend('win','loss')
xlim([-0.125 0.125]) 
ylim([-1500 1500])
hold off
print(fig,'-depsc',['../output/figure2.eps'])