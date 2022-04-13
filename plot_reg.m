function plot_reg(regStats)

figure('Color', 'w', 'Position',[179 512 560 360]);
imagesc(regStats.corr_score); hold on;
plot(regStats.best_ang_combo_id, regStats.best_frame,'*r')
xlabel('xyz rotation combo')
ylabel('Best match xcorr')
title(sprintf('Best rotation x:%0.1f, y:%0.1f; z:%0.1f',  regStats.best_ang_combo))
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
plot_volMatch(regStats.regMatch, regStats.regOps.mimg, regStats.volMatch, regStats.regPlane)
title(sprintf('Best %s match', regStats.regOps.type));