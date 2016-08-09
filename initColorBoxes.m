function initColorBoxes()

global colorBoxVector;

redBox = zeros(30,30,3);
redBox(:,:,1) = ones(30,30);

greenBox = zeros(30,30,3);
greenBox(:,:,2) = ones(30,30);

blueBox = zeros(30,30,3);
blueBox(:,:,3) = ones(30,30);


cyanBox = ones(30,30,3);
cyanBox(:,:,1) = zeros(30,30);

magentaBox = ones(30,30,3);
magentaBox(:,:,2) = zeros(30,30);

yellowBox = ones(30,30,3);
yellowBox(:,:,3) = zeros(30,30);

blackBox = zeros(30,30,3);
whiteBox = ones(30,30,3);

field = 'f';
value = {blueBox; greenBox; redBox; cyanBox; magentaBox; yellowBox; blackBox; whiteBox;};
colorBoxVector = struct(field,value);



end