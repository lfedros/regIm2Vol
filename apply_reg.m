function regPlane = apply_reg(plane, regStats)

regOps = regStats.regOps;

switch regOps.type
    
    case 'rigid'
        
        
        regPlane = rigidRegFrames(plane,regOps, regStats.dv);
        
        valid = rigidreg_validPx(size(regPlane), regStats.dv);
        
        regPlane(~valid) =NaN;
        
    case 'nonrigid'
        
        
        [regPlane, Valid]= nonrigidRegFrames(plane, regOps.xyMask, regStats.dv);
        
        regPlane(~Valid) = NaN;
        
        
end

end