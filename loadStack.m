function info = loadStack(info, channel)

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
info.stack_G = loadFramesBuff(fullfile(info.folderZStacks,stack_file_G));
% temporary fix as zstacks were trimmed the first 2 planes
info.stack_G = cat(3, zeros(size(info.stack_G(:,:,1:2))), info.stack_G);
else
   info.stack_G = []; 
end

if exist(fullfile(info.folderZStacks,stack_file_R))
info.stack_R = loadFramesBuff(fullfile(info.folderZStacks,stack_file_R));
% temporary fix as zstacks were trimmed the first 2 planes
info.stack_R = cat(3, zeros(size(info.stack_R(:,:,1:2))), info.stack_R);
else
       info.stack_R = []; 

end



end