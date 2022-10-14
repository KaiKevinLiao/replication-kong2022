function [ bases ] = bernstein_bases_univariate( data, n )

% Given a column vector of data and degree of the univariate bernstein
% polynomial, forms the bernstein polynomial bases using the data.

for p = 0:n
     B(:,p+1) = nchoosek(n,p).*(data.^p).*((1-data).^(n-p));
end

bases = B; % size is length(data) x (n+1)

end

