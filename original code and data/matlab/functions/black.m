function [V] = black( a,theta1,theta2,F,sigma,t,r_cc )
% Compute lease (option) value given all inputs

    S = F.*(1-a).*theta1;
    
    x = ( log(S./theta2) + (sigma.^2).*t./2 )./(sigma.*sqrt(t));
    
    V = exp(-r_cc.*t).*( S.*normcdf(x) - theta2.*normcdf(x-sigma.*sqrt(t)) );

end

