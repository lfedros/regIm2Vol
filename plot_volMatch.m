function plot_volMatch(volMatch,regPlane)

imgnonan = regPlane;
imgnonan(isnan(imgnonan)) = min(regPlane(:));
nonrigid = imfuse(mat2gray(volMatch),mat2gray(imgnonan),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

subplot(1,3,1)
imagesc(volMatch); axis image;colormap(1-gray);
formatAxes
title('Volume match')

subplot (1,3,2)
imagesc(imgnonan); axis image;colormap(1-gray);
formatAxes
title('Img registered')

subplot(1,3,3)
imshow(nonrigid); 
formatAxes


end



