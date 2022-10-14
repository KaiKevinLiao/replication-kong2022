function [obj] = focs_am( theta,F,roy,r_cc,sigma,t,steps,deltar,rhs1,rhs2 )
% Objective function for best satisfying 2 FOCs using American option value
% computed via binomial tree.
% theta should be a vector of length 2.
    
    % V : american option, binomial tree
    V = american_value( F.*(1-roy).*theta(1), theta(2), r_cc, sigma, t, steps);
    
    % dV/da - numerical derivative of V wrt a
    rup = roy + deltar;
    rdown = roy - deltar;
    Vaup = american_value( F.*(1-rup).*theta(1), theta(2), r_cc, sigma, t, steps);
    Vadown = american_value( F.*(1-rdown).*theta(1), theta(2), r_cc, sigma, t, steps);
    dVda = (Vaup - Vadown)./(2*deltar);
    
    % Satisfy the 2 FOCs:
    obj = (dVda-rhs1).^2 + (V-rhs2).^2;
    
end

