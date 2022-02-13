function [regX, regY, regZ] = plane2vol_coordMap(q, stats)

X = q.X(:,:,stats.bestFrame);
Y = q.Y(:,:,stats.bestFrame);
Z = q.Z(:,:,stats.bestFrame);


switch stats.regOps.type
    
    case 'rigid'
        
        % need to make it return 'Valid' pixels
        regX = rigidRegFrames(X, stats.regOps, -stats.dv);
        Valid = rigidreg_validPx(size(X), -stats.dv);
        regX(~Valid) = NaN;
        
        regY = rigidRegFrames(Y, stats.regOps, -stats.dv);
        Valid = rigidreg_validPx(size(Y), -stats.dv);
        regY(~Valid) = NaN;
        
        regZ = rigidRegFrames(Z, stats.regOps, -stats.dv);
        Valid = rigidreg_validPx(size(Z), -stats.dv);
        regZ(~Valid) = NaN;
        
    case 'nonrigid'
        
        [regX, Valid]= nonrigidRegFrames(X, stats.regOps.xyMask, -stats.dv);
        regX(~Valid) = NaN;
        [regY, Valid]= nonrigidRegFrames(Y, stats.regOps.xyMask, -stats.dv);
        regY(~Valid) = NaN;
        
        [regZ, Valid]= nonrigidRegFrames(Z, stats.regOps.xyMask, -stats.dv);
        regZ(~Valid) = NaN;
        
end


end