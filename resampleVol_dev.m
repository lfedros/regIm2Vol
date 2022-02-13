function q_vol = resampleVol_dev(vol, q)

% inputs need to be: grid vectors for the original stack
% grid vectors or scattered query coordinates

% assume the original stack z coordinate is constant for each plane
% so you can use gridded interpolation which is faster


Fg = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.stack), 'linear', 'none');
% Fr = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.R), 'linear', 'none');

if q.gridded
    
    q_vol{1} = Fg({q.y_vec, q.x_vec, q.z_vec});
%     q_vol.R = Fr({q.y_vec, q.x_vec, q.z_vec});
    
    
else
   
    for iRot = 1:q.n_rot
        
        Yq = q.Y(:,:,:,iRot);
        Xq = q.X(:,:,:,iRot);
        Zq = q.Z(:,:,:,iRot);

    q_vol{iRot} = Fg(Yq(:), Xq(:), Zq(:));
    q_vol{iRot} = reshape(q_vol{iRot}, q.n_y, q.n_x, q.n_z);
%     q_vol.R{iRot} = Fr(Yq(:), Xq(:), Zq(:));
%     q_vol.R{iRot} = reshape(q_vol.R{iRot}, q.n_y, q.n_x, q.n_z);
    end
end



%use ndgrid+griddedInterpolant
% [Xq, Yq, Zq] = ndgrid(new_X, new_Y, new_Z);
% [Xv, Yv, Zv] = ndgrid(vol.micronsY, vol.micronsX,  vol.zMicronsPerPlane);
%
% new_vol.G = interpn( Yv, Xv,Zv, single(vol.G),Yq, Xq,  Zq);
% new_vol.R = interpn(Yv, Xv,  Zv, single(vol.R),Yq, Xq,  Zq);
%OR
% F = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.G));
% new_vol.G = F({new_Y, new_X, new_Z});
% F = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.R));
% new_vol.R = F({new_Y, new_X, new_Z});


end