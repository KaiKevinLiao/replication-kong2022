function [ output ] = A_wincreasingin_y( c, m, eg )
% Form a matrix as follows:
% for example, if cycle c=3, multiple m=2, (eg=1),
% [1 0 0 -1 0 0 ;
%  0 1 0 0 -1 0 ;
%  0 0 1 0 0 -1 ];
% This is used with fmincon, such that Ax <= b, with x being parameters of
% a multivariate Bernstein polynomial, implies the polynomial is weakly
% increasing in its second argument.

% c is for cycle
% m is for multiple of this cycle
% eg is for # of times the c x m is repeated

A2 = zeros( c*m*eg-c , c*(m*eg) );
for j=1:eg
    for i = (j-1)*c*m+1 : j*c*m-c
        A2(i,i)=1;
        A2(i,i+c)=-1;
    end
end

output = A2;

end

