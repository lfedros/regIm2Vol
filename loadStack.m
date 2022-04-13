function info = loadStack(info, channel)
%% loads a pre-registered zstack
% INPUT:
% info: db struct with the following fields
% .subject    = 'FR140'; % animal name
% .date          = '2019-05-23'; % date of functional experiment
% .expts = [1 2 3 4 6 7 8];% which experiment were functional imaging;
% OUTPUTS
% info: loads a registered zstack


if nargin <2
    channel = 'all';
end
% root = 'D:\Data\2P';
% [Rfile, root] = uigetfile(fullfile(root, '*.tif'));
% Gfile = uigetfile(fullfile(root, '*.tif'));
% [Rfile2, root2] = uigetfile(fullfile(root, '*.tif'));
% Gfile2 = uigetfile(fullfile(root2, '*.tif'));
% R = img.loadFrames(fullfile(root, Rfile));
% rRange = range(R(:));
% R = single(mat2gray(R));
% G = img.loadFrames(fullfile(root, Gfile));
% gRange = range(G(:));
% G = single(mat2gray(G));

if exist(info.folderZStacks, 'dir')

    switch channel
        case 'R'
            stack_file_R = sprintf('%s_%d_%s_zStackMean_R.tif', info.date, info.expts, info.subject);

        case 'G'

            stack_file_G = sprintf('%s_%d_%s_zStackMean_G.tif', info.date, info.expts, info.subject);
        case 'all'

            stack_file_R = sprintf('%s_%d_%s_zStackMean_R.tif', info.date, info.expts, info.subject);
            stack_file_G = sprintf('%s_%d_%s_zStackMean_G.tif', info.date, info.expts, info.subject);


    end
end

if exist(fullfile(info.folderZStacks,stack_file_G))
    stack_G = loadFramesBuff(fullfile(info.folderZStacks,stack_file_G));
    % temporary fix as zstacks were trimmed the first 2 planes
    stack_G = cat(3, zeros(size(stack_G(:,:,1:2))), stack_G);
else
    stack_G = [];
end

if exist(fullfile(info.folderZStacks,stack_file_R))
    stack_R = loadFramesBuff(fullfile(info.folderZStacks,stack_file_R));
    % temporary fix as zstacks were trimmed the first 2 planes
    stack_R = cat(3, zeros(size(stack_R(:,:,1:2))), stack_R);
else
    stack_R = [];

end

info.stack_G = uint16([]);
info.stack_R = uint16([]);

for iPlane = 1: info.nPlanes

info.stack_G(:,:,iPlane) = imadjust(uint16(mat2gray(stack_G(:,:,iPlane))*65535));
info.stack_R(:,:,iPlane) = imadjust(uint16(mat2gray(stack_R(:,:,iPlane))*65535));

end

end