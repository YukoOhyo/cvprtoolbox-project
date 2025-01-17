function decompress_block_ezw(file_in, img_out)
% Block-EZW Based Image Decompression
%
%  decompress_ezw_block(file_in, img_out)
%
% Input arguments ([]s are optional):
%  file_in (string): path to compressed file to be docompressed
%  img_out (string): path to decompressed image file
%
% Uses: iezw.m, ihuffman.m arith06.m, WaveUtilities/IWaveletTransform2D.m
%
% Author: Naotoshi Seo <sonots(at)umd.edu>
% Date  : April 2007
if nargin < 3,
    num_pass = Inf;
end

% read file
eval(sprintf('load %s -mat', file_in));
% N, T0, dc, len_arighmetic, arithmetic
% codewords_sigs codewords_refs pad_sigs pad_refs
% huffman_sigs huffman_refs M
%whos

% Initialization
X = zeros(N);
nCol = N; nRow = N;
T = T0;
scan = ezw_mortonorder(M);
num_pass = length(codewords_sigs);
nBlock = floor(N/M);
% decoding
for i=1:num_pass
    fprintf('pass %d ...\n', i);
    
    disp('Huffman decoding ...');
    tic;
%     for j=0:(floor(nCol/M)-1)
%         sj = j*M+1;
%         for k=0:(floor(nRow/M)-1)
%             sk = k*M+1;
%             sigmaps{i}{k+1}{j+1} = ihuffman(huffman_sigs{i}{k+1}{j+1},...
%                 codewords_sigs{i}{k+1}{j+1}, pad_sigs{i}{k+1}{j+1});
%             refmaps{i}{k+1}{j+1} = ihuffman(huffman_refs{i}{k+1}{j+1},...
%                 codewords_refs{i}{k+1}{j+1}, pad_refs{i}{k+1}{j+1});
%         end
%     end
    sigmapss{i} = ihuffman(huffman_sigs{i}, codewords_sigs{i}, pad_sigs{i});
    refmapss{i} = ihuffman(huffman_refs{i}, codewords_refs{i}, pad_refs{i});
    index = find(sigmapss{i} == uint8('d'));
    for l=0:length(index)-2
        k = mod(l, nBlock);
        j = floor(l / nBlock);
        sigmaps{i}{k+1}{j+1} = sigmapss{i}(index(l+1)+1:index(l+2)-1);
    end
    sigmaps{i}{nBlock}{nBlock} = sigmapss{i}(index(l+2)+1:end);
    index = find(refmapss{i} == 2);
    for l=0:length(index)-2
        k = mod(l, nBlock);
        j = floor(l / nBlock);
        refmaps{i}{k+1}{j+1} = refmapss{i}(index(l+1)+1:index(l+2)-1);
    end
    refmaps{i}{nBlock}{nBlock} = refmapss{i}(index(l+2)+1:end);
    toc
    
    disp('ezw_decoding ...');
    tic
    for j=0:(floor(nCol/M)-1)
        sj = j*M+1;
        for k=0:(floor(nRow/M)-1)
            sk = k*M+1;
            X(sk:(sk+M-1), sj:(sj+M-1)) = iezw_dominantpass(...
                X(sk:(sk+M-1), sj:(sj+M-1)), sigmaps{i}{k+1}{j+1}, T{k+1}{j+1}, scan);
            X(sk:(sk+M-1), sj:(sj+M-1)) = iezw_subordinatepass(...
                X(sk:(sk+M-1), sj:(sj+M-1)), refmaps{i}{k+1}{j+1}, T{k+1}{j+1}, scan);
        end
    end
    toc
    
    for j=0:(floor(nCol/M)-1)
        for k=0:(floor(nRow/M)-1)
            T{k+1}{j+1} = T{k+1}{j+1} / 2;
        end
    end

    % for testing
    eval(sprintf('save %s.%02dof%02d X -mat', file_in, i, num_pass));
end
% Inverse Wavelet
addpath matlabPyrTools/
addpath matlabPyrTools/MEX/
I = blkproc(X, [M M], 'invwave_transform_qmf(x,P1)', 5);

% add DC coponent
for j=0:(floor(nCol/M)-1)
    sj = j*M+1;
    for k=0:(floor(nRow/M)-1)
        sk = k*M+1;
        I(sk:(sk+M-1), sj:(sj+M-1)) = I(sk:(sk+M-1), sj:(sj+M-1)) + dc{k+1}{j+1};
    end
end
I = uint8(I);

% Save
imwrite(I, img_out);
end

