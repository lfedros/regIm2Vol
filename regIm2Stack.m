function stats = regIm2Stack (vol, plane, regType, doPlot)

if nargin <4
    doPlot = false;
end

if nargin <3
    regOps.type = 'rigid';
else
    regOps.type = regType;
end

regOps.targetFrame = plane;
regOps.useGPU = true;
regOps.subPixel = 1;
regOps.phaseCorrelation = true;
regOps.maxregshift = 50;
regOps.kriging = 1;
[regOps.Ly, regOps.Lx, ~]  = size(vol);

vol(isnan(vol(:))) = 0;

switch regOps.type
    
    case 'rigid'
        
        
        [stats.dv, stats.corr] = phaseCorrKriging(vol, regOps);
        
        [~, stats.bestFrame] = max(stats.corr);
        
        stats.volMatch = vol(:,:,stats.bestFrame);
        
        stats.dv = -stats.dv(stats.bestFrame, :); 
        
        regPlane = rigidRegFrames(regOps.targetFrame,regOps, stats.dv);
        
        valid = rigidreg_validPx(size(regPlane), stats.dv);
        
        regPlane(~valid) =NaN;
        
    case 'nonrigid'
        
        regOps = build_nonrigidops(regOps.targetFrame);
        
        [dsall,regOps] = nonrigidOffsets_LFR(vol, regOps);
        
        stats.corr = mean(regOps.CorrFrame,2);
        
        [~, stats.bestFrame] = max(mean(regOps.CorrFrame,2));
        
        [regPlane, Valid]= nonrigidRegFrames(plane, regOps.xyMask, -dsall(stats.bestFrame,:,:));
        
        regPlane(~Valid) = NaN;
        
        stats.dv = -dsall(stats.bestFrame,:,:);
        
        stats.volMatch = vol(:,:,stats.bestFrame);
        
end

stats.regPlane = regPlane;

stats.regOps = regOps;

if doPlot
    
    
    C = imfuse(stats.volMatch,regPlane,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    figure;
    
    subplot(1,3,3)
    imshow(C);
    
    subplot(1,3,1)
    imagesc(stats.volMatch); axis image
    
    subplot(1,3,2)
    imagesc(regPlane); axis image
    
    
end

end