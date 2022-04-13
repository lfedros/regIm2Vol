function plot_volMatch(regMatch, plane, volMatch,regPlane)

imgnonan = regPlane;
imgnonan(isnan(imgnonan)) = min(regPlane(:));
nonrigid = imfuse(mat2gray(volMatch),mat2gray(imgnonan),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

subplot(2,3,1)
imagesc(volMatch); axis image;colormap(1-gray);
formatAxes
title('Volume match')

subplot (2,3,2)
imagesc(imgnonan); axis image;colormap(1-gray);
formatAxes
title('Img registered')

subplot(2,3,3)
imshow(nonrigid); 
formatAxes


imgnonan = regMatch;
imgnonan(isnan(imgnonan)) = min(regMatch(:));
nonrigid = imfuse(mat2gray(imgnonan),mat2gray(plane),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);


subplot(2,3,4)
imagesc(imgnonan); axis image;colormap(1-gray);
formatAxes
title('Volume reg match')

subplot (2,3,5)
imagesc(plane); axis image;colormap(1-gray);
formatAxes
title('Target Img')

subplot(2,3,6)
imshow(nonrigid); 
formatAxes


end



