%model- struct that contains
%[centroid, labelIndex, structKalmanModel]

%centroids- center pixel locations of large connected component regions
%labelVector - associated ids (should persist and remain consistent between frames)

%strucFilterModel:
%all necessary components to perform prediction and update step of kalamn filter algorithm:
%eg: F, H, Kpi, P, etc.

%or alternatively a particle filter model


function [curModel orderedCentroids] =  vehicleTrackingParticle(curCentroids, prevModel)

%pseudoCode
prevLabelVector = prevModel(1).f;
prevFilter = prevModel(2).f;

%performs prediction and udpate steps for filter (can be replaced by
%particle filter here as well
[predictedCentroids timeFilter] = particleTimeUpdate(prevFilter);

[curLabelVector orderedCentroids] = centroidMatching(predictedCentroids, prevLabelVector, curCentroids);

curFilter = particleMeasureUpdate(timeFilter, orderedCentroids);

field = 'f';
curValue = {curLabelVector, curFilter};
curModel = struct(field, curValue);
end