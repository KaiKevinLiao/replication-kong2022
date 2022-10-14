% Compute implied volatility using 3-month crude oil options

cd(fileparts(mfilename('fullpath')))

%% Import Data
D = csvread('../calculations/option_data_for_impliedvol_m3.csv',1,0);
    year = D(:,1);
    month = D(:,2);
    maturity = D(:,3);
    S = D(:,4); % strikeprice
    F = D(:,5); % 3-month futures price
    r = D(:,6); % risk-free interest rate
    V = D(:,7); % option value

%%
% Pre-define some terms that go into the Black (1976) commodity option pricing equation
t = maturity./12; % Convert months to years.
c1 = log(F./S)./sqrt(t);
c2 = sqrt(t)./2;
ert = exp(-r.*t);
n = length(V);

iv = NaN(n,1);
% Invert the Black (1976) commodity option pricing equation to back out the 
% expected volatility implied by the price of every traded call option.
parfor i = 1:n
    i
    funF = @(z) ert(i)*( F(i)*normcdf(c1(i)/z + c2(i)*z) - S(i)*normcdf(c1(i)/z - c2(i)*z) ) - V(i); % z is the volatility
    z0 = [10^-10,100]; % search range
    if funF(z0(1))*funF(z0(2)) > 0 % if there is no value within search range that satisfies the equation
        iv(i,1) = NaN;
    else
        iv(i,1) = fzero(funF,z0); % Solve for implied volatility
    end
end

%% Save
% csvwrite data
M = [year month maturity S F r V iv];
csvwrite('../calculations/impliedvol_m3.csv',M)
save('../calculations/impliedvol_m3.mat','year', 'month', 'maturity', 'S', 'F', 'r', 'V', 'iv')