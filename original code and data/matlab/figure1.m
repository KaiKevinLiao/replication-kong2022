% Generate Figure 1

cd(fileparts(mfilename('fullpath')))

%% Import Data
clear; clc;
D = csvread('../calculations/summary_and_scatter.csv',1,0);
lntotal = D(:,1); 
royalty = D(:,2);
numbids = D(:,3);

fig = figure;
scatter(royalty, lntotal,'+') 
xlabel('royalty','FontSize',14)
ylabel('ln(cash per acre)','FontSize',14)
xlim([0.1 0.5]) 
ylim([2 11])
pbaspect([1.25 1 1])
print(fig,'-depsc',['../output/figure1.eps'])