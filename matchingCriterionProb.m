%computes distributions for which a match exists with current pixel
%based on Mahalanobis distance
function match = matchingCriterionProb(pixMean,pixVar,pixel, pixWeight)     
K = size(pixMean,3);
match = 0;
global matchThres;
bestD = 0;

beta = 1;

totalProbMeasure = 0;
probCompVec = zeros(K,1);
for k = 1:K
    pixVarMatrix = eye(3)/pixVar(k);
    D = sqrt((pixel - pixMean(:,:,k))'*pixVarMatrix*(pixel-pixMean(:,:,k)));
	probMeasure = (1/sqrt(((2*pi)^3)*(pixVar(k)^3)))*exp((-.5)*D);
    totalProbMeasure = totalProbMeasure + pixWeight(k) * probMeasure;
	
	probCompParameter = pixMean(:,:,k) + beta*ones(3,1)*pixVar(k);
	probCompD = sqrt((probCompParameter)'*pixVarMatrix*(probCompParameter));
	probCompVec(k) = (1/sqrt(((2*pi)^3)*(pixVar(k)^3)))*exp((-.5)*probCompD);
       
end

for k = 1:K
if(totalProbMeasure > probCompVec(k))
match = k;
end
end