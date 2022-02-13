function q = populateVolCoordinates (vol, q)

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


end