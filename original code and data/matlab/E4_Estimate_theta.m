% Estimate thetas for each bid - follows constructive identification
% argument in "Verification of Necessary Identification Condition for 
% Option Value" in proofs section of appendix

cd(fileparts(mfilename('fullpath')))
addpath('functions')
clear; clc;

% Load estimated probability of winning and derivatives
load('../calculations/Estimate_P.mat')
% define
sigma = iv; % Only available for year>=1987.
S = wtim_d;
    S(S==0) = NaN;
t = primaryterm;
ert = exp(-r_cc.*t);
Sert = S.*ert;

% Winning probability P
P = PV(:,1);
% derivative dP/droy
dPdroy = (PV(:,3)-PV(:,2))./(2*deltar);
% derivative dP/dcash
dPdc = (PV(:,5)-PV(:,4))./(2*deltac);
% derivative dc/droy
dcdroy = -dPdroy./dPdc;

% Compute C1.
C1 = -dcdroy./Sert;

% Compute C2
dcdP = 1./dPdc;
C2numer = totalcash + P.*dcdP;
C2denom = (1-roy).*Sert.*C1;
C2ratio = C2numer./C2denom;
C2 = 1-C2ratio;

%% Solve for x (defined in equation (2)) 
% according to "Verification of Necessary Identification Condition for 
% Option Value" in proofs section of appendix
sig2to2 = sigma.^2.*t./2; 
xl = -30;
xu = 100;
xsol = NaN(length(C2),1);
for i=1:length(C2)
    if isnan(sigma(i)) || C2ratio(i)>=1 % sigma available only 1987+
        xsol(i,1) = NaN; 
    else
        funF = @(x) exp(sig2to2(i)-sigma(i)*sqrt(t(i))*x)*normcdf(x-sigma(i)*sqrt(t(i)))/normcdf(x) - C2(i); % x should satisfy this equation
        x0 = [xl,xu];
        if funF(xl)<0
            xsol(i,1) = NaN;
        elseif funF(xu)>0
            xsol(i,1) = NaN;
        else
            xsol(i,1) = fzero(funF,x0);
        end
    end
end

%% Ex-ante predicted probability of development
pdrill = normcdf(xsol-sigma.*sqrt(t));

% x is not well identified if normcdf(x-sigma.*sqrt(t)) is close to 0 or 1.
ided = pdrill>0.01 & pdrill<0.99 & C2>0;

% Sample mean of pdrill
% (winning bids: accbid==1; exclude stateagency==1, for which 
% DNR system doesn't record income)
mean(pdrill(accbid==1 & ided==1 & stateagency==0))

% Ex-post observed Pr(development)
mean(develop(accbid==1 & ided==1 & stateagency==0))

%% Estimate thetas
theta1 = C1./normcdf(xsol);
theta2 = (1-roy).*S.*theta1./exp(sigma.*sqrt(t).*xsol - sig2to2);
thetaratinv = theta2./(S.*theta1);
theta1(ided==0) = NaN;
theta2(ided==0) = NaN;
theta21 = theta2./theta1;

%% Compute option value V given estimated thetas
V = ert.*((1-roy).*S.*theta1.*normcdf(xsol) - theta2.*pdrill);

%% Save results
Pwin = P;
results = [rowid theta1 theta2 theta21 pdrill ided Pwin V xsol];
csvwrite('../calculations/Estimate_theta.csv',results)

clear results fig funF diffrM diffcM drnM dcnM ornM oroyM PM
save('../calculations/Estimate_theta.mat')