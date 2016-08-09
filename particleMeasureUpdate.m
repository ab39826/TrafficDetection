function [curFilter] = particleMeasureUpdate(timeFilter, orderedCentroids)

%system model assumptions
global numParticles;
H = [1 0 0 0; 0 1 0 0];
R = 2;

prevStateEstimates = timeFilter(1).f;
prevParticleMatrix = timeFilter(2).f;
prevWeightMatrix = timeFilter(3).f;

curWeightMatrix = [];

 for i = 1:size(prevStateEstimates,2)
     
        %compute distances between particles and observation in order to
        %generate updated weights based on error
        curCentroidMatrix = repmat(flipud(orderedCentroids(i,:)'),1,numParticles);
        particleDistances = abs(curCentroidMatrix - H*prevParticleMatrix(:,:,i));
        particleDistanceVec = sqrt(sum(particleDistances.^2,1));
        particleWeights = (1/sqrt(2*pi*R)*exp(-1*particleDistanceVec/(2*R)));
        particleWeights = particleWeights./sum(particleWeights);
        curWeightMatrix(:,i) = particleWeights';
        
        
        %resample to form new particle matrix.
        prevParticles = prevParticleMatrix(:,:,i);
        curParticles = [];
        for p = 1:numParticles
           curParticles(:,p) =  prevParticles(:,find(rand <= cumsum(particleWeights),1));
        end
       
        
        %update the particle matrix and estimat
        curParticleMatrix(:,:,i) = curParticles;
        curStateEstimates(:,i) = mean(curParticles,2); 

        
 end

field = 'f';
value = {curStateEstimates; curParticleMatrix; curWeightMatrix};
curFilter = struct(field,value);
end