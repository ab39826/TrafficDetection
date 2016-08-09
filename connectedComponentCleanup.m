%function takes preliminary foreground video frame and cleans it up
%based on connected component threshold processing



function [cleanTrackFrame centroids] = connectedComponentCleanup(foreFrame)
grayFrame = rgb2gray(foreFrame);
grayFrame(grayFrame(:,:) == 1) = 0;
grayFrame(grayFrame(:,:) > 0) = 255;

global ccThreshold;
cleanFrame = bwareaopen(grayFrame,ccThreshold);
filledFrame = imfill(cleanFrame,'holes');

%calculate centroid positions within image
s = regionprops(filledFrame,'centroid');
centroids = cat(1, s.Centroid);
centroids = round(centroids);

filledCopyFrame = repmat(filledFrame,[1 1 3]);


%update initial foreground frame estimation
cleanTrackFrame = foreFrame;
cleanTrackFrame(filledCopyFrame == 0) = 1;

end