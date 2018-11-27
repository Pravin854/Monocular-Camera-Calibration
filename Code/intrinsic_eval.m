function y = intrinsic_eval()

images = imageSet(fullfile(toolboxdir('vision'),'visiondata',...
            'calibration','mono'));
imageFileNames = images.ImageLocation;
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
squareSizeInMM = 24;
worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMM);
I = readimage(images,1); 
imageSize = [size(I, 1),size(I, 2)];
params = estimateCameraParameters(imagePoints,worldPoints, ...
                                  'ImageSize',imageSize);
y = params;

end