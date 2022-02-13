function plot_volMatch(volMatch,regPlane)

nonrigid = imfuse(mat2gray(volMatch),mat2gray(regPlane),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

figure('Color', 'w'); 

subplot(1,3,3)
imshow(nonrigid); 

subplot(1,3,1)
imagesc(volMatch); axis image;colormap(1-gray);

subplot (1,3,2)
imagesc(regPlane); axis image;colormap(1-gray);
end



