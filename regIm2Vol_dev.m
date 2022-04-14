function [regStats, q] = regIm2Vol_dev(vol, plane, q)
%% 3D registration of a imaging plane to a z-stack
% INPUTS
% vol: struct with fields: 
    % micronsX: 1×xPx (cols) vector px coordinates in microns
    % micronsY: 1×yPx  (rows/lines) vector px coordinates in microns
    % micronsZ: yPx×zPx vector of z-coordinate in microns of each imaging line 
    % xMicronsPerPixel: 1.2338 % microns/px resolution in x
    % yMicronsPerPixel: 1.2338 % microns/px resolution in y
    % zMicronsPerPlane: 1×zPx vector of z-coordinates in microns (average across lines)
    % stack_G: yPx×xPx×zPx int16 imaging data green channel
    % stack_R: yPx×xPx×zPx int16 imaging data green channel
    
% plane: struct with fields: 
    % img_G: yPx×xPx target imaging plane green channel (can be different size than the zstack dimensions)
    % img_R: yPx×xPx target imaging plane red channel
    % micronsY: 1×yPx  (rows/lines) vector px coordinates in microns
    % micronsX: 1×xPx (cols) vector px coordinates in microns
    % micronsZ: 1×zPx vector of z-coordinate in microns of each imaging line 
    
% q: struct containing query pars and registration options, including
    % x_theta: rotations angle(deg) to try around x axis (rows) 
    % y_theta: rotations angle(deg) to try around y axis (columns) 
    % z_theta: rotations angle(deg) to try around z axis (z dim) 
    % regType: registration type, either 'nonrigid'  or 'rigid' (default)
    % reg_ch: channel to use for registration, either 'G' (default) or 'R'

% OUTPUTS



%% initialise registration options
if nargin <3
    q = struct;
end

q = q; 

q = populateVolCoordinates(vol, q);

% necessary if plane is slanted (i.e. multiplane imaging with piezo)
q.yz_vec = interp1(plane.micronsY, plane.micronsZ, q.y_vec, 'makima')';

q.x_theta =getOr(q, 'x_theta', [-5:5]); % angles in degrees
q.y_theta =getOr(q, 'y_theta', [0]); % angles in degrees
q.z_theta =getOr(q, 'z_theta', [0]); % angles in degrees

q.regType = getOr(q, 'regType', 'rigid'); % angles in degrees
q.reg_ch = getOr(q, 'reg_ch', 'G');% registration channel

target_plane = resamplePlane(plane, q); % interpolate plane to zstack resolution

% vol.stack_G = imgaussfilt3(vol.stack_G, [q.x_res, q.y_res, q.z_res]/3);
% vol.stack_R = imgaussfilt3(vol.stack_R, [q.x_res, q.y_res, q.z_res]/3);

%% if needed, restrict z location based on first regpass

if numel(q.x_theta)*numel(q.y_theta)*numel(q.z_theta) >1
    
    q0 = q;
    
    q0.x_theta =[0]; % angles in degrees
    q0.y_theta =[0]; % angles in degrees
    q0.z_theta =[0]; % angles in degrees
    
    q0 = resampleCoords(vol, q0); % resample stack coordinates with default res (or provide desired one)
    
    q0.stack = resampleVol_dev(vol, q0);
    
    % interpolate plane to zstack res
    
    switch q0.reg_ch
        case 'G'
            [q0.stats] = regIm2Stack(q0.stack{1}, target_plane.img_G, q.regType, 0); % nonrigid takes ~3 times longer
        case 'R'
            [q0.stats] = regIm2Stack(q0.stack{1}, target_plane.img_R, q.regType, 0); % nonrigid takes ~3 times longer
            
    end
    bestGuess = q0.stats.bestFrame;
    
    % look at 20um above and below
