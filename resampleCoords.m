function q = resampleCoords(vol, q)


%% gatehr coordinates of data

q.x_res = getOr(q, 'x_res' , 2);
q.y_res = getOr(q, 'y_res' , 2);
q.z_res = getOr(q, 'z_res' , 2);

q.x_vec = getOr(q, 'x_vec', []);
if isempty(q.x_vec)
    q.x_vec = vol.micronsX(1): q.x_res :vol.micronsX(end);
end
q.n_x = numel(q.x_vec);

q.y_vec = getOr(q, 'y_vec', []);
if isempty(q.y_vec)
    q.y_vec = vol.micronsY(1): q.y_res :vol.micronsY(end);
end
q.n_y = numel(q.y_vec);

q.z_vec = getOr(q, 'z_vec', []);
if isempty(q.z_vec)
    q.z_vec = vol.zMicronsPerPlane(1):q.z_res: vol.zMicronsPerPlane(end);
end
q.n_z = numel(q.z_vec);

q.yz_vec = getOr(q, 'yz_vec', []);
if isempty(q.yz_vec) && q.y_theta ==0  && q.x_theta ==0 && q.z_theta ==0
    
    % when possible, use gridded interpolation for speed
    q.gridded = true;
    
else
    q.gridded = false;
    if isempty(q.yz_vec)
        q.yz_vec = zeros(q.n_y, 1);
    else
        q.yz_vec = q.yz_vec-mean(q.yz_vec); % make sure its centered
    end
    q.YZ = q.yz_vec + q.z_vec;
    
    
end

%%
if ~q.gridded
    
    X = repmat(q.x_vec, [q.n_y, 1, q.n_z]);
    Y = repmat(q.y_vec', [1, q.n_x, q.n_z]);
    Z= repmat(reshape(q.YZ, q.n_y, 1, q.n_z), [1, q.n_x, 1]);
    
    % rotations
    
    %     q.rot_cx = mean(vol.micronsX);
    %     q.rot_cy = mean(vol.micronsY);
    %     q.rot_cz = mean(vol.zMicronsPerPlane);
    %
    q.rot_cx = mean(q.x_vec);
    q.rot_cy = mean(q.y_vec);
    q.rot_cz = mean(q.z_vec);
    
    C = single([Y(:)-q.rot_cy, X(:)- q.rot_cx, Z(:)-q.rot_cz]);
    
    q.X = [];
    q.Y = [];
    q.Z = [];
    
    [q.y_theta_grid, q.x_theta_grid, q.z_theta_grid] = ndgrid(q.y_theta, q.x_theta, q.z_theta);
    
    q.n_rot = numel(q.x_theta_grid);
    
    for ia = 1: numel(q.x_theta_grid)
        
        R = rotation_matrix(q.y_theta_grid(ia)*pi/180, q.x_theta_grid(ia)*pi/180, q.z_theta_grid(ia)*pi/180);
        rotC = R*C';
        rotC = rotC';
        
        q.Y = cat(1, q.Y, rotC(:, 1));
        q.X = cat(1, q.X, rotC(:, 2) );
        q.Z = cat(1, q.Z, rotC(:, 3));
        
    end
    
    q.X = reshape(q.X, q.n_y, q.n_x,q.n_z, q.n_rot) + q.rot_cx;
    q.Y = reshape(q.Y, q.n_y, q.n_x,q.n_z, q.n_rot) + q.rot_cy;
    q.Z = reshape(q.Z, q.n_y, q.n_x,q.n_z, q.n_rot)+ q.rot_cz;
    
else
    
    q.X = [];
    q.Y = [];
    q.Z =[];
    q.n_rot = 1;
end



end