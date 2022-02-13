function info = loadStack(info, channel)


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
    stack_file = sprintf('%s_%d_%s_zStackMean_R.tif', info.date, info.expts, info.subject);
            case 'G'

    stack_file = sprintf('%s_%d_%s_zStackMean_G.tif', info.date, info.expts, info.subject);
    end
end

info.stack = loadFramesBuff(fullfile(info.folderZStacks,stack_file));

% temporary fix as zstacks were trimmed the first 2 planes

info.stack = cat(3, zeros(size(info.stack(:,:,1:2))), info.stack);




end