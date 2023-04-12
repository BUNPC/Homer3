function xy = convert_optodepos_to_circlular_2D_pos(pos, T, norm_factor)
pos = [pos ones(size(pos,1),1)];
pos_unit_sphere = pos*T;
pos_unit_sphere_norm = sqrt(sum(pos_unit_sphere.^2,2));
pos_unit_sphere = pos_unit_sphere./pos_unit_sphere_norm ;

[azimuth,elevation, ~] = cart2sph(pos_unit_sphere(:,1),pos_unit_sphere(:,2),pos_unit_sphere(:,3));
elevation = pi/2-elevation;
[x,y] = pol2cart(azimuth,elevation);      % get plane coordinates
xy = [x y];
xy = xy/norm_factor;               % set maximum to unit length
end


