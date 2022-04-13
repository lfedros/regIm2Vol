function stats = regIm2Stack (vol, plane, regType, doPlot)
%% finds the plane in vol that best registers to plane, and registers the plane to it
% INPUTS
% vol
% plane
% regType either 'rigid' (default) or 'non-rigid'
% doPlot logical, whether you want a summary plot or not (default)
% OUTPUTS
% stats struct of registration pars with fields
%     dv: (inverse) registration shifts required to align plane to volMatch 
%     bestFrame: id of the frame of vol with higher reg correlation with target
%     volMatch: bestFrame match from vol 
%     regPlane: target plane aligned to volMatch (by inverse of registration)
%     regOps: struct with registration options
%     corr: registration correlation between volMatch and target plane

if nargin <4
    doPlot = false;
end

if nargin <3
    regOps.type = 'rigid';
else
    regOps.type = regType;
end

% regOps.targetFrame = plane;
% regOps.useGPU = true;
% regOps.subPixel = 1;
% regOps.phaseCorrelation = true;
% regOps.maxregshift = 50;
% regOps.kriging = 1;
% [regOps.Ly, regOps.Lx, ~]  = size(vol);

vol(isnan(vol(:))) = 0;

switch regOps.type
    
    case 'rigid'
        
        regOps = build_rigidops(plane);

        [stats.dv, stats.corr] = phaseCorrKriging(vol, regOps);
        
        [~, stats.bestFrame] = max(stats.corr);
        
        stats.volMatch = vol(:,:,stats.bestFrame);
        
        stats.dv = stats.dv(stats.bestFrame, :);

        stats.regMatch= rigidRegFrames(stats.volMatch, regOps.xyMask, stats.dv);

        Valid = rigidreg_validPx(size(stats.regMatch), stats.dv);

        stats.regMatch(~Valid) = NaN;

        regOps_inv = build_rigidops(stats.volMatch);

        stats.dv_inverse = phaseCorrKriging(plane, regOps_inv);

        regPlane = rigidRegFrames(regOps.targetFrame,regOps, stats.dv_inverse);

        Valid = rigidreg_validPx(size(regPlane), stats.dv_inverse);

        regPlane(~Valid) = NaN;

       
    case 'nonrigid'
        
        regOps = build_nonrigidops(plane);
        
        [dsall,regOps] = nonrigidOffsets_LFR(vol, regOps);
        
        stats.corr = mean(regOps.CorrFrame,2);
        
        [~, stats.bestFrame] = max(mean(regOps.CorrFrame,2));
        
        stats.dv = dsall(stats.bestFrame,:,:);

        stats.volMatch = vol(:,:,stats.bestFrame);

        [stats.regMatch, Valid]= nonrigidRegFrames(stats.volMatch, regOps.xyMask, stats.dv);
        
        stats.regMatch(~Valid) = NaN;


        regOps_inv = build_nonrigidops(stats.volMatch);

        [stats.dv_inverse, regOps_inv] = nonrigidOffsets_LFR(plane, regOps_inv);

        [regPlane, Valid]= nonrigidRegFrames(plane, regOps_inv.xyMask, stats.dv_inverse);

        regPlane(~Valid) = NaN;

end

stats.regPlane = regPlane;

stats.regOps = regOps;

stats.regOps_inv = regOps_inv;


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