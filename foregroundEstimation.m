function foregroundEstimation(movie)

%Load video into memory and prepare output video for writing

v = VideoReader(movie);
numFrames = 410;
foregroundVideo = VideoWriter('foreground.avi');
open(foregroundVideo);

%video constants

initFrame = read(v,1);
global height;
global width;
height = size(initFrame,1); 
width = size(initFrame,2);



%initialize GMM parameters: (based upon Stauffer notation)
%http://www.ai.mit.edu/projects/vsam/Publications/stauffer_cvpr98_track.pdf

% alpha = learning constant
%K= #of guassians in the mixture
% T = min. portion of background
% initVariance = initial variance
% pixelThresh = threshold condition for computing adaptive process on pixel

alpha=0.05;
K=5;
global T;
T=0.8;

global initVariance;
initVariance=75;
pixelThresh=45;
referenceDistance = 40; %shortcut to speed up processing time. Compare current pixel to pixel referenceDistance frames back and skip adaptive process if similar. Downside is doesn't collect background evidence as well.
sideWeight = (K-1)/(1-T);
global matchThres;
matchThres = sqrt(3);
global ccThreshold;
ccThreshold = 5000;
global deltaT;
deltaT = 1;
global numParticles;
numParticles = 100;

trackingOn = 0; % will superimpose tracking color marker on detected vehicles in output video. tackingOn should equal 1 or 0

prevCentSize = 0;


%structures to pass information between frames for detection purposes.
field = 'f';
filterValue = {[];[];};
prevFilter = struct(field,filterValue);
modelValue = {[];prevFilter};
prevModel = struct(field,modelValue);

%initiailze video process components
initColorBoxes();


foreFrame = zeros(height,width,3);
backFrame = zeros(height,width,3);

%map represents pixels at a given frame to perform adaptive process
pixThreshMap = ones(height,width);


%individual pixel process components
pixel = zeros(3,1);
pixMean = zeros(3,1,K);
pixVar = ones(1,K);
pixWeight = zeros(1,K);

%global pixel process components
globalWeight = (ones(height,width,K)/sideWeight);
globalWeight(:,:,1) = T;
%globalWeight = (ones(height,width,K)/K);
globalMean = zeros(height,width,3,K);
globalVar = ones(height,width,K);




%=====================================================
%Extract Foreground and Background by K-mixture model
%=====================================================
%initialize g-mixture model
globalVar = globalVar*initVariance;

for k=1:K
globalMean(:,:,1,k)=initFrame(:,:,1);
globalMean(:,:,2,k)=initFrame(:,:,2);
globalMean(:,:,3,k)=initFrame(:,:,3);
end;


distVec = zeros(numFrames,1);

%adaptive g-mixture background segmentation
for frameIndex=2:numFrames
%get current frame and the refernece frame
%tic;
frameIndex
currentFrame = double(read(v,frameIndex));



if (frameIndex<=referenceDistance)
referenceFrame= double(read(v,1));
else
referenceFrame= double(read(v,frameIndex-referenceDistance));
end;

frameDifference = abs(currentFrame - referenceFrame);

%creates map of pixel locations where we will perform adaptive process. Based
%upon threshold that detects low change regions based on previous frame in
%order to save computation.
pixThreshMap = min(sum(+(frameDifference(:,:,:)>pixelThresh),3),1);



for index=1:3
  backFrame(:,:,index)=(+(pixThreshMap(:,:)==0)).*currentFrame(:,:,index);      
end;

%extract the parts considered "stable background" from current frame

%reset foreground frame
foreFrame = ones(height,width,3)*255;

%gaussian mixture matching & model updating



[i,j]=find(pixThreshMap(:,:)==1);


%loop through every pixel location where adaptive process should be performed
for k = 1:size(i,1)
    
    pixel = reshape(currentFrame(i(k),j(k),:),3,1);
    pixMean = reshape(globalMean(i(k),j(k),:,:),3,1,K);
    pixVar = reshape(globalVar(i(k),j(k),:,:),1,K);
    pixWeight=reshape(globalWeight(i(k),j(k),:),1,K);
    
    %update gaussian mixture according to new pix value
    match=matchingCriterion(pixMean,pixVar,pixel);
    matchWeight = 0;
    
    if(match>0)
        %match found so update weights/normalize
        pixWeight = (1-alpha)*pixWeight;
        pixWeight(match)= pixWeight(match) + alpha;
        pixWeight = pixWeight/sum(pixWeight);
        matchWeight = pixWeight(1,match);
        
        %NOTE ALPHA SHOULD BE REPACED WITH SOME KIND OF RHO EVENTUALLY
        %WHERE RHO IS PRODUCT OF ALPHA AND CONDITIONAL PROBABILITY MEASURE
        
        %update variance
        pixVar(:,match) = (1-alpha)*pixVar(:,match) + ...
        alpha*(pixel - pixMean(:,:,match))'*(pixel-pixMean(:,:,match));
        
        %update mean
        pixMean(:,:,match) = (1-alpha)*pixMean(:,:,match) + alpha*pixel;
        

    
    else
        %no match currently found.
        %replace one with lowest sigma value
        
        rankVector = pixWeight./sqrt(pixVar(1,:));
        [mini minIndex] = min(rankVector);
        
        pixMean(:,:,minIndex) = pixel;  
        pixVar(:,minIndex) = initVariance;  
    end
    
    %rerank all pixel components
    rankCriterionVector = pixWeight./sqrt(pixVar(1,1,:)); 
    [rankSort rankIndex] = sort(rankCriterionVector);
    
    pixMean = pixMean(rankIndex);
    pixVar = pixVar(rankIndex);
    pixWeight = pixWeight(rankIndex);
       

    %repopulate global structures with updated values
    globalWeight(i(k),j(k),:) = pixWeight(:,1);
    globalMean(i(k),j(k),:,:) = pixMean(:,1,:);
    globalVar(i(k),j(k),:,:) = pixVar(:,:,:);
    
    %now need to perform the background segmentation based upon weight
    %threshold
    
    bgIndex = segmentBackground(pixWeight);
    if(ismember(matchWeight, pixWeight))
        matchIndex = find(pixWeight == matchWeight,1);
    else
        matchIndex = 0;
    end
    
    if((matchIndex>=bgIndex) || (matchIndex == 0))
        
        %also check against initFrame for match
        %NOTE CHANGE
        if(initMatch(initFrame(i(k),j(k),:),pixel) == 0)
          foreFrame(i(k),j(k),:) = pixel;   
        end 
        
    end
    
    
end


%Now write foreground frame to foreground estimation video
contrastFrame = foreFrame/max(abs(foreFrame(:)));

%remove all connected components associated with foreground objects that are smaller than what we expect a vehicle should be.
[cleanFrame centroids]= connectedComponentCleanup(contrastFrame);

if(trackingOn == 1)
if(size(centroids,1) > prevCentSize)
   prevModel = addModel(prevModel, centroids, height, width);
elseif (size(centroids,1) < prevCentSize)
   prevModel = removeModel(prevModel, centroids, height, width);
end


if(size(centroids,1) > 0)
    %implies there is a car in frame for tracking
    [curModel orderedCentroids] = vehicleTracking(centroids, prevModel);
    prevModel = curModel;
    trackFrame = colorBox(cleanFrame, curModel,orderedCentroids, height, width);  
else
    trackFrame = cleanFrame;
end

else
   trackFrame = cleanFrame; 
end

writeVideo(foregroundVideo,trackFrame); 
prevCentSize = size(centroids,1);
end