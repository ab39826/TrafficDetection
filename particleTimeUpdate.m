function [predictedCentroids curFilter] = particleTimeUpdate(prevFilter)
%system model assumptions
global deltaT;
global numParticles;
global height;
global width;
H = [1 0 0 0; 0 1 0 0];
F = [1 0 deltaT 0; 0 1 0 deltaT; 0 0 1 0; 0 0 0 1];
Q = [5 0 0 0; 0 5 0 0; 0 0 2 0; 0 0 0 2];

prevStateEstimates = prevFilter(1).f;
prevParticleMatrix = prevFilter(2).f;
prevWeightMatrix = prevFilter(3).f;


for i = 1:size(prevStateEstimates,2)
predictedParticles = F*prevParticleMatrix(:,:,i) + sqrt(Q)*randn(4,numParticles);

curParticlesLocs = predictedParticles(1:2,:);
curParticlesLocs(predictedParticles(1:2,:)<0) = 0;
curParticleXLoc = curParticlesLocs(1,:);
curParticleYLoc = curParticlesLocs(2,:);


%make sure all are valid locations
curParticleXLoc(predictedParticles(1,:)>width) = width;
curParticleYLoc(predictedParticles(2,:)>height) = height;
predictedParticles(1:2,:) = [curParticleXLoc;curParticleYLoc];

predictedParticleMatrix(:,:,i) = predictedParticles;


%now generate predictedStateEstimates as the mean of each corresponding
%particle filter
predictedStateEstimates(:,i) = mean(predictedParticles,2);    
end




field = 'f';
value = {predictedStateEstimates; predictedParticleMatrix; prevWeightMatrix};
curFilter = struct(field,value);
predictedCentroids = H*predictedStateEstimates;


end
