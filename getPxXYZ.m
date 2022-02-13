function [micronsX, micronsY, micronsZ, xMicronsPerPixel, yMicronsPerPixel,zMicronsPerPlane]...
    = getPxXYZ(info)

scanZoomFactor = info.scanZoomFactor;
scanLinesPerFrame = info.scanLinesPerFrame;
scanPixelsPerLine = info.scanPixelsPerLine;

if isfield(info, 'microID')
    [fovx, fovy] = ppbox.zoom2fov(scanZoomFactor, infoROI.microID, info.date);
else
    [fovx, fovy] = ppbox.zoom2fov(scanZoomFactor, [], info.date);
end


xMicronsPerPixel = fovx / scanPixelsPerLine;
yMicronsPerPixel = fovy / scanLinesPerFrame;

micronsX = squeeze((1:scanPixelsPerLine)*xMicronsPerPixel);
micronsY = squeeze((1:scanLinesPerFrame)*yMicronsPerPixel);


if info.nPlanes>1
    micronsZ = zeros(scanLinesPerFrame, info.nPlanes);
    % only do the calculation if the piezo was moving (monty-python imaging)
    try
        % first trying to load a local copy of Timeline
        load(fullfile(info.folderTLLocal, info.basenameTL));
    catch
        load(fullfile(info.folderTL, info.basenameTL));
    end
    
    nInputs=length(Timeline.hw.inputs);
    for iInput=1:nInputs
        if isequal(Timeline.hw.inputs(iInput).name, 'piezoPosition')
            indPosition=iInput;
        end
        if isequal(Timeline.hw.inputs(iInput).name, 'piezoCommand')
            indCommand=iInput;
        end
        if isequal(Timeline.hw.inputs(iInput).name, 'neuralFrames')
            indFrames=iInput;
        end
    end
    
    frameTTL = [0; diff(Timeline.rawDAQData(:, indFrames))];
    frame_start = find(frameTTL > mean(frameTTL));
    
% %     here comes a bit of cumbersome code, but it seems that it works ok
% %     deltas = [0; -diff(Timeline.rawDAQData(:, indCommand))];
% %   deltas = -diff2(Timeline.rawDAQData(:, indCommand));
% % deltas = Timeline.rawDAQData(:, indCommand);
% %     cycleStarts = (deltas>0.95*max(deltas));
    
cycleStarts =frame_start(1:info.nPlanes:end);

    % skip the first 5 cycles and then take ten cycles to average across
    nCycles = 10;
    nStart = 5;
   

% 
%     % skip the first 5 cycles and then take ten cycles to average across
%     nCycles = 10;
%     nStart = 5;
% %     [~, indices] = findpeaks(deltas, 'MinPeakHeight', max(deltas)*0.99);
% %     cycleStarts = zeros(size(deltas));
% %     cycleStarts(indices) = 1;
%     indices = find(cycleStarts, nStart + nCycles, 'first');
% 
%     if max(abs(diff(diff(indices(nStart+1:end)))))>1
%         % take only reliable sequence,
%         % if not reliable skip a few cycles and try again
%         nStart = nStart + 5;
%         indices = find(cycleStarts, nStart + nCycles, 'first');
%     end
%     % defining start and end of the nCycle segment
%     startFrame = indices(nStart);
%     endFrame = indices(end);

%     % defining start and end of the nCycle segment
    startFrame = cycleStarts(nStart);
    endFrame = cycleStarts(nStart+nCycles);

    % extracting the segment
    signal = Timeline.rawDAQData(startFrame:endFrame, indPosition);
    tAxis = Timeline.rawDAQTimestamps(startFrame:endFrame);
    nSamples = round(Timeline.hw.daqSampleRate/2);
    referenceVoltage = mean(Timeline.rawDAQData(1:nSamples, indPosition));
    % interpolating to fit the number of lines in the image
    nSamples = nCycles*info.nPlanes*scanLinesPerFrame+1;
    tInterpolated = linspace(tAxis(1), tAxis(end), nSamples);
    sInterpolated = interp1(tAxis, signal, tInterpolated);
    % averaging across cycles to get the mean cycles
    oneMeanCycle = mean(reshape(sInterpolated(1:end-1), info.nPlanes*scanLinesPerFrame, nCycles), 2);
    % extracting the bit that is corresponding the the plane of interest
    for iPlane = 1:info.nPlanes
    thisPlaneZ = oneMeanCycle((iPlane-1)*scanLinesPerFrame+1:iPlane*scanLinesPerFrame);
    
    % extracting the z coordinates of the ROI centres
        % the scaling factor is 40 um/Volt
        % the overall range is 10 Volts
     micronsZ(:, iPlane) = 40*(thisPlaneZ - referenceVoltage);
    end
else
    % nPlanes == 1, so piezo was not moving
     micronsZ = zeros(scanLinesPerFrame, info.nPlanes);
end
  zMicronsPerPlane = mean(micronsZ,1);
end


