function [regStats, q] = regIm2Vol_dev(vol, plane, q)

%% initialise registration options
if nargin <3
    q = struct;
end


q = populateVolCoordinates(vol, q);

% necessary if plane is slanted (i.e. multiplane imaging with piezo)
q.yz_vec = interp1(plane.micronsY, plane.micronsZ, q.y_vec, 'makima')';

q.x_theta =getOr(q, 'x_theta', [-5:5]); % angles in degrees
q.y_theta =getOr(q, 'y_theta', [0]); % angles in degrees
q.z_theta =getOr(q, 'z_theta', [0]); % angles in degrees

q.regType = getOr(q, 'regType', 'rigid'); % angles in degrees
q.reg_ch = getOr(q, 'reg_ch', 'G');% registration channel

target_plane = resamplePlane(plane, q); % interpolate plane to zstack resolution

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
    
    q.z_vec = max(q0.z_vec(bestGuess)-20,0):min(q0.z_vec(bestGuess)+20, q0.z_vec(end));
    
else
    bestGuess = [];
    q.z_vec =  getOr(vol, 'zMicronsPerPlane', 1:size(vol.stack,3));
    
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
    this_q.stacks = resampleVol_dev(vol, this_q);
    
    [stats(iRot)] = regIm2Stack(this_q.stacks{1}, target_img, q.regType);
end
toc

corr_score = cat(2, stats(:).corr);

[~, best_ang_combo]= max(corr_score(:));

[best_frame, best_ang_combo] = ind2sub(size(corr_score), best_ang_combo);

best_x = q.x_theta_grid(best_ang_combo);
best_y = q.y_theta_grid(best_ang_combo);
best_z = q.z_theta_grid(best_ang_combo);

%% Assign outputs
regStats = stats(best_ang_combo);
q.x_theta = best_x;
q.y_theta = best_y;
q.z_theta = best_z;
q = resampleCoords(vol, q);
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
        regStats.regPlane_R = apply_reg(target_plane.img_R, regStats);
        
        if isfield(q, 'stacks_R')
            regStats.volMatch_R = q.stacks_R{1}(:,:,best_frame);
            
        end
    case 'R'
        regStats.volMatch_R = regStats.volMatch;        
        regStats.regPlane_R = regStats.regPlane;
        regStats.regPlane_G = apply_reg(target_plane.img_G, regStats);
        if isfield(q, 'stacks_G')
            regStats.volMatch_G = q.stacks_G{1}(:,:,best_frame);
        end
end
regStats.target_plane = target_plane;

% q.stack = stacks{best_ang_combo};
regStats.corr_score = corr_score;
regStats.best_frame =best_frame;
regStats.best_ang_combo_id = best_ang_combo;
regStats.best_ang_combo = [best_x, best_y, best_z];



[regStats.regX, regStats.regY, regStats.regZ] = plane2vol_coordMap(q, regStats);

%% plotting

figure('Color', 'w', 'Position',[179 512 560 360]);
imagesc(regStats.corr_score); hold on;
plot(regStats.best_ang_combo_id, regStats.best_frame,'*r')
xlabel('xyz rotation combo')
ylabel('Best match xcorr')
title(sprintf('Best rotation x:%0.1f, y:%0.1f; z:%0.1f',  best_x, best_y, best_z))
formatAxes

figure('Color', 'w', 'Position', [742 104 830 322]);
subplot(1,3,1)
imagesc(regStats.regX); axis image
formatAxes
title('X Im2Vol coordinate');

subplot(1,3,2)
imagesc(regStats.regY); axis image
formatAxes
title('Y Im2Vol coordinate');

subplot(1,3,3)
imagesc(regStats.regZ); axis image
formatAxes
title('Z Im2Vol coordinate');

figure('Color', 'w', 'Position', [742 512 830 360]);
plot_volMatch(regStats.volMatch, regStats.regPlane)
title(sprintf('Best %s match', q.regType));


end