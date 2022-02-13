function info = loadMimgPlanes(info)


for iplane = 1:info.nPlanes
    try
        load([info.folderProcessed '\F' '_' info.subject '_' info.date '_plane' num2str(iplane) '_proc.mat'  ]);
    catch
        
        dat = load([info.folderProcessed '\F' '_' info.subject '_' info.date '_plane' num2str(iplane) '.mat'  ]);
    end
    
    info.mimgG(:,:,iplane) = dat.ops.mimg1;
    if isfield(dat.ops,'mimgRED')
        info.mimgR(:,:,iplane,1) = dat.ops.mimgRED;
    else
        info.mimgR = [];
    end
    
    
end

end