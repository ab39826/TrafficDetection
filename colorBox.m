%This function takes a processed foreground frame, and adds colorBoxes
%corresponding to tracked cars

%modulo 8 to correspond to color labels
%each color has a corresponding index

function trackFrame = colorBox(frame, curModel,centroids, height, width)
global colorBoxVector;
colorBoxSize = size(colorBoxVector(1).f,1);



labelVector = curModel(1).f;


if(size(centroids,1) ~= 0)
    
for k = 1:size(centroids,1)
    
       xlen = centroids(k,2)+colorBoxSize;
       ylen = centroids(k,1)+colorBoxSize;
       
       
       if((xlen < height) && (ylen < width))
          frame(centroids(k,2):centroids(k,2)+colorBoxSize-1,centroids(k,1):centroids(k,1)+colorBoxSize-1,:) = colorBoxVector(labelVector(k)).f; 
       end  
end

end

trackFrame = frame;
end