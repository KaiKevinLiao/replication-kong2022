function [b] = apvfpa(v,vs,vos)
% Compute FPA bid b(v) in 2 bidder auction given joint draws (v,vo) from F(v,vo).
% Theory is in Milgrom & Weber (1982).
% v should be a scalar; vs and vos vectors of equal length.

    vmin = min(vs);
    
    g = 200; % fineness of outer integration grid
    % Outer grid
    grid1 = [vmin+(v-vmin)./(2*g) : (v-vmin)./g : v-(v-vmin)./(2*g)];
    % Inner grid
    grid2 = [vmin+(v-vmin)./(4*g) : (v-vmin)./(2*g) : v-(v-vmin)./(4*g)];
    
    % Compute f_vo|v(s|s) and F_vo|v(s|s) for each point on grid2
        % grid2 in quantiles - used for purposes of conditioning
        g2q = ksdensity(vs(1:1000),grid2,'function','cdf'); % A random sample of 1000 is enough for computing quantile; affects speed.
        % vs in quantiles - used for purposes of conditioning
        vsq = ksdensity(vs(1:1000),vs,'function','cdf'); % A random sample of 1000 is enough for computing quantile; affects speed.
        % Loop through grid2 to compute fss/Fss
        foverFss = NaN(1,2*g);
        for i = 1:2*g
            cvos = vos(vsq>g2q(i)-0.005 & vsq<g2q(i)+0.005); % These are conditional draws from F(vo|v=s)
            fss = ksdensity(cvos,grid2(i),'function','pdf'); % f_vo|v(s|s)
            Fss = ksdensity(cvos,grid2(i),'function','cdf'); % F_vo|v(s|s)
            foverFss(i) = fss./Fss;
        end
    % Using fss/Fss, compute L(alpha|x) as defined in Thm14 of Milgrom&Weber(1982)
    % alpha are the points on grid1
        Lax = NaN(g,1);
        for i = 1:g
            % foverFss(grid2>grid1(i) & grid2<v) = Values of fss/Fss where s is in [alpha v].
            int = (v-grid1(i)).*mean(foverFss(grid2>grid1(i) & grid2<v));
            Lax(i) = exp(-int);
        end
    % b(v) = v - int_to_v_of L(alpha|x)dalpha.
    b = v - (v-vmin).*mean(Lax);
end

