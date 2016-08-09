function foundMatch = initMatch(initPixel, pixel)

global matchThres;
global initVariance;

foundMatch = 0;
initPixel = double(reshape(initPixel,3,1));
pixVarMatrix = eye(3)/initVariance;
pixDiff = abs(initPixel - pixel);
D = sqrt((pixDiff)'*pixVarMatrix*(pixDiff));

if(D<matchThres)
    foundMatch = 1;
end

end