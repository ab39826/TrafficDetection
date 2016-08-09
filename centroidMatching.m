%this function performs the linear assignment problem using the Hungarian
%algorithm in order to minimize cost of matching predicted centroids with
%current centroids

%cost is defined as distance between centroids.

function [nextLabelVector orderedCentroids] = centroidMatching(predictCentroids, prevLabelVector, currentCentroids)

%first construct matrix that shows corresponding distances

distanceMatrix = pdist2(fliplr(predictCentroids'),currentCentroids);

[matchVector cost] = hungarian(distanceMatrix);

matchMatrix = zeros(size(distanceMatrix));

for i = 1:size(distanceMatrix,2)
   currentCol =  matchMatrix(:,i);
   currentCol(matchVector(i)) = 1;
   matchMatrix(:,i) = currentCol;
end

%routine to return a vector of reordered centroids based on matchMatrix
%where row indexes correspond to predicted centroids and column indexes
%correspond to current measured centroids
idx = find(matchMatrix);
[r c] = ind2sub(size(matchMatrix),idx);
cmin = accumarray(r,c,[],@min);

orderedCentroids = currentCentroids(cmin,:);
nextLabelVector = prevLabelVector;

end