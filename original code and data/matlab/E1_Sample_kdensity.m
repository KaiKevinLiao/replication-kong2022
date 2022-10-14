% Sample from joint density of two 2-D bids.
% Marginal densities are estimated via kernels; affiliation is estimated via Gaussian copula.

cd(fileparts(mfilename('fullpath')))

%% Import Data
clear; clc;
D = csvread('../calculations/Data_for_kdensity.csv',1,0);
roy_dm = D(:,1);
lncpad_dm = D(:,2);
accbid = D(:,3);
rng(0,'twister');

% Rename
x = lncpad_dm;
y = roy_dm;
% Form a vector of the corresponding competing bid components
    xo = reshape(x,2,[])';
    xo = reshape([xo(:,2) xo(:,1)]',[],1);
    yo = reshape(y,2,[])';
    yo = reshape([yo(:,2) yo(:,1)]',[],1);    

% Convert to quantiles using kernel estimation
u = ksdensity(x,x,'function','cdf');
v = ksdensity(y,y,'function','cdf');
uo = ksdensity(xo,xo,'function','cdf');
vo = ksdensity(yo,yo,'function','cdf');

% Fit Gaussian copula on all four components
Rho = copulafit('Gaussian',[u v uo vo]);

% Generate a large random sample
r = copularnd('Gaussian',Rho,10^7);

% Simulated quantiles of i's bid components
z1 = r(:,1);
z2 = r(:,2);
% Simulated quantiles of j's bid components, allowed to be affiliated with i's
u1 = r(:,3);
v1 = r(:,4);

% Convert simulated quantiles back to lncpad_dm, roy_dm
xs = NaN(10^5,10^2); ys = NaN(10^5,10^2); 
parfor i = 1:10^2
    xs(:,i) = ksdensity(xo,u1((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
    ys(:,i) = ksdensity(yo,v1((i-1)*(10^5)+1:i*(10^5)),'function','icdf');
end

% reshape
xs = reshape(xs,[],1);
ys = reshape(ys,[],1);

save('../calculations/Sample_kdensity.mat','Rho','xs','ys','z1','z2','x','y')