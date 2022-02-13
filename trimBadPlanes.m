function vol = trimBadPlanes(vol)

%% identify flyback and wobbly planes

wobble = range(vol.micronsZ, 1); 

wobblyPlanes = smooth(wobble> vol.planeSpacing*2, 3)>0;

vol.wobblyPlanes = wobblyPlanes;

vol.stack =vol.stack(:,:,~wobblyPlanes);
vol.micronsZ= vol.micronsZ(:, ~wobblyPlanes);
vol.zMicronsPerPlane = vol.zMicronsPerPlane(~wobblyPlanes);
vol.nPlanes = sum(~wobblyPlanes);
end