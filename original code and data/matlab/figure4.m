% Generate Figure 4

cd(fileparts(mfilename('fullpath')))
addpath('functions')

%% Import Data
clear; clc;
load('../calculations/Estimate_theta_am.mat')

%% Kernel density of theta21
grid2 = [0:0.1:100]';
% European option estimates
t21 = theta21(ided);
[ke,xie] = ksdensity(t21,grid2); 

% American option estimates
theta_am21 = theta_am2./theta_am1;
t21a = theta_am21(ided);
[ka,xia] = ksdensity(t21a,grid2); 

% Sample mean of (1-a)S
x = (1-roy(ided)).*S(ided);
avenetprice = mean(x);
    
% Plot 
fig = figure;
plot(xie,ke, xia,ka,'-.','Color',[0, 0.4470, 0.7410])
    hold on
    plot( avenetprice.*[1;1],[0;0.05],'r--' ) % Reference line
    hold off
    xlim([0 100])
    ylim([0 0.05])
    xticks([0:20:100])
    xlabel('$\hat{\theta}_2/\hat{\theta}_1$ (\$)','FontSize',14,'Interpreter','latex')
    legend('European','American','sample average of (1-a)*oil price','Location','Northeast')
print(fig,'-depsc',['../output/figure4.eps'])

%% Other stats
% Median cost-per-barrel 
t21 = theta21(ided);
median( t21 )

% Expected production conditional on median quality index
z = index(ided);
hz = std(z)*(length(z)^(-1/6)); % bandwidth
% index is "within" bandwidth of median=0.5
    % Kernel argument: length ss
    kernelarg = (0.5-z)./hz;
    % Epanechnikov kernel
    Kmz = (abs(kernelarg)<=1).*0.75.*(1-kernelarg.^2);    
% Mean conditional on median index
sum(theta1(ided).*Kmz)./sum(Kmz) 