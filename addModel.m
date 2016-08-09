function updatedModel = addModel(prevModel, centroids, height, width)


global deltaT;
maxVel = 500;

%helper function handles
insert = @(a, x, n)cat(2,  x(1:n), a, x(n+1:end));
insertCol = @(a, x, n)cat(2,  x(:,1:n), a, x(:,n+1:end));
insertMat = @(a, x, n)cat(3,  x(:,:,1:n), a, x(:,:,n+1:end));

%find centroid closest to edge of a frame
[lowCentroidVal lowCentroidIndex] = min(min(centroids,[],2));
highCentroids(:,2) = height-centroids(:,2);
highCentroids(:,1) = width-centroids(:,1);
[highCentroidVal highCentroidIndex] = min(min(highCentroids,[],2));

%compare and find the actual centroids that's closest to the frame
addIndex = 1;
if(highCentroidVal < lowCentroidVal)
   %stateVector initialization for bottom right region of frame
   
   heightDist = height - centroids(highCentroidIndex,2);
   widthDist = width - centroids(highCentroidIndex,1);
   
   if(heightDist<widthDist)
   initLoc = [centroids(highCentroidIndex,1); height];
   initVel = (centroids(highCentroidIndex,:)'-initLoc)/(deltaT);
   
   %adjustment for large velocity components
   if(sum(abs(initVel)>maxVel) > 0)
      initVel = [0;-maxVel];
      initLoc = centroids(highCentroidIndex,:)' -deltaT*initVel;
   end
   else
   initLoc = [width; centroids(highCentroidIndex,2)];
   initVel = (centroids(highCentroidIndex,:)'-initLoc)/(deltaT);
   
   %adjustment for large velocity components
   if(sum(abs(initVel)>maxVel) > 0)
      initVel = [-maxVel; 0];
      initLoc = centroids(highCentroidIndex,:)' -deltaT*initVel;
   end  
   end
   initStateVector = [initLoc;initVel];
   addIndex = highCentroidIndex;
else
    %stateVector initialization for top left region of frame
   
   if(centroids(lowCentroidIndex,2)<centroids(lowCentroidIndex,1))
   initLoc = [centroids(lowCentroidIndex,1); 0];
   initVel = ((centroids(lowCentroidIndex,:)'-initLoc)/(deltaT));
   
   %adjustment for large velocity components
   if(sum(abs(initVel)>maxVel) > 0)
      initVel = [0; maxVel];
      initLoc = centroids(lowCentroidIndex,:)' -deltaT*initVel;
   end  
   
   else
   initLoc = [0; centroids(lowCentroidIndex,2)];
   initVel = ((centroids(lowCentroidIndex,:)'-initLoc)/(deltaT)); 
   
      %adjustment for large velocity components
   if(sum(abs(initVel)>maxVel) > 0)
      initVel = [0; maxVel];
      initLoc = centroids(lowCentroidIndex,:)' -deltaT*initVel;
   end 
   
   end
   initStateVector = [initLoc;initVel];
   addIndex = lowCentroidIndex;
end

%now add updated model parameters to previous model
prevLabelVector = prevModel(1).f;
prevFilter = prevModel(2).f;

prevStateEstimates = prevFilter(1).f;
prevErrorCovariances = prevFilter(2).f;

%obtain unique new label from set of integers between 1 to 8.
newLabel = findNewLabel(prevLabelVector);


if(newLabel ~= 0)
%insert model parameters in correct locations
curLabelVector = insert(newLabel,prevLabelVector, addIndex-1);
curStateEstimates = insertCol(initStateVector, prevStateEstimates, addIndex-1);

if(isempty(prevErrorCovariances))
curErrorCovariances = eye(4);
else
curErrorCovariances = insertMat(eye(4), prevErrorCovariances, addIndex-1);    
end


%format and pass updated Model outside function
field = 'f';
filterValue = {curStateEstimates; curErrorCovariances;};
curFilter = struct(field,filterValue);
modelValue = {curLabelVector; curFilter};
updatedModel = struct(field,modelValue);
else
updatedModel = prevModel;
end

end