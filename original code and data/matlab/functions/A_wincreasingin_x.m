function [ output ] = A_wincreasingin_x( c, m, eg )
% Form a square matrix of the following form:
% for example, if cycle c=3 and multiple m=2, (eg=1)
% form a size (c*m) square matrix, i.e. a 6x6 matrix 
% [1 -1 0 0 0 0 ;
%  0 1 -1 0 0 0 ;
%  0 0 0 0 0 0 ;
%  0 0 0 1 -1 0 ;
%  0 0 0 0 1 -1 ;
%  0 0 0 0 0 0 ];
% In row r, element (r,r)=1 and element (r,r+1)=-1, and all the other
% elements are zero, with the exception of every 3rd row (hence a cycle of
% 3) which is all zeroes.
% This is used with fmincon, such that Ax <= b, with x being parameters of
% a multivariate Bernstein polynomial, implies the polynomial is weakly
% increasing in its first argument.

% c is for cycle
% m is for multiple of this cycle
% eg is for # of times the c x m is repeated

A = eye(c*(m*eg)) + [zeros( c*(m*eg)-1 ,1) -eye( c*(m*eg)-1 ) ; zeros(1,c*(m*eg))];
for i=1:m*eg
    A(i*c,:) = zeros(1,c*(m*eg));
end

output = A;

end

