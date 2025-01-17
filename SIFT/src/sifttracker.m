function [U, V] = sifttracker(im_names, distRatio)
% [U, V] = sifttracker(im_names)
%
% Point Tracker using SIFT features
%
% Input Arguments ([]s are optional):
%   im_names (cell array of strings): input image file names
%   distRatio (scalar) [0-1]:
%     Only keep matches in which the ratio of vector angles from the
%     nearest to second nearest neighbor is less than distRatio.
% Output Arguments ([]s are optional):
%   U (matrix) of size FxP where F is # of frames (images) and P is # of
%   tracking points: horizontal coordinates of tracking points
%   V (matrix) of size FxP where F is # of frames (images) and P is # of
%   tracking points: vertical coordinates of tracking points
%
% Example:
%  im_names = {'scene.pgm','book.pgm'};
%  [U, V] = tracker(im_names);
%
% Date: May 2007
% Author: Naotoshi Seo <sonots(at)umd.edu>
if ~exist('distRatio', 'var')
    distRatio = 0.6;
end
[im1 pos1 scale1 ori1 des1] = SIFT_cache(im_names{1});
P = size(pos1, 1);
F = length(im_names);
U(1, :) = pos1(:, 1)';
V(1, :) = pos1(:, 2)';
idx1 = 1:P;
for f = 2:F
    [im2 pos2 scale2 ori2 des2] = SIFT_cache(im_names{f});

    % Start: copy from match.m

    % For each descriptor in the first image, select its match to second image.
    des2t = des2';                          % Precompute matrix transpose
    for i = 1 : size(des1,1)
        dotprods = des1(i,:) * des2t;        % Computes vector of dot products
        [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

        % Check if nearest neighbor has angle less than distRatio times 2nd.
        if (vals(1) < distRatio * vals(2))
            match(i) = indx(1); % match(id1) = id2;
        else
            match(i) = 0;
        end
    end
    % End of Copy
    fprintf('%d points were matched with previous image.\n', sum(match > 0));
    match(length(match)+1:P) = 0;

    % Sequential correspoinding points
    idx2 = zeros(1, P);
    idx2(idx1 > 0) = match(idx1(idx1 > 0));
    U(f, :) = ones(1, P) * -1;
    V(f, :) = ones(1, P) * -1;
    U(f, idx2 > 0) = pos2(idx2(idx2 > 0), 1)';
    V(f, idx2 > 0) = pos2(idx2(idx2 > 0), 2)';
    fprintf('%d points were remained to track.\n', sum(U(f, :) > -1));
    des1 = des2; pos1 = pos2; idx1 = idx2;
end
