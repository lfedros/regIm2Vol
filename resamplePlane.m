function target_plane = resamplePlane(plane, q)

target_plane = plane;

target_plane.img = interp2(plane.micronsY', plane.micronsX, plane.img, q.y_vec', q.x_vec);
target_plane.micronsY = q.y_vec;
target_plane.micronsX = q.x_vec;

end