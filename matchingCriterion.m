%computes distributions for which a match exists with current pixel
%based on Mahalanobis distance

function match = matchingCriterion(pixMean,pixVar,pixel)     
K = size(pixMean,3);
match = 0;
global matchThres;
bestD = 0;


for k = 1:K
    pixVarMatrix = eye(3)/pixVar(k);
    D = sqrt((pixel - pixMean(:,:,k))'*pixVarMatrix*(pixel-pixMean(:,:,k)));
    
    if (D < matchThres)
        %implies a match was found
        if(D>bestD)
            %find best match
            bestD = D;
            match = k;
        end
    end
    
end


end
    