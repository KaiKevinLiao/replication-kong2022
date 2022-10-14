function [x] = x_black( a,theta1,theta2,F,sigma,t )
% Compute x as defined in equation (2).

    S = F.*(1-a).*theta1;
    
    x = ( log(S./theta2) + (sigma.^2).*t./2 )./(sigma.*sqrt(t));

end

