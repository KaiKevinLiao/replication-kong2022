% Simulate counterfactual quasi-linear scoring auctions.
% s = b + w*S*(-1/a^power), where w and power are parameters.
% American option valuation

cd(fileparts(mfilename('fullpath')))
addpath('functions')

%% Load necessary data and estimates
clear; clc;
% For an apples-to-apples comparison with other auction mechanisms, use the
% same auctions to compute revenue.

load('../calculations/Fixed_royalty_SPA_am.mat')
winner_zeroroy = frspawinner(:,1); % winner of zero-royalty auction
clearvars -except winner_zeroroy

load('../calculations/Fixed_royalty_values_am.mat')
ss = size(T,1);

%% Specify grid of scoring rule parameters over which to compute outcomes.
%**********************************************
% Power of function of royalty, (-1/a^power)
powergrid = [1:1:15];
% Weight on royalty component
wgrid = [0.01:0.01:1]'; % This will be rescaled depending on power.
%**********************************************
% Meshgrid
temp = wgrid*[14 2 0.4 0.08 0.025 0.005 2*10^-3 8*10^-4 2*10^-4 6*10^-5 2*10^-5 5*10^-6 10^-6 3*10^-7 2*10^-7]; % Rescaling wgrid, based on preliminary assessments
w = reshape(temp,[],1);
power = reshape( repmat(powergrid,length(wgrid),1),[],1 );

%% Simulate scoring auction, looping over scoring rule parameters.
% Options for fmincon, used below to compute royalty choice in scoring auction:
startval = 0.25;
lb = 0.125;
ub = 0.99;
options = optimset('MaxFunEvals',1e10);
options = optimoptions('fmincon','Display','off');

% Objects to be saved from loop over scoring rule parameters.
    rchoice_qls = NaN(ss,length(w));
    bpaid_qls = NaN(ss,length(w));
    won_qls = NaN(ss,length(w));
    comparenan = NaN(length(w),1);
    qls_ave_cpad = NaN(length(w),1);
    qls_ave_gvalpad = NaN(length(w),1);
    qls_totalgvalpad = NaN(length(w),1);
    qls_ave_bvalpad = NaN(length(w),1);
    qls_social_surplus = NaN(length(w),1);
    qls_sameallo = NaN(length(w),1);
    qls_ave_pdrill = NaN(length(w),1);

% Loop over scoring rule parameters
for j = 1:length(w)

%%  Compute the scoring auction    
    % 1. Compute bidders choice of royalty given scoring rule
    rchoice = NaN(ss,1);
    parfor i=1:ss
        if ~isnan(T.theta_am1(i))
            % Maximize V(a,theta_am)+w*S*(-1/a^power) in interval a=[lb,ub]
            rchoice(i) = fmincon(@(a) -(w(j).*T.S(i).*(-1./(a.^power(j))) + american_value(T.S(i)*(1-a)*T.theta_am1(i), T.theta_am2(i), T.r_cc(i), T.sigma(i), T.t(i), steps)), ...
                startval,[],[],[],[],lb,ub,[],options);
        end
    end
    % 2. Compute the cash b that bidders will bid in a second-score auction
    % = value of option evaluated at royalty = rchoice
    bbid = NaN(ss,1);
    parfor i=1:ss    
        if ~isnan(T.theta_am1(i))
            bbid(i) = american_value(T.S(i)*(1-rchoice(i))*T.theta_am1(i), T.theta_am2(i), T.r_cc(i), T.sigma(i), T.t(i), steps);            
        end
    end
        
    % 3. Compute the score of the bid (rchoice, bbid)
    score = bbid + w(j).*T.S.*(-1./(rchoice.^power(j)));
    
    % 4. Identify winner. Recall N=2, and consecutive rows belong to same
    % auction.
    score_byauction = [score([1:2:ss-1]) score([2:2:ss])]; % each row is an auction
        % If one bidder of an auction shows NaN, discard whole auction
        score_byauction(isnan(score_byauction(:,1)),2) = NaN;
        score_byauction(isnan(score_byauction(:,2)),1) = NaN;
        % Collected in one column:
        score_withnan = reshape(score_byauction.',[],1);
    % Winner is the one with higher score
    bidder1wins = score_byauction(:,1) > score_byauction(:,2);
    winnerid = bidder1wins.*1 + (1-bidder1wins).*2;
    % Construct logical vector indicating whether a row contains winner
    won = zeros(ss,1);
    won([0:2:ss-2]' + winnerid) = 1;
    
    % 5. Cash actually paid by bidder in a second-score auction
    % Vector of losing scores by auction
    score2nd = reshape( repmat( score_withnan(logical(1-won))',2,1 ), [],1);
    % Winner chooses b to fulfill second score
    bpaid = score2nd - w(j).*T.S.*(-1./(rchoice.^power(j)));
    bpaid(isnan(score_withnan)) = NaN; % If any score in the auction is NaN, fill in NaN.
    
    % Compare NaN in bpaid versus 1-use
    comparenan(j) = sum(isnan(bpaid)-(1-use)); % Checked in detail. "use" is a subset of isnan(bpaid)==0.
    
    %% Evaluate the scoring auction
    % cash revenue per acre
    qls_ave_cpad(j) = mean(bpaid(won==1 & use==1));
    % Ex-ante value of royalties to government
    gvalpad = NaN(ss,1);
    for k = 1:ss
        gvalpad(k) = american_gval( T.S(k), rchoice(k), T.theta_am1(k), T.theta_am2(k), T.r_cc(k), T.sigma(k), T.t(k), steps );
    end
    qls_ave_gvalpad(j) = mean(gvalpad(won==1 & use==1));
    % Total to gov
    qls_totalgvalpad(j) = qls_ave_cpad(j) + qls_ave_gvalpad(j);
    % Average lease value to winner
    bvalpad = bbid;
    qls_ave_bvalpad(j) = mean(bvalpad(won==1 & use==1));
    % Social surplus
    qls_social_surplus(j) = qls_ave_gvalpad(j) + qls_ave_bvalpad(j);
    % Allocation relative to 0% case
    sameallo = won==winner_zeroroy;
    qls_sameallo(j) = mean(sameallo(won==1 & use==1));
    % Probability of exercise
    qls_pdrill = NaN(ss,1);
    for k = 1:ss
        qls_pdrill(k) = american_probex( T.S(k)*(1-rchoice(k))*T.theta_am1(k), T.theta_am2(k), T.r_cc(k), T.sigma(k), T.t(k), steps );
    end
    qls_ave_pdrill(j) = mean(qls_pdrill(won==1 & ~isnan(qls_pdrill) & T.stateagency==0));

    % Save bid components to matrix
    rchoice_qls(:,j) = rchoice;
    bpaid_qls(:,j) = bpaid;
    won_qls(:,j) = won;
j
end

% Save
save('../calculations/Quasi_linear_scoring_am.mat','powergrid','w','power','rchoice_qls', 'bpaid_qls', 'won_qls', 'comparenan', ...
    'qls_ave_cpad', 'qls_ave_gvalpad', 'qls_totalgvalpad', 'qls_ave_bvalpad', 'qls_social_surplus', 'qls_sameallo', 'qls_ave_pdrill')