function vol = trimBadPlanes(vol)
%% identifies and removes flyback and unstable/wobbly planes from a structural zstack
% INPUTS 
% vol is a struct containing a registered zstack and associated metadata
% OUTPUT
% vol same as input

wobble = range(vol.micronsZ, 1); 

wobblyPlanes = smooth(wobble> vol.planeSpacing*2, 3)>0;

vol.wobblyPlanes = wobblyPlanes;

if isfield(vol, 'stack_G')
vol.stack_G =vol.stack_G(:,:,~wobblyPlanes);
end
if isfield(vol, 'stack_R')
vol.stack_R =vol.stack_R(:,:,~wobblyPlanes);
end

vol.micronsZ= vol.micronsZ(:, ~wobblyPlanes);

vol.zMicronsPerPlane = vol.zMicronsPerPlane(~wobblyPlanes);
vol.nPlanes = sum(~wobblyPlanes);
end