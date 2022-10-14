% For each lease, obtain predictions from leave-one-out local quadratic 
% regressions of bid residuals on geographic coordinates of the lease
% township(s)

cd(fileparts(mfilename('fullpath')))
tic
%% Import Data
clear; clc;
D = csvread('../calculations/Heatmap_township_tracts_bids.csv',1,0);
id = D(:,1); 
y = D(:,2);
x = D(:,3);
lnbonuspad_res = D(:,4);
royalty_res = D(:,5);
numbids = D(:,6);
year = D(:,7);

% Obtain vector of unique id's
uniqid = unique(id);
L = length(uniqid);

%% Fit surface
C = cell(L);
% Next, exclude own-auction bids and find fit value.
parfor j = 1:L % Loop through tracts
 
    i = uniqid(j);
    yeari = mode(year(id==i)); % There is only one year associated with each id
    % Leave own-auction bids out of surface fitting : "leave one out"
    % Only use auctions in years up to auctionyear
    use = id~=i & year<=yeari;
    xfit = x(use);
    yfit = y(use);
    lnbfit = lnbonuspad_res(use);
    rfit = royalty_res(use);
    
    % Local quadratic regression
    fitlqr_lnb = fit( [xfit, yfit], lnbfit, 'loess' );
    fitlqr_r = fit( [xfit, yfit], rfit, 'loess' );
    % Find fit value for rows with id==i
    put = id==i;    
    s1 = fitlqr_lnb(x(put),y(put));
    s2 = fitlqr_r(x(put),y(put));

    C{j} = [s1 s2];

end

%%
% Append all tracts
surffit = C{1};
for i = 2:L % Loop through tracts
    surffit = [surffit; C{i}];
end

% csvwrite data
M = [id y x surffit];
csvwrite('../calculations/Heatmap_time.csv',M)
toc