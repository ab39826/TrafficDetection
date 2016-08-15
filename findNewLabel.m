function newLabel = findNewLabel(prevLabelVector)
labelSet = [ 1 2 3 4 5 6 7 8];

unusedNumbers = setdiff(labelSet, prevLabelVector);

if(size(unusedNumbers,2) == 0)
    %no more labels for tracking
    newLabel = 0;
else
    
newLabel = unusedNumbers(1);    
end

end