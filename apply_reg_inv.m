function regPlane = apply_reg_inv(plane, regStats)

regOps = regStats.regOps;

switch regOps.type
    
    case 'rigid'
        
        
        regPlane = rigidRegFrames(plane,regOps, regStats.dv_inverse);
        
        valid = rigidreg_validPx(size(regPlane), regStats.dv_inverse);
        
        regPlane(~valid) =NaN;
        
    case 'nonrigid'
        
        
        [regPlane, Valid]= nonrigidRegFrames(plane, regOps.xyMask, regStats.dv_inverse);
        
        regPlane(~Valid) = NaN;
        
        
end

end