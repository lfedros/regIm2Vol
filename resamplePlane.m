function target_plane = resamplePlane(plane, q)

target_plane = plane;

if isfield(plane, 'img_G');
target_plane.img_G = interp2(plane.micronsY', plane.micronsX, single(plane.img_G), q.y_vec', q.x_vec, 'linear',0);
end

if isfield(plane, 'img_R');
target_plane.img_R = interp2(plane.micronsY', plane.micronsX, single(plane.img_R), q.y_vec', q.x_vec, 'linear',0);
end

target_plane.micronsX = q.x_vec;
target_plane.micronsY = q.y_vec;
target_plane.micronsZ = interp1(plane.micronsY, plane.micronsZ, q.y_vec);

% valid_x = q.x_vec <= max(target_plane.micronsX );
% valid_y = q.y_vec <= max(target_plane.micronsY );

% target_plane.micronsY = q.y_vec(valid_y);
% target_plane.micronsX = q.x_vec(valid_x);
% 
% target_plane.img = target_plane.img(valid_y, valid_x);

end