function info = populatePaths(info)
%% populates the paths associated with an imaging experiment
% INPUT:
% info: db struct with the following fields
% .subject    = 'FR140'; % animal name
% .date          = '2019-05-23'; % date of functional experiment
% .expts = [1 2 3 4 6 7 8];% which experiment were functional imagingplane = getImgInfo(planes);
% OUTPUTS
% info: populate the input structure with paths to data


info.expRef  = dat.constructExpRef(info.subject,info.date, info.expts(1));

tmp=dat.expFilePath(info.expRef, '2p-raw');
[info.folder2p, info.basename2p, ~]=fileparts(tmp{2});
[info.folder2pLocal, ~, ~] = fileparts(tmp{1});
tmp=dat.expFilePath(info.expRef, 'timeline');
[info.folderTL, info.basenameTL, ~]=fileparts(tmp{2});
[info.folderTLLocal, ~, ~] = fileparts(tmp{1});

expStr =  sprintf('%d_', info.expts);
expStr = expStr(1:end-1);
info.folderProcessed=fullfile(getTmpFolder, info.subject, info.date, expStr);
info.folderZStacks=fullfile(getTmpFolder('zstack'), info.subject, info.date, expStr);

dataFolders = {'\\128.40.224.65\Subjects\', '\\znas.cortexlab.net\Subjects\', '\\zserver.cortexlab.net\Data\2P\', ...
    '\\zserver.cortexlab.net\Data\Subjects\', '\\zserver4.cortexlab.net\Data\2P\', '\\zserver.cortexlab.net\Data2\Subjects\', ...
    '\\zubjects.cortexlab.net\Subjects\', '\\zarchive.cortexlab.net\Data\Subjects\'};

for k = 1:length(dataFolders)
    folder = fullfile(dataFolders{k}, info.subject, info.date, num2str(info.expts(1)));
    if exist(folder, 'dir') ~= 0
        info.folder2p = folder;
        thisServer = dataFolders{k};
        break
    end
end

info.basename2p=sprintf('%s_%d_%s_2P', info.date, info.expts(1), info.subject);
if ~exist(info.folderTL, 'dir') || ~exist(fullfile(info.folderTL, info.basenameTL), 'file')% LFR added on 21.04.18 to handle old datasets sitting on zserver
    info.folderTL=fullfile('\\zserver.cortexlab.net\Data\ExpInfo', info.subject, info.date, num2str(info.expts(1)));
end
if ~exist(info.folderTL, 'dir')
    info.folderTL=fullfile(thisServer, info.subject, info.date, num2str(info.expts(1)));
end
info.basenameTL=sprintf('%s_%d_%s_Timeline', info.date, info.expts(1), info.subject);



end


function str = getTmpFolder(data_type)

% This location will be used to keep all the processed data of the ppbox
% package
% Make sure you have enough space for all the processed files there
% Do not use network drives, this will slow down the process. If you have
% SSD - use it, it will make things faster. The ppbox code tries to be
% memory-efficient (this is required for large datasets), which means it is
% writing to disk more than minimally needed.

if nargin == 0
    
    data_type = 'functional';
    
end

str = 'C:\Temp2p\';

[~, hostname] = system('hostname');
hostname = hostname(1:end-1);

switch hostname
    
    case 'zpike'
        switch data_type
            case 'functional'
                str = 'C:\Users\Federico\Documents\Data\2P';
            case 'zstack'
                str = 'C:\Users\Federico\Documents\Data\2P';
                
        end
    case 'zufolo'
        switch data_type
            
            case 'functional'
                str = 'D:\OneDrive - University College London\Data\2P';
            case 'zstack'
                str = 'E:\Data\zStacks';
        end
        
end



end