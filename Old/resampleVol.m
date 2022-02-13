function new_vol = resampleVol(vol, varargin)

% inputs need to be: grid vectors for the original stack
% grid vectors or scattered query coordinates

% assume the original stack z coordinate is constant for each plane
% so you can use gridded interpolation which is faster

if numel(varargin) ==1
    
    
    %
    %     % reslice the volume with flat planes with constant Z along X and Y
    %
    %     % new_X is 1 * nPx_X
    %     % new_Y is 1 * nPx_Y
    %     % new_Z is nPx_Y * nPx_Z
    %
    %     x_res = varargin{1}(1);
    %     y_res = varargin{1}(2);
    %     z_res = varargin{1}(3);
    %
    %     % new_X = linspace(vol.micronsX(1),vol.micronsX(end),round(vol.xRange/x_res));
    %     % new_Y = linspace(vol.micronsY(1),vol.micronsY(end),round(vol.xRange/y_res));
    %     % new_Z = linspace(vol.zMicronsPerPlane(1),vol.zMicronsPerPlane(end),round(vol.zRange/z_res));
    %
    %     new_X = vol.micronsX(1): x_res :vol.micronsX(end);
    %     new_Y = vol.micronsY(1): y_res :vol.micronsY(end);
    %     new_Z = vol.zMicronsPerPlane(1):z_res : vol.zMicronsPerPlane(end);
    %
    %
    %     gridded_q = true;
    % else
    %
    % reslice the volume with a curved or angled plane along Y, scanline
    % are assumed on the same Z.
    % varargin{1} is either x_res (scalar) or 1 * nPx_X
    % varargin{2} is either y_res (scalar) or 1 * nPx_Y
    % varargin{3} z_res (scalar)
    % varargin{4} is nPx_Y * nPx_Z, for curved or tilted planes
    
    if numel(varargin{1}>1)
        new_X = varargin{1};
        
    else
        x_res = varargin{1};
        new_X = vol.micronsX(1): x_res :vol.micronsX(end);
    end
    
    if numel(varargin{2}>1)
        new_Y = varargin{2};
        
    else
        y_res = varargin{2};
        new_Y = vol.micronsY(1): y_res :vol.micronsY(end);
    end
    
    z_res = varargin{3};
    new_Z = vol.zMicronsPerPlane(1):z_res : vol.zMicronsPerPlane(end);
    
    
    if numel(varargin>3)
        new_YZ = varargin{3}';
        new_YZ = new_YZ' + new_Z;
        gridded_q = false;
        
    else
        % when possible, use gridded interpolation for speed
        gridded_q = true;
        
    end
end


Fg = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.G));
Fr = griddedInterpolant( {vol.micronsY, vol.micronsX, vol.zMicronsPerPlane}, single(vol.R));

if gridded_q
    
    new_vol.G = Fg({new_Y, new_X, new_Z});
    new_vol.R = Fr({new_Y, new_X, new_Z});
    
    % Xv = repmat(vol.micronsX, [vol.scanLinesPerFrame,1, vol.nPlanes]);
    % Yv = repmat(vol.micronsY', [1, vol.scanPixelsPerLine, vol.nPlanes]);
    % Zv = repmat(reshape(vol.micronsZ,vol.scanPixelsPerLine, 1, vol.nPlanes), [1, vol.scanPixelsPerLine, 1]);
    % F = scatteredInterpolant(  Yv(:), Xv(:), Zv(:), double(vol.G(:)));
    % new_vol.G = F({new_Y, new_X, new_Z});
    % F = griddedInterpolant(  Yv, Xv, Zv, single(vol.R));
    % new_vol.R = F({new_Y, new_X, new_Z});
    
    
else
    
    Xq = repmat(new_X, [numel(new_Y),1, numel(new_Z)]);
    Yq = repmat(new_Y', [1, numel(new_X), numel(new_Z)]);
    %     Zq = repmat(reshape(new_Z, 1, 1, numel(new_Z)), [numel(new_X), numel(new_Y), 1]);
    Zq = repmat(reshape(new_YZ,numel(new_Y), 1, size(new_YZ,2)), [1, numel(new_X), 1]);
    
    new_vol.G = Fg(Yq(:), Xq(:), Zq(:));
    new_vol.G = reshape(new_vol.G, numel(new_Y), numel(new_X), size(new_YZ,2));
    new_vol.R = Fr(Yq(:), Xq(:), Zq(:));
    new_vol.R = reshape(new_vol.R, numel(new_Y), numel(new_X), size(new_YZ,2));
    
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