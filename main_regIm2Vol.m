
clear;
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol');
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol\rigid');
addpath('C:\Users\Federico\Documents\GitHub\regIm2Vol\nonrigid');
addpath(genpath('C:\Users\Federico\Documents\GitHub\Rigbox'));
addpath('C:\Users\Federico\Documents\GitHub\Suite2P_Matlab\tiffTools\');
addpath('C:\Users\Federico\Documents\GitHub\Suite2P_Matlab\registration\');
addpath(genpath('C:\Users\Federico\Documents\GitHub\FedBox'));
addpath('C:\Users\Federico\Documents\GitHub\Suite2P_Matlab\utils')
%% expref of functional imaging planes

plane.subject    = 'FR143';
plane.date          = '2019-06-20'; % date of functional experiment
plane.expts = [1 3 4 5 6];% which experiment were functional imaging plane = getImgInfo(planes);

% plane.subject    = 'FR140';
% plane.date          = '2019-05-23'; % date of functional experiment
% plane.expts = [1 2 3 4 6 7 8];% which experiment were functional imagingplane = getImgInfo(planes);


plane = populatePaths(plane);
plane = populateImgInfo(plane);
plane = loadMimgPlanes(plane);

%% expref of zstack volume

vol.subject = 'FR143';
vol.date = '2019-07-03';
vol.expts = [14];

% vol.subject = 'FR140';
% vol.date = '2019-05-30';
% vol.expts = [15];

vol = populatePaths(vol);
vol = populateImgInfo(vol);

%load
vol  = loadStack(vol);

%remove flyback and wobbly planes
vol = trimBadPlanes(vol);

%% select the desired plane and channel

iPlane = 2;
target_plane.img_G = plane.mimgG(:,:,iPlane);
target_plane.img_R = plane.mimgR(:,:,iPlane);
target_plane.micronsY = plane.micronsY;
target_plane.micronsX = plane.micronsX;
target_plane.micronsZ = plane.micronsZ(:,iPlane);

%% find best match
% to do: add function that applies same transform to red channel
% add function that saves results 

q.x_theta =[-3:3]; % angles in degrees
q.y_theta =[0]; % angles in degrees
q.z_theta =[0]; % angles in degrees
q.regType = 'nonrigid';
q.reg_ch = 'G'; % register the green channel
[regStats, q_vol] = regIm2Vol_dev(vol, target_plane, q);


