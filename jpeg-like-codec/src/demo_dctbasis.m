function demo_dctbasis
% (1) 8x8 DCT Basis Images
%
%  demo_dctbasis
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
N = 8;
C = gen_dctbasis(N);
B = gen_basisimages(C);
% plot
space = 2;
mini = min(min(min(min(B(:, :, :, :)))));
TILE = ones((N+space)*N, (N+space)*N) * mini;
for k = 0:N-1
    sk = k*(N+space)+1;
    for n = 0:N-1
        sn = n*(N+space)+1;
        TILE(sk:(sk+N-1), sn:(sn+N-1)) = B(:, :, k+1, n+1);
    end
end
imshow(TILE, 'DisplayRange', [min(min(TILE)) max(max(TILE))], ...
    'InitialMagnification', 300);
colorbar;
title('8x8 DCT basis images');
end

function B = gen_basisimages(C)
% Generate Basis Images associated with Input Basis Vectors
%
%  B = gen_basisimages(C)
%
% Input arguments ([]s are optional):
%  C  (matrix) of size NxN. Basis Vectors. Rows of C are orthonormal basis.
%
% Output arguments ([]s are optional):
%  B  (matrix) of size NxNx(NxN). Basis Images
%
% see also: gen_dctbasis, demo_dctbasis
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : March 2007
N = size(C, 1);
for n = 0:N-1
    for k = 0:N-1
        X = zeros(N, N);
        X(k+1, n+1) = 1;
        Y = C*X*C';
        B(:, :, k+1, n+1) = Y;
    end
end
end
