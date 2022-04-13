function info = loadMimgPlanes(info)
%% INPUT:
% info: db struct with the following fields
% .subject    = 'FR140'; % animal name
% .date          = '2019-05-23'; % date of functional experiment
% .expts = [1 2 3 4 6 7 8];% which experiment were functional imagingplane = getImgInfo(planes);
%% OUTPUTS
% info: loads the imaging planes for the specific imaging experiment
%%

for iplane = 1:info.nPlanes
    try
        load([info.folderProcessed '\F' '_' info.subject '_' info.date '_plane' num2str(iplane) '_proc.mat'  ]);
    catch
        
        dat = load([info.folderProcessed '\F' '_' info.subject '_' info.date '_plane' num2str(iplane) '.mat'  ]);
    end
    
    info.mimgG(:,:,iplane) = imadjust(uint16(mat2gray(dat.ops.mimg1)*65535));

    if isfield(dat.ops,'mimgRED')
        info.mimgR(:,:,iplane,1) =  imadjust(uint16(mat2gray(dat.ops.mimgRED)*65535));
    else
        info.mimgR = [];
    end
    
    
end

end