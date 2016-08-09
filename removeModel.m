function updatedModel = removeModel(prevModel, centroids, height, width)

removeIndex = 1;
H = [1 0 0 0; 0 1 0 0];

%compute distance matrix based upon predicted Centroids and current
%centroids and remove model that has poorest fit

%now add updated model parameters to previous model

prevLabelVector = prevModel(1).f;
prevFilter = prevModel(2).f;

prevStateEstimates = prevFilter(1).f;
prevErrorCovariances = prevFilter(2).f;

if(size(centroids,1) == 0)
removeIndex =1;
else  
predictedCentroids = H*prevStateEstimates;

distanceMatrix = pdist2(fliplr(predictedCentroids'),centroids);
matchVector = zeros(size(predictedCentroids,2),1);

for i = 1:size(centroids,1)
    curCol = distanceMatrix(:,i);
    [minVal minIndex] = min(curCol);
    matchVector(minIndex) = 1;
end
[remVal removeIndex] = min(matchVector);        
end

%remove
prevLabelVector(removeIndex) = [];
prevStateEstimates(:,removeIndex) = [];
prevErrorCovariances(:,:,removeIndex) =[];


%format and pass updated Model outside function
field = 'f';
filterValue = {prevStateEstimates; prevErrorCovariances;};
curFilter = struct(field,filterValue);
modelValue = {prevLabelVector; curFilter};
updatedModel = struct(field,modelValue);
end