% For each datapoint, compute the probability of winning, P(a,b) and its numerical derivatives at that
% point.

cd(fileparts(mfilename('fullpath')))
addpath('functions') 

%% Import Data
clear; clc; close all;
D = csvread('../calculations/Data_for_theta_est.csv',1,0);

accbid = D(:,1);
roy_dm = D(:,2);
lncpad_dm = D(:,3);
roy = D(:,4);
totalcash = D(:,5);
e_roy = D(:,6);
e_lncpad = D(:,7); 
wtim_d = D(:,8); 
r_cc = D(:,9); 
primaryterm = D(:,10); 
year = D(:,11);
iv = D(:,12); 
develop = D(:,13); 
stateagency = D(:,14);
rowid = D(:,15);
acreage = D(:,16);
index = D(:,17);
nb = D(:,18);

ld = length(roy_dm);

%% Load estimated government choice probability
load('../calculations/Estimate_gchoice.mat')

%% Prepare to evaluate numerical derivatives
% The `delta' to be used for numerical derivatives
deltar = 0.005;
deltac = 0.01.*totalcash; % dollars

rdown = roy - deltar;
rup = roy + deltar;
cdown = totalcash - deltac;
cup = totalcash + deltac;
% "Demean" 
roy_dm_down = rdown - e_roy;
roy_dm_up = rup - e_roy;
lncpad_dm_down = log(cdown) - e_lncpad;
lncpad_dm_up = log(cup) - e_lncpad; 
% Form matrix of [original rdown rup cdown cup] for both roy_dm and
% lncpad_dm
royV = [roy rdown rup roy roy];
cashV = [totalcash totalcash totalcash cdown cup];
roydmV = [roy_dm roy_dm_down roy_dm_up roy_dm roy_dm];
lncdmV = [lncpad_dm lncpad_dm lncpad_dm lncpad_dm_down lncpad_dm_up];

%% P(a,b) and derivatives
% Load sample of demeaned bids
load('../calculations/Sample_kdensity.mat')
samplelncdmall = xs;
samplerdmall = ys;

% Convert observed demeaned bids to quantiles used in
% "E1_sample_kdensity.m"
lncdmq = ksdensity(x,lncpad_dm,'function','cdf');
rdmq = ksdensity(y,roy_dm,'function','cdf');

% Computation of P:
PV = NaN(ld,5);
samplect = NaN(ld,1);
% For each column of roydmV, lncdmV:
parfor i = 1:ld % rows of original data
    % To allow for affiliation, condition sample bids on each observed bid.
    cond = z1>lncdmq(i)-0.005 & z1<lncdmq(i)+0.005 & z2>rdmq(i)-0.005 & z2<rdmq(i)+0.005;
    samplelncdm = samplelncdmall(cond);
    samplerdm = samplerdmall(cond);
    samplect(i) = sum(cond);
    % For each datapoint in the row, compute diffr and lndiffc relative to the sample bid.
    diffrM = repmat(roydmV(i,:),samplect(i),1) - repmat(samplerdm,1,5);
    lndiffcM = repmat(lncdmV(i,:),samplect(i),1) - repmat(samplelncdm,1,5);
    % Convert to quantile
    drnM = interp1(drn_table(:,1),drn_table(:,2),diffrM); % linear interpolation
    dcnM = interp1(dcn_table(:,1),dcn_table(:,2),lndiffcM); % linear interpolation
        % Quantiles are bounded [0,1]
        drnM = min(max(drnM,0.001),0.999);
        dcnM = min(max(dcnM,0.001),0.999); 

    % Compute prob of being chosen against each sample bid:
    PM = NaN(samplect(i),5);
    for j = 1:samplect(i) % rows of sample bids
        for k = 1:5 % columns [original rdown rup cdown cup]
            PM(j,k) = bernstein_bases_trivariate( drnM(j,k),dcnM(j,k),index(i), dr,dc,dq )*Bernstein_parameters; 
        end
    end
    % Integrated (over sample of competitors) probability of winning:
    PV(i,:) = mean(PM,1);

end

clear 'xs' 'ys' 'z1' 'z2' 'samplelncdmall' 'samplerdmall' 'cond'
save('../calculations/Estimate_P.mat')