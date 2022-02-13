function valid = rigidreg_validPx(img_sz, ds)

sz_x = img_sz(2);
sz_y = img_sz(1); 

rx = max(max(ds(:,2), 0));
lx = -min(min(ds(:,2),0));

dy = max(max(ds(:,1), 0));
uy = -min(min(ds(:,1), 0));

valid_x = lx+1:sz_x-rx;
valid_y = uy+1:sz_y-dy;

valid = zeros(img_sz);

valid(valid_y, valid_x) = 1;




end