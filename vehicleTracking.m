%model- struct that contains
%[centroid, labelIndex, structKalmanModel]

%centroids- center pixel locations of large connected component regions
%labelVector - associated ids (should persist and remain consistent between frames)

%strucFilterModel:
%all necessary components to perform prediction and update step of kalamn filter algorithm:
%eg: F, H, Kpi, P, etc.

%or alternatively a particle filter model


function [curModel orderedCentroids] =  vehicleTracking(curCentroids, prevModel)

%pseudoCode
prevLabelVector = prevModel(1).f;
prevFilter = prevModel(2).f;

%performs prediction and udpate steps for filter (can be replaced by
%particle filter here as well
[predictedCentroids timeFilter] = kalmanTimeUpdate(prevFilter);

[curLabelVector orderedCentroids] = centroidMatching(predictedCentroids, prevLabelVector, curCentroids);

curFilter = kalmanMeasureUpdate(timeFilter, orderedCentroids);

field = 'f';
curValue = {curLabelVector, curFilter};
curModel = struct(field, curValue);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prevLabelVector = prevModel(1).f;
% prevFilter = prevModel(2).f;
% 
% H = [1 0 0 0; 0 1 0 0];
% 
% predictedCentroids = H*(prevFilter(1).f);
% 
% %performs prediction and udpate steps for filter (can be replaced by
% %particle filter here as well
% %[predictedCentroids timeFilter] = kalmanTimeUpdate(prevFilter);
% 
% [curLabelVector orderedCentroids distanceRound] = centroidMatching(predictedCentroids, prevLabelVector, curCentroids);
% 
% curStateEstimates = prevFilter(1).f;
% curStateEstimates(1:2,:) = flipud(curCentroids');
% curErrorCovariances = prevFilter(2).f;
% 
% field = 'f';
% value = {curStateEstimates; curErrorCovariances};
% curFilter = struct(field,value);
% 
% curValue = {curLabelVector, curFilter};
% curModel = struct(field, curValue);

end