function cutoffIndex = segmentBackground(pixWeight)
accWeight = 0;
cutoffIndex = 1;
global T;

while (accWeight < T && cutoffIndex<size(pixWeight,2))
   accWeight = accWeight + pixWeight(1,cutoffIndex);
   cutoffIndex = cutoffIndex + 1;
end

end