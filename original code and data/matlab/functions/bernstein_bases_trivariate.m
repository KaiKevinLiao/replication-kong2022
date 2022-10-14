function [ bases ] = bernstein_bases_trivariate( x,y,z, nx,ny,nz )

% Given column vectors of data x,y,z and polynomial degrees nx,ny,nz, forms 
% trivariate bernstein polynomial bases using the data.

ss = length(x); % Length of y and z need to be the same.

Bx = bernstein_bases_univariate( x, nx ); % ss x nx+1
By = bernstein_bases_univariate( y, ny ); % ss x ny+1
Bz = bernstein_bases_univariate( z, nz ); % ss x nz+1
% Now form cross products of the x polynomial bases and y polynomial bases, 
% for each observation.
% Bxy: ss x nx+1 x ny+1
for i=1:ss
    Bxym(i,:,:) = Bx(i,:)'*By(i,:);
end
% Convert the cross-product matrices into vectors, basically stacking the
% columns of the matrix vertically. Size ss x (nx+1)(ny+1)
for i=1:ss
    Bxy(i,:) = reshape(Bxym(i,:,:),[],1);
end
% Now form cross products of the x*y polynomial bases and z polynomial
% bases, for each observation.
% ss x {nx+1)(ny+1) x (nz+1)
for i=1:ss
    Bxyzm(i,:,:) = Bxy(i,:)'*Bz(i,:);
end    
% Convert the cross-product matrices into vectors, basically stacking the
% columns of the matrix vertically. Size ss x (nx+1)(ny+1)(nz+1)
for i=1:ss
    Bxyz(i,:) = reshape(Bxyzm(i,:,:),[],1);
end

bases = Bxyz;

end