%     q.z_vec = max(q0.z_vec(bestGuess)-20,0):q.z_res:min(q0.z_vec(bestGuess)+20, q0.z_vec(end));

    if bestGuess-round(20/q.z_res) >0
        top = q0.z_vec(bestGuess-round(20/q.z_res));
    else
        top = q0.z_vec(1);
    end

    if bestGuess+round(20/q.z_res) <= max(q0.z_vec)
        bot = q0.z_vec(bestGuess+round(20/q.z_res));
    else
        bot = q0.z_vec(end);
    end
    q.z_vec = top:q.z_res:bot;

else
    bestGuess = [];
    q.z_vec =  getOr(vol, 'zMicronsPerPlane', 1:numel(vol.zMicronsPerPlane)); % buggy check
    
end
%% find best match

[q.y_theta_grid, q.x_theta_grid, q.z_theta_grid] = ndgrid(q.y_theta, q.x_theta, q.z_theta);

nRots = numel(q.x_theta_grid);

switch q.reg_ch
    case 'G'
        target_img =  target_plane.img_G;
    case 'R'
        target_img =  target_plane.img_R;
end

tic
for iRot = 1:nRots
    this_q = q;
    this_q.x_theta = q.x_theta_grid(iRot);
    this_q.y_theta = q.y_theta_grid(iRot);
    this_q.z_theta = q.z_theta_grid(iRot);
    this_q = resampleCoords(vol, this_q);
    this_q.stacks = resampleVol_dev(vol, this_q); % you can add Fg to the inputs to make this faster
    
    [stats(iRot)] = regIm2Stack(this_q.stacks{1}, target_img, q.regType);
end
toc

corr_score = cat(2, stats(:).corr);

[~, best_ang_combo]= max(corr_score(:));

[best_frame, best_ang_combo] = ind2sub(size(corr_score), best_ang_combo);

best_x = q.x_theta_grid(best_ang_combo);
best_y = q.y_theta_grid(best_ang_combo);
best_z = q.z_theta_grid(best_ang_combo);
%%
% q_dwsmp = q; 
q.x_theta = best_x;
q.y_theta = best_y;
q.z_theta = best_z;
q = resampleCoords(vol, q);
[q.stacks, q.Fg] = resampleVol_dev(vol, q); % you can add Fg to the inputs to make this faster

regStats = stats(best_ang_combo);
regStats.target_plane = target_plane;

switch q.reg_ch
    case 'G'
        target_img =  target_plane.img_G;
    case 'R'
        target_img =  target_plane.img_R;
end

this_q = q;
if ~isempty(vol.stack_R)
    this_q.reg_ch = 'R';
    q.stacks_R = resampleVol_dev(vol, this_q);
end

if ~isempty(vol.stack_G)
    this_q.reg_ch = 'G';
    q.stacks_G = resampleVol_dev(vol, this_q);
end

switch q.reg_ch
    case 'G'
        regStats.volMatch_G = regStats.volMatch;
        regStats.regPlane_G = regStats.regPlane;
        regStats.regMatch_G = regStats.regMatch;

        regStats.regPlane_R = apply_reg_inv(target_plane.img_R, regStats);
        
        if isfield(q, 'stacks_R')
            regStats.volMatch_R = q.stacks_R{1}(:,:,best_frame);
            
        end
    case 'R'
        regStats.volMatch_R = regStats.volMatch;        
        regStats.regPlane_R = regStats.regPlane;
        regStats.regMatch_R = regStats.regMatch;

        regStats.regPlane_G = apply_reg_inv(target_plane.img_G, regStats);
        if isfield(q, 'stacks_G')
            regStats.volMatch_G = q.stacks_G{1}(:,:,best_frame);
        end
end


regStats.best_ang_combo = [best_x, best_y, best_z];
regStats.corr_score = corr_score;
regStats.best_frame =best_frame;
regStats.best_ang_combo_id = best_ang_combo;

% these are the maps of coordinate transforms in microns!
[regStats.regX_dwsmp, regStats.regY_dwsmp, regStats.regZ_dwsmp] = plane2vol_coordMap(q, regStats);
% [regStats.regX, regStats.regY, regStats.regZ] = plane2vol_coordMap(q, regStats);

