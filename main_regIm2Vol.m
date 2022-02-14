
clear;
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol');
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol\rigid');
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol\nonrigid');

%% expref of functional imaging planes

plane.subject    = 'FR143';
plane.date          = '2019-06-20'; % date of functional experiment
plane.expts = [1 3 4 5 6];% which experiment were functional imagingplane = getImgInfo(planes);

plane = populatePaths(plane);
plane = populateImgInfo(plane);

plane = loadMimgPlanes(plane);

%% expref of zstack volume

vol.subject = 'FR143';
vol.date = '2019-07-03';
vol.expts = [14];

vol = populatePaths(vol);
vol = populateImgInfo(vol);

%load
volG  = loadStack(vol, 'G');
volR  = loadStack(vol, 'R');

%remove flyback and wobbly planes
volG = trimBadPlanes(volG);
volR = trimBadPlanes(volR);

%% select the desired plane and channel

iPlane = 4;
target_plane.img = plane.mimgG(:,:,iPlane);
target_plane.micronsY = plane.micronsY;
target_plane.micronsX = plane.micronsX;
target_plane.micronsZ = plane.micronsZ(:,iPlane);

%% select desired stack channel
ref_vol = volG; 

%% find best match
% to do: add function that applies same transform to red channel

q.x_theta =[-3:3]; % angles in degrees
q.y_theta =[0]; % angles in degrees
q.z_theta =[0]; % angles in degrees
q.regType = 'nonrigid';
[regStats, q_vol] = regIm2Vol_dev(ref_vol, target_plane, q);


