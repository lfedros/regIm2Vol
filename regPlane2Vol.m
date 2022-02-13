function q = regPlane2Vol(vol, plane, ops)

if nargin <3
    ops = struct;
end







% if no best guess is provided
ops.q0 = getOr(ops, 'q0', struct);

q.x_vec = getOr(ops.q0,'x_vec',[]);
q.x_res = getOr(ops.q0,'x_res',2);
q.y_vec = getOr(ops.q0,'y_vec',[]);
q.y_res = getOr(ops.q0,'y_res',2);

if isfield(ops.q0.stats, 'bestFrame')
    q.z_vec = max(ops.q0.z_vec(ops.q0.stats.bestFrame)-20,0):min(ops.q0.z_vec(ops.q0.stats.bestFrame)+20, ops.q0.z_vec(end));
else
    q.z_vec =  getOr(vol, 'zMicronsPerPlane', 1:size(vol.stack,3));
    
end

q.z_res = getOr(ops.q0, 'z_res', 1) ; %mean(diff(vol.zMicronsPerPlane))
% q.yz_vec = interp1(plane.micronsY, plane.micronsZ(:,2), plane.micronsY(1): q.y_res :plane.micronsY(end))';
q.yz_vec = getOr(ops.q0, 'yz_vec', []);

q.x_theta =getOr(ops, 'x_theta', [-5:5]); % angles in degrees
q.y_theta =getOr(ops, 'y_theta', [0]); % angles in degrees
q.z_theta =getOr(ops, 'z_theta', [0]); % angles in degrees

tic
q = resampleCoords(vol, q);
q.stacks = resampleVol_dev(vol, q);
toc %17s for 20 comb; 1min for 55comb; 202s for 100 combs. 315combs 1861s, almost fills up RAM

%%
tic
for iVol = 1:numel(q.stacks)
    [q.stats(iVol)] = regPlane2Stack(q.stacks{iVol}, plane, 'nonrigid');
end
toc %5s

corr_score = cat(2, q.stats(:).corr);

[~, best_ang_combo]= max(corr_score(:));

[best_frame, best_ang_combo] = ind2sub(size(corr_score), best_ang_combo);

%%

q = q(best_ang_combo);
q.stats = q.stats(best_ang_combo);
q.stack = q.stacks{best_ang_combo};
q.corr_score = corr_score;
q.best_frame =best_frame;
q.best_ang_combo = best_ang_combo;
%% plotting
figure; imagesc(q.corr_score); hold on; plot(q.best_ang_combo, q.best_frame,'or')

plot_volMatch(q.stats.volMatch, q.stats.regPlane)



end