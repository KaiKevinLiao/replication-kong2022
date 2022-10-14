% Fit a copula to the thetas of two bidders and the index
% American option estimation
cd(fileparts(mfilename('fullpath')))
addpath('functions')

%%
clear; clc;
rng(0,'twister')  % For reproducibility

% Load estimated theta values
load('../calculations/Estimate_theta_am.mat')
theta_am1 = theta_am1(nb==2); % use auctions for which both bids are present
theta_am2 = theta_am2(nb==2);
index = index(nb==2);

x = log(theta_am1);
y = log(theta_am2);
% Form a vector of the corresponding competing theta components
    xo = reshape(x,2,[])';
    xo = reshape([xo(:,2) xo(:,1)]',[],1);
    yo = reshape(y,2,[])';
    yo = reshape([yo(:,2) yo(:,1)]',[],1);    
% Drop NaNs
good = ~isnan(x+y+xo+yo);
x=x(good); y=y(good); xo=xo(good); yo=yo(good);
z = index(good);

% Convert to quantiles
u = ksdensity(x,x,'function','cdf');
v = ksdensity(y,y,'function','cdf');
uo = ksdensity(xo,xo,'function','cdf');
vo = ksdensity(yo,yo,'function','cdf');
% z is already a quantile by construction

% Fit copula
Rho = copulafit('Gaussian',[u v uo vo z]);

% Generate a large random sample
ss = 10^7;
r = copularnd('Gaussian',Rho,ss);

% Simulated quantiles of i's thetas and index
tq1 = r(:,1);
tq2 = r(:,2);
zs = r(:,5);
% Simulated quantiles of j's thetas, allowed to be affiliated with i's
toq1 = r(:,3);
toq2 = r(:,4);

%% Convert simulated j quantiles back to log thetas
xs = NaN(10^5,ss/(10^5)); ys = xs; xos = xs; yos = xs;
tic
parfor i = 1:ss/(10^5) % running in parfor loop is faster than doing the 10^7 vector at once
    
    xs(:,i) = ksdensity(x,tq1((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
    ys(:,i) = ksdensity(y,tq2((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
    xos(:,i) = ksdensity(xo,toq1((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
    yos(:,i) = ksdensity(yo,toq2((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
end
toc
% Convert to thetas
ts1 = exp(xs);
ts2 = exp(ys);
tos1 = exp(xos);
tos2 = exp(yos);
% reshape to vector
ts1 = reshape(ts1,[],1);
ts2 = reshape(ts2,[],1);
tos1 = reshape(tos1,[],1);
tos2 = reshape(tos2,[],1);

save('../calculations/Fit_theta_copula_am.mat','Rho','ts1','ts2','tos1','tos2','tq1','tq2','zs')