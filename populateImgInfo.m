function info = populateImgInfo(info)

try
    try
        allTiffInfo = dir([info.folder2pLocal, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2pLocal, tiffName);
        [~, header]=loadFramesBuff(filename, 1, 1, 1);
    catch
        fprintf('Getting the tiff from the server (local tiffs do not exist)...\n');
        allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2p, tiffName);
        [~, header]= loadFramesBuff(filename, 1, 1, 1);
    end
    
    
    % getting some parameters from the header
    
    hh=header{1};
    
    str = hh(strfind(hh, 'scanZoomFactor = '):end);
    ind = strfind(str, 'SI');
    info.zoomFactor = str2double(str(18 : ind(1)-1));
    
    
    try
        verStr = ['SI.VERSION_MAJOR = ',char(39),'2018b',char(39)];
        
        if ~isempty(strfind(hh, verStr)) % For scanimage 2016b, SF
            str = hh(strfind(hh,'channelSave = '):end);
            ind = strfind(str, 'SI');
            ch = str2num(str(15 : ind(1)-1));
            info.nChannels = length(ch);
            
            fastZEnable = sscanf(hh(strfind(hh,'hFastZ.enable = '):end), 'hFastZ.enable = %s');
            fastZEnable = strcmp(fastZEnable,'true');
            fastZDiscardFlybackFrames = sscanf(hh(strfind(hh, 'hFastZ.discardFlybackFrames = '):end), 'hFastZ.discardFlybackFrames = %s');
            fastZDiscardFlybackFrames = strcmp(fastZDiscardFlybackFrames,'true');
            stackNumSlices = sscanf(hh(strfind(hh, 'hStackManager.numSlices = '):end), 'hStackManager.numSlices = %d');
            
            info.planeSpacing = sscanf(hh(strfind(hh, 'hStackManager.stackZStepSize = '):end), 'hStackManager.stackZStepSize = %d');

            info.nPlanes = 1;
            
            if fastZEnable
                info.nPlanes = stackNumSlices+fastZDiscardFlybackFrames;
            end
            
            
            
            
            str = hh(strfind(hh, 'linesPerFrame = '):end);
            ind = strfind(str, 'SI');
            info.scanLinesPerFrame = str2double(str(17 : ind(1)-1));
            str = hh(strfind(hh, 'pixelsPerLine = '):end);
            ind = strfind(str, 'SI');
            info.scanPixelsPerLine  = str2double(str(17 : ind(1)-1));
            str = hh(strfind(hh, 'scanZoomFactor = '):end);
            ind = strfind(str, 'SI');
            info.scanZoomFactor  = str2double(str(18 : ind(1)-1));
            info.zoomFactor  = str2double(str(18 : ind(1)-1));
            
        else
            
            str = hh(strfind(hh, 'channelsSave = '):end);
            ind = strfind(str, 'scanimage');
            ch = str2num(str(16 : ind(1)-1));
            info.nChannels = length(ch);
            
            fastZEnable = sscanf(hh(findstr(hh, 'fastZEnable = '):end), 'fastZEnable = %d');
            fastZDiscardFlybackFrames = sscanf(hh(findstr(hh, 'fastZDiscardFlybackFrames = '):end), 'fastZDiscardFlybackFrames = %d');
            if isempty(fastZDiscardFlybackFrames)
                fastZDiscardFlybackFrames = 0;
            end
            stackNumSlices = sscanf(hh(findstr(hh, 'stackNumSlices = '):end), 'stackNumSlices = %d');
            
            if fastZEnable
                info.nPlanes=stackNumSlices+fastZDiscardFlybackFrames;
                
            else
                fprintf('The fast scanning was disabled during this acquisition\n');
                info.nPlanes=1;
            end
            
            values = getVarFromHeader(hh, ...
                {'scanFramePeriod', 'scanZoomFactor', 'scanLinesPerFrame', 'scanPixelsPerLine'});
            %     scanFramePeriod = str2double(values{1});
            info.scanZoomFactor = str2double(values{2});
            info.zoomFactor = str2double(values{2});
            info.scanLinesPerFrame = str2double(values{3});
            info.scanPixelsPerLine = str2double(values{4});
            
        end
    catch
        info.nPlanes=1;
        info.nChannels = 1;
    end
    
    %temporary hack
    info.chData(1).color = 'green';
    if info.nChannels ==2
        info.chData(2).color = 'red';
    end
    
    [info.micronsX, info.micronsY, info.micronsZ, info.xMicronsPerPixel, info.yMicronsPerPixel, info.zMicronsPerPlane]...
    = getPxXYZ(info);
    


info.xRange = range(info.micronsX);
info.yRange = range(info.micronsY);
info.zRange = range(makeVec(info.zMicronsPerPlane(:,~info.wobblyPlanes)));

catch
    warning('NO IMAGING DATA FOUND, returning basic exp info')
end
end


function values = getVarFromHeader(str, fields)

% str is the header
% fields is a cell array of strings with variable names
% values is a cell array of corresponding values, they will be strings

ff = strsplit(str, {' = ', 'scanimage.SI4.'});
if ~iscell(fields)
    fields = cell(fields);
end
values = cell(size(fields));

for iField = 1:length(fields)
    ind = find(ismember(ff, fields{iField}));
    values{iField} = ff{ind+1};
end
end