% interpolate map transform to original plane resolution and pixel size
regStats.regX = interp2(target_plane.micronsY', target_plane.micronsX, regStats.regX_dwsmp, plane.micronsY', plane.micronsX, 'linear',NaN);
regStats.regY = interp2(target_plane.micronsY', target_plane.micronsX, regStats.regY_dwsmp, plane.micronsY', plane.micronsX, 'linear', NaN);
regStats.regZ = interp2(target_plane.micronsY', target_plane.micronsX, regStats.regZ_dwsmp, plane.micronsY', plane.micronsX, 'linear', NaN);

%% plotting

plot_reg(regStats);

regStats.reconstructed_plane = reshape(Fg(regStats.regY(:),regStats.regX(:),regStats.regZ(:)), size(plane.img_G));

% %check reconstructed plane from reg z-slice coordinates
% nonrigid = imfuse(mat2gray(regStats.reconstructed_plane),mat2gray(plane.img_G),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
% figure; imshow(nonrigid);

%% Assign outputs  (TO DO: re run the matching at original resolution!)


% q_out.x_res = median(diff(plane.micronsX));
% q_out.y_res = median(diff(plane.micronsY));
% q_out.z_res = q.z_res;
% q_out.z_vec = q.z_vec;

% q_out = populateVolCoordinates(vol, q_out);
% q_out.yz_vec = interp1(plane.micronsY, plane.micronsZ, q_out.y_vec, 'makima')';
% 
% q_out.x_theta = best_x;
% q_out.y_theta = best_y;
% q_out.z_theta = best_z;
% q_out = resampleCoords(vol, q_out);
% q_out.stacks = resampleVol_dev(vol, q_out);

% q_out.regType = getOr(q_out, 'regType', 'rigid'); % angles in degrees
% q_out.reg_ch = getOr(q_out, 'reg_ch', 'G');% registration channel
% target_plane = resamplePlane(plane, q_out); % interpolate plane to zstack resolution

% switch q_out.reg_ch
%     case 'G'
%         target_img =  target_plane.img_G;
%     case 'R'
%         target_img =  target_plane.img_R;
% end
% 
% regStats = regIm2Stack(q_out.stacks{1}(:,:, regStats_dwsmp.best_frame), target_img, q_out.regType,1);
% 
% corr_score = cat(2, regStats.corr);
% [~, best_frame] = max(corr_score);
% 
% 
% this_q = q_out;
% if ~isempty(vol.stack_R)
%     this_q.reg_ch = 'R';
%     q_out.stacks_R = resampleVol_dev(vol, this_q);
% end
% 
% if ~isempty(vol.stack_G)
%     this_q.reg_ch = 'G';
%     q_out.stacks_G = resampleVol_dev(vol, this_q);
% end
% 
% switch q_out.reg_ch
%     case 'G'
%         regStats.volMatch_G = regStats.volMatch;
%         regStats.regPlane_G = regStats.regPlane;
%         regStats.regMatch_G = regStats.regMatch;
% 
%         regStats.regPlane_R = apply_reg_inv(target_plane.img_R, regStats);
%         
%         if isfield(q_out, 'stacks_R')
%             regStats.volMatch_R = q_out.stacks_R{1}(:,:,best_frame);
%             
%         end
%     case 'R'
%         regStats.volMatch_R = regStats.volMatch;        
%         regStats.regPlane_R = regStats.regPlane;
%         regStats.regMatch_R = regStats.regMatch;
% 
%         regStats.regPlane_G = apply_reg_inv(target_plane.img_G, regStats);
%         if isfield(q_out, 'stacks_G')
%             regStats.volMatch_G = q_out.stacks_G{1}(:,:,best_frame);
%         end
% end
% regStats.target_plane = target_plane;
% 
% % q.stack = stacks{best_ang_combo};
% regStats.corr_score = corr_score;
% regStats.best_frame =best_frame;
% regStats.best_ang_combo_id = best_ang_combo;
% regStats.best_ang_combo = [best_x, best_y, best_z];
% 






end