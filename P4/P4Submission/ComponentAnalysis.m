image = imread('imgs\shapes1.pnm');
%image = bitcmp(image);
%image = rgb2gray(image);
%image = medfilt2(image, [3,3]);

[segmentedImage, smoothedHistogram] = segmentImg(image);
[segmentedImage] = segmentImg(image);
[analysisOfImg] = ConnectedComponentAnalysis(image);
analysisOfImg = analysisOfImg * 6;


figure;
subplot(1, 2, 1);
imshow(image);
title('Original Image');
subplot(1, 2, 2);
imshow(analysisOfImg);
title('Component Analysis');

function [segmentedImage, smoothedHistogram] = segmentImg(image)
    
    isRgbImg = size(image, 3) == 3;
    if isRgbImg
        image = rgb2gray(image);
    end
    
    histogram = imhist(image);
    
    histogram = double(histogram);

    kernel = [1, 2, 3, 2, 1] / 9;
    smoothedHistogram = conv(histogram, kernel, 'same');

    [valleyValues, valleyIndices] = findpeaks(smoothedHistogram);    

    midValue = ( maxk(valleyIndices, 1) + mink(valleyIndices, 1)) / 2;

    threshold = ( midValue + mink(valleyIndices, 1) ) / 2;

    segmentedImage = image > threshold;
end

function [segmentedImg] = ConnectedComponentAnalysis(image)
    segmentedImg = segmentImg(image);
    [rows, cols] = size(segmentedImg);
    segmentedImg = padarray(segmentedImg, [1,1], 0, "both");
    segmentedImg = im2uint8(segmentedImg);
    
    classCounter = 0;
    for y = 2:rows
        for x = 2:cols
            pixelValue = segmentedImg(y, x);
            
            if pixelValue == 0
                continue;
            end
            neighborhood = segmentedImg(y - 1: y, x - 1: x);
            notConnected = length(neighborhood(neighborhood ~= 0)) == 1;
            connected = length(neighborhood(neighborhood ~= 0)) > 1;
            
            if notConnected
                classCounter = classCounter + 2;
                segmentedImg(y, x) = classCounter;
            elseif connected
                nonZeroNeighbors = neighborhood(neighborhood ~= 0);
                choice = maxk(nonZeroNeighbors, 1);
                segmentedImg(y, x) = choice;
            end
        end
    end
    
    for i = 1:10
        for y = 2:rows
            for x = 2:cols
                pixelValue = segmentedImg(y, x);
                
                if pixelValue == 0
                    continue;
                end
                neighborhood = segmentedImg(y - 1: y, x - 1: x);
                isConflicting = unique(neighborhood(neighborhood ~= 0)) > 1;
                
                if isConflicting
                    neighborhood = neighborhood(neighborhood > 0);
                    minNeighbor = mink(neighborhood, 1);
                    for y_i = y -1: y
                        for x_i = x -1: x
                            if segmentedImg(y_i, x_i) ~= 0
                                segmentedImg(y_i, x_i) = minNeighbor;
                            end
                        end 
                    end
                end
            end
        end
    end
end