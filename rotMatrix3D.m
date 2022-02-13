function Rxyz = rotMatrix3D(x_theta, y_theta, z_theta)

Rx = [1 0 0; 0 cosd(x_theta) -sind(x_theta); 0 sind(x_theta) cosd(x_theta)];

Ry = [cosd(y_theta) 0 sind(y_theta); 0 1 0; -sind(y_theta) 0 cosd(y_theta)];

Rz = [cosd(z_theta) -sin(z_theta) 0; sind(z_theta) cosd(z_theta) 0; 0 0 1];

Rxyz = Rz*Ry*Rx;

end