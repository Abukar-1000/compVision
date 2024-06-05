image = imread('imgs\keys.jpg');
%image = bitcmp(image);
%image = medfilt2(image, [3,3]);

[segmentedImage, smoothedHistogram] = segmentImg(image);
plot(smoothedHistogram);


figure;
subplot(1, 2, 1);
imshow(image);
title('Original Image');
subplot(1, 2, 2);
imshow(segmentedImage);
title('Segmented Image');


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


function [geometricFeatures] = computeFeatures(image)
    [components] = ConnectedComponentAnalysis(image);
    segments = unique(components);
    segments = segments(segments > 0)

    geometricFeatures = double([]);


    for i = 1:length(segments)
        id = segments(i);
        regionOfIntrest = components;
        regionOfIntrest(regionOfIntrest ~= id) = 0;
        area = length(regionOfIntrest(regionOfIntrest ~= 0));
        [xCenter, yCenter] = computeCentroid(regionOfIntrest);
        [perimeter] = computeParimeter(regionOfIntrest);
        compactness = (perimeter^2)/(4 * pi * area);
        geometricFeatures(i,1) = id;
        geometricFeatures(i,2) = area;
        geometricFeatures(i,3) = perimeter;
        geometricFeatures(i,4) = xCenter;
        geometricFeatures(i,5) = yCenter;
        geometricFeatures(i,6) = compactness;
    end
end

function [xBar , yBar] = computeCentroid(region)
    xBar = 0;
    yBar = 0;

    [rows, cols] = size(region);
    n = 0;

    for y =  1: rows
        for x =  1: cols
            if region(y, x) ~= 0
                xBar = xBar + x;
                yBar = yBar + y;
                n = n + 1;
            end
        end
    end

    xBar = xBar / n;
    yBar = yBar / n;
end

function [perimeter] = computeParimeter(regionOfIntrest)
    regionOfIntrest(regionOfIntrest ~= 0 ) = 255;
    boundary = bwboundaries(regionOfIntrest);
    boundary = boundary{1};
    distance = sqrt(sum(diff(boundary).^2, 2));
    perimeter = sum(distance);
end

function [] = plotCentroids(image, geometryData)
    centroids = geometryData(:, 4:5)
    [rows, cols] = size(centroids);
    
    imshow(image);
    hold on;
    for y = 1:rows
        for x = 1:cols
            xCenter = centroids(y, 1);
            yCenter = centroids(y, 2);
            plot(xCenter, yCenter, "*", "MarkerSize", 7);
        end
    end
    hold off;
end