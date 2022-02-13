function dreg = nonRigidReg(ops,IMG)
%%
ops.dobidi=0;
ops.kriging=1;
ops.numBlocks = [5 5];
ops = buildRegOps(ops);
ops.planesToProcess=1;
%% find the mean frame after aligning a random subset
% check if there are tiffs in directory

[Ly, Lx, ~, ~] = size(IMG);
ops.Ly = Ly;
ops.Lx = Lx;

% split into subsets (for high scanning resolution recordings)
[xFOVs, ~] = get_xyFOVs(ops);

% from random frames get scaling factor (if uint16, scale by 2)
if ~isfield(ops, 'scaleTiff')
    if max(IMG(:)) > 2^15
        ops.scaleTiff = 2;
    else
        ops.scaleTiff = 1;
    end
end

% makes blocks (number = numBlocks) and masks for smoothing registration offsets across blocks
if ops.nonrigid
    ops = MakeBlocks(ops);
end
% for each plane: align chosen frames to average to generate target image
ops1{1} = nonrigidAlignIterative2(squeeze(IMG(:,:,:,:)), ops);

for i = 1
    for j = 1:size(xFOVs,2)
       
        ops1{i,j}.DS          = [];
        ops1{i,j}.CorrFrame   = [];
        ops1{i,j}.mimg1       = zeros(ops1{i,j}.Ly, ops1{i,j}.Lx);
        if ops.nonrigid
            ops1{i}.mimgB = cell(prod(ops.numBlocks),1);
            for ib = 1:ops.numBlocks(1)*ops.numBlocks(2)
                ops1{i}.mimgB{ib} = ops1{i}.mimg(ops1{i}.yBL{ib}, ops1{i}.xBL{ib});
            end
        end
    end
end
for i = 1:numel(ops1)
    ops1{i}.Nframes(1)     = 0;
end

[dsall, ~] = nonrigidOffsets(squeeze(IMG(:,:,:,:)), 1, 1, 1, ops, ops1);
xyValid = true(Ly,Lx);
[dreg, xyValid] = nonrigidMovie(squeeze(IMG(:,:,:,:)), ops, dsall, xyValid);

