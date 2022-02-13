% computes registration offsets for data split into blocks
% loops over blocks and returns offsets dsall
function [dsall,ops] = nonrigidOffsets_LFR(data, ops)


nblocks = ops.numBlocks(1)*ops.numBlocks(2);
dsall = zeros(size(data,3), 2, nblocks);

indframes = 1:size(data,3);

ds = zeros(numel(indframes), 2, nblocks,'double');
Corr = zeros(numel(indframes), nblocks,'double');
mimg_all =ops.mimg;
for ib = 1:nblocks
    % collect ds
    ops.mimg = ops.mimgB{ib};
    if ops.kriging
        [ds(:,:,ib), Corr(:,ib)]  = ...
            regoffKriging(data(ops.yBL{ib},ops.xBL{ib},indframes),ops, 0);
    else
        [ds(:,:,ib), Corr(:,ib)]  = ...
            regoffLinear(data(ops.yBL{ib},ops.xBL{ib},indframes),ops,0);
    end
end

dsall(indframes,:,:)  = ds;
ops.DS          = ds;
ops.CorrFrame   = Corr;
ops.mimg = mimg_all; 