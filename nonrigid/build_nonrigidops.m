function ops = build_nonrigidops(target)

ops.type = 'nonrigid';
ops.mimg = target;
ops.useGPU = true;
ops.subPixel = 1;
ops.phaseCorrelation = true;
ops.maxregshift = 50;
ops.kriging = 1;

[ops.Ly, ops.Lx] = size(ops.mimg);
ops.numBlocks = [5 5];
ops = MakeBlocks(ops);
ops.kriging = 1;
for ib = 1:ops.numBlocks(1)*ops.numBlocks(2)
    ops.mimgB{ib} = ops.mimg(ops.yBL{ib}, ops.xBL{ib});
end
end