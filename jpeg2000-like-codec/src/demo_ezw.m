function demo_ezw
% Demonstrate EZW coding 
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007

% Example of wavelet transform of an 8x8 image
% given by Shapiro's EZW paper
X=[ 63   -34    49    10     7    13   -12     7
   -31    23    14   -13     3     4     6    -1
    15    14     3   -12     5    -7     3     9
    -9    -7   -14     8     4    -2     3     2
    -5     9    -1    47     4     6    -2     2
     3     0    -3     2     3    -2     0     4
     2    -3     6    -4     3     6     3     6
     5    11     5     6     0     3    -4     4];
% Example of wavelet transform of an 8x8 image
% given by Usevitch's JPEG2000 paper
% X=[ 53   -22    21    -9    -1     8    -7     6
%     14   -12    13   -11    -1     0     2    -3
%     15    -8     9     7     2    -3     1    -2
%     34    -2    -6    10     6    -4     4    -5
%     -6     5    -1     1     1     3    -1     5
%      6     1     3     0    -2     2     6     0
%      4     2     1    -4    -1     0    -1     4
%      0    -2     7     5    -3     2    -2     3];
% EZW encoding
[N, T0, sigmaps, refmaps] = ezw(X, 1);
% display
for i=1:length(sigmaps)
    sigmaps{i}
end
for i=1:length(refmaps)
    refmaps{i}
end
% EZW decoding
decoded = iezw(N, T0, sigmaps, refmaps);
% display
X
decoded
disp('X - fix(decoded) = ');
disp(X - fix(decoded));